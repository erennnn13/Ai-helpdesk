import type { Request, Response, NextFunction } from "express";
import { TicketCategory } from "@prisma/client";
import { createError } from "../middleware/error.middleware";
import { prisma } from "../lib/prisma";

/**
 * Classifies a ticket by ID using Gemini API based on its subject and initial message.
 * Updates ticket.category in the database and returns the assigned category (or null).
 */
export async function classifyTicketHelper(ticketId: number): Promise<TicketCategory | null> {
  try {
    const apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_GENERATIVE_AI_API_KEY;
    if (!apiKey) {
      console.warn("⚠️ [AI Classifier] GEMINI_API_KEY is not configured.");
      return null;
    }

    const ticket = await prisma.ticket.findUnique({
      where: { id: ticketId },
      include: {
        messages: { orderBy: { createdAt: "asc" }, take: 1 },
      },
    });

    if (!ticket) {
      console.warn(`⚠️ [AI Classifier] Ticket #${ticketId} not found.`);
      return null;
    }

    const initialMessage = ticket.messages[0]?.body || "";
    const validCategories = Object.values(TicketCategory);

    const prompt = `Analyze the support ticket subject and customer message below, and classify it into one of the allowed categories: ${validCategories.join(", ")}.

Ticket Subject: "${ticket.subject}"
Customer Message:
"""
${initialMessage}
"""

Classify the ticket accurately based on the issue described.`;

    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=${apiKey}`;
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.1,
          responseMimeType: "application/json",
          responseSchema: {
            type: "OBJECT",
            properties: {
              category: {
                type: "STRING",
                enum: validCategories,
                description: "The classified ticket category matching one of the valid enum values",
              },
              reasoning: {
                type: "STRING",
                description: "Brief rationale for selecting this category",
              },
            },
            required: ["category"],
          },
        },
      }),
    });

    if (!response.ok) {
      const errorData: any = await response.json().catch(() => ({}));
      console.warn("⚠️ [AI Classifier] Gemini API request failed:", errorData?.error?.message || response.statusText);
      return null;
    }

    const data: any = await response.json();
    const responseText = data.candidates?.[0]?.content?.parts?.[0]?.text?.trim() || "";

    let category: TicketCategory | null = null;

    if (responseText) {
      try {
        const parsed = JSON.parse(responseText);
        if (parsed.category && validCategories.includes(parsed.category as TicketCategory)) {
          category = parsed.category as TicketCategory;
          if (parsed.reasoning) {
            console.log(`💡 [AI Classifier] Reasoning: ${parsed.reasoning}`);
          }
        }
      } catch {
        // Fallback parsing if JSON wrapper is stripped
        const matched = validCategories.find(
          (cat) => responseText.toUpperCase().includes(cat)
        );
        if (matched) {
          category = matched;
        }
      }
    }

    if (category) {
      await prisma.ticket.update({
        where: { id: ticketId },
        data: { category },
      });
      console.log(`🤖 [AI Classifier] Ticket #${ticketId} auto-classified as: ${category}`);
    }

    return category;
  } catch (error) {
    console.error("❌ [AI Classifier] Background error during ticket classification:", error);
    return null;
  }
}

/**
 * Non-blocking trigger to enqueue a ticket classification job via pg-boss.
 * Returns immediately; the actual Gemini API call is handled by the classify worker.
 * All errors are caught internally so callers are never interrupted.
 */
export function classifyTicketInBackground(ticketId: number): void {
  import("../lib/queue")
    .then(({ enqueueClassifyJob }) => enqueueClassifyJob(ticketId))
    .catch((err) => {
      console.error(`❌ [AI Classifier] Failed to enqueue classify job for ticket #${ticketId}:`, err);
    });
}

/**
 * POST /api/tickets/:id/classify
 * HTTP endpoint to classify a ticket using Gemini API.
 * Supports async mode (query ?async=true) for non-blocking execution.
 */
export async function classifyTicket(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const id = parseInt(String(req.params.id), 10);
    if (isNaN(id)) {
      return next(createError("Invalid ticket ID", 400));
    }

    const ticket = await prisma.ticket.findUnique({ where: { id } });
    if (!ticket) {
      return next(createError("Ticket not found", 404));
    }

    if (req.query.async === "true") {
      classifyTicketInBackground(id);
      res.json({ message: "Classification started in background", ticketId: id });
      return;
    }

    const apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_GENERATIVE_AI_API_KEY;
    if (!apiKey) {
      return next(createError("GEMINI_API_KEY is not configured in environment variables", 500));
    }

    const category = await classifyTicketHelper(id);
    const updatedTicket = await prisma.ticket.findUnique({ where: { id } });

    res.json({ category: category || updatedTicket?.category || null, ticket: updatedTicket });
  } catch (error: any) {
    console.error("AI Classify Endpoint Error:", error);
    next(createError(error?.message || "Failed to classify ticket", 500));
  }
}

export async function polishReply(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { draft, subject, customerName, agentName } = req.body;

    if (!draft || typeof draft !== "string" || !draft.trim()) {
      return next(createError("Draft reply text is required", 400));
    }

    const apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_GENERATIVE_AI_API_KEY;
    if (!apiKey) {
      return next(createError("GEMINI_API_KEY is not configured in environment variables", 500));
    }

    const customerFirstName = customerName?.trim().split(/\s+/)[0];
    const agentFirstName = agentName?.trim().split(/\s+/)[0];

    const customerGreetingPrompt = customerFirstName
      ? `Address the customer directly using ONLY their first name, "${customerFirstName}" (e.g. "Dear ${customerFirstName}," or "Hi ${customerFirstName},"). Do NOT use their full name or last name.`
      : `Address the customer using only their first name if known.`;

    const agentSignoffPrompt = agentFirstName
      ? `Sign off the response using ONLY the assigned agent's first name, "${agentFirstName}" (e.g. "Best regards,\n${agentFirstName}" or "Sincerely,\n${agentFirstName}"). Do NOT include the agent's last name.`
      : `Sign off professionally using a first name on behalf of the support team.`;

    const prompt = `You are a professional, polite, and clear customer support agent assistant.
Your task is to refine and polish the agent's draft reply to a customer support ticket.

Context:
- Ticket Subject: "${subject || "Support Ticket"}"
${customerFirstName ? `- Customer First Name: "${customerFirstName}"` : ""}
${agentFirstName ? `- Assigned Agent First Name: "${agentFirstName}"` : ""}

Agent Draft Reply:
"""
${draft.trim()}
"""

Formatting & Tone Guidelines:
- ${customerGreetingPrompt}
- ${agentSignoffPrompt}
- Make the response professional, clear, empathetic, and grammatically correct.
- Preserve all core facts, steps, and information provided by the agent.
- Do NOT hallucinate new policies or unverified promises.
- Output ONLY the refined reply text directly. Do not include markdown code block formatting (\`\`\`) or conversational intro/outro text.`;

    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=${apiKey}`;
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.3 }
      })
    });

    const data: any = await response.json();

    if (!response.ok) {
      const msg = data.error?.message || "";
      if (response.status === 429 || msg.includes("Quota exceeded") || msg.includes("limit: 0")) {
        return next(createError("Gemini API Key Quota Exceeded. Please verify your API key quota in Google AI Studio.", 429));
      }
      if (response.status === 401 || msg.includes("invalid authentication credentials") || msg.includes("API_KEY_INVALID")) {
        return next(createError("Invalid Gemini API Key format.", 401));
      }
      return next(createError(msg || "Failed to polish reply with AI", 500));
    }

    const polishedText = data.candidates?.[0]?.content?.parts?.[0]?.text;
    res.json({ polishedText: polishedText ? polishedText.trim() : draft.trim() });
  } catch (error: any) {
    console.error("AI Polish Error:", error);
    next(createError(error?.message || "Failed to polish reply with AI", 500));
  }
}

/**
 * POST /api/tickets/:id/summarize
 * Summarizes the ticket subject and full conversation history using Gemini.
 * Persists the result to ticket.aiSummary and returns { aiSummary }.
 */
export async function summarizeTicket(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const id = parseInt(String(req.params.id), 10);
    if (isNaN(id)) {
      return next(createError("Invalid ticket ID", 400));
    }

    const apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_GENERATIVE_AI_API_KEY;
    if (!apiKey) {
      return next(createError("GEMINI_API_KEY is not configured in environment variables", 500));
    }

    const ticket = await prisma.ticket.findUnique({
      where: { id },
      include: {
        messages: { orderBy: { createdAt: "asc" } },
      },
    });

    if (!ticket) {
      return next(createError("Ticket not found", 404));
    }

    const conversationLines = ticket.messages
      .map((msg) => {
        const role = (msg.sender || "").toUpperCase();
        const label =
          role === "CUSTOMER" ? "Customer" :
          role === "AI"       ? "AI Agent" :
          role === "ADMIN"    ? "Admin"    : "Agent";
        const date = new Date(msg.createdAt).toISOString();
        return `[${date}] ${label}: ${msg.body?.trim() || "(no content)"}`;
      })
      .join("\n");

    const prompt = `You are a concise support ticket summarizer.
Given the ticket details and full conversation history below, produce a brief, clear summary (3–5 sentences) that covers:
1. The customer's core issue or request.
2. Key actions taken or responses provided.
3. The current resolution status.

Ticket Details:
- Subject: "${ticket.subject}"
- Customer: ${ticket.customerName || "Unknown"} (${ticket.customerEmail})
- Status: ${ticket.status}
${ticket.category ? `- Category: ${ticket.category}` : ""}

Conversation History (chronological):
${conversationLines || "(no messages yet)"}

Output ONLY the summary paragraph. No bullet points, no markdown formatting.`;

    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=${apiKey}`;
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.2 },
      }),
    });

    const data: any = await response.json();

    if (!response.ok) {
      const msg = data.error?.message || "";
      if (response.status === 429 || msg.includes("Quota exceeded") || msg.includes("limit: 0")) {
        return next(createError("Gemini API Key Quota Exceeded.", 429));
      }
      if (response.status === 401 || msg.includes("API_KEY_INVALID")) {
        return next(createError("Invalid Gemini API Key.", 401));
      }
      return next(createError(msg || "Failed to summarize ticket", 500));
    }

    const aiSummary = data.candidates?.[0]?.content?.parts?.[0]?.text?.trim();
    if (!aiSummary) {
      return next(createError("AI did not return a summary", 500));
    }

    // Persist summary to the database
    await prisma.ticket.update({
      where: { id },
      data: { aiSummary },
    });

    res.json({ aiSummary });
  } catch (error: any) {
    console.error("AI Summarize Error:", error);
    next(createError(error?.message || "Failed to summarize ticket", 500));
  }
}


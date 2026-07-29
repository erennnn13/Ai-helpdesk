import fs from "fs/promises";
import path from "path";
import crypto from "crypto";
import { TicketCategory, TicketStatus } from "@prisma/client";
import { prisma } from "./prisma";
import { sendOutboundEmail } from "./mailer";

/**
 * Loads Knowledge-base.md content from workspace root.
 */
export async function loadKnowledgeBaseContent(): Promise<string> {
  try {
    const kbPath = path.join(process.cwd(), "..", "Knowledge-base.md");
    const content = await fs.readFile(kbPath, "utf-8");
    return content;
  } catch (err) {
    // Fallback if cwd is server root
    try {
      const kbPath = path.join(process.cwd(), "Knowledge-base.md");
      return await fs.readFile(kbPath, "utf-8");
    } catch {
      console.warn("⚠️ [KB Solver] Knowledge-base.md file not found.");
      return "";
    }
  }
}

export interface KBEvaluationResult {
  canResolve: boolean;
  confidence: number;
  kbQuestionMatched?: string;
  solutionReply?: string;
  category?: TicketCategory;
  reasoning?: string;
}

/**
 * Main function to evaluate a ticket against Knowledge-base.md and classify/resolve it.
 *
 * State Transitions:
 *  - On Start : Status -> PROCESSING
 *  - On Match : Status -> RESOLVED (AI message added to thread)
 *  - On Miss  : Status -> OPEN     (ready for human agent)
 */
export async function processTicketAutoResolution(ticketId: number): Promise<TicketStatus> {
  try {
    const apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_GENERATIVE_AI_API_KEY;
    if (!apiKey) {
      console.warn("⚠️ [KB Solver] GEMINI_API_KEY is missing. Defaulting ticket to OPEN.");
      await prisma.ticket.update({
        where: { id: ticketId },
        data: { status: TicketStatus.OPEN },
      });
      return TicketStatus.OPEN;
    }

    // Step 1: Set ticket status to PROCESSING
    await prisma.ticket.update({
      where: { id: ticketId },
      data: { status: TicketStatus.PROCESSING },
    });
    console.log(`⏳ [KB Solver] Ticket #${ticketId} status set to PROCESSING.`);

    const ticket = await prisma.ticket.findUnique({
      where: { id: ticketId },
      include: {
        messages: { orderBy: { createdAt: "asc" }, take: 1 },
      },
    });

    if (!ticket) {
      console.warn(`⚠️ [KB Solver] Ticket #${ticketId} not found.`);
      return TicketStatus.OPEN;
    }

    const kbContent = await loadKnowledgeBaseContent();
    if (!kbContent) {
      console.warn("⚠️ [KB Solver] Empty Knowledge Base. Transitioning ticket to OPEN.");
      await prisma.ticket.update({
        where: { id: ticketId },
        data: { status: TicketStatus.OPEN },
      });
      return TicketStatus.OPEN;
    }

    const initialMessage = ticket.messages[0]?.body || "";
    const validCategories = Object.values(TicketCategory);

    const prompt = `You are an automated support assistant for a ticketing system.
Your task is to analyze the support ticket subject and customer message against the official Knowledge Base provided below.

Determine if the customer's query can be fully, accurately, and conclusively answered using ONLY the information in the Knowledge Base.

--- OFFICIAL KNOWLEDGE BASE ---
${kbContent}
--------------------------------

Customer Support Ticket:
- Ticket Subject: "${ticket.subject}"
- Customer Message:
"""
${initialMessage}
"""

Rules:
1. Set "canResolve" to true ONLY IF a matching solution exists in the Knowledge Base above.
2. If no clear match exists or if the request requires custom account inspection/human intervention, set "canResolve" to false.
3. Set "confidence" between 0.0 and 1.0 (use >= 0.8 for strong matches).
4. Select the most accurate "category" from: ${validCategories.join(", ")}.
5. If "canResolve" is true, write a polite, professional, step-by-step "solutionReply" citing the Knowledge Base.
   CRITICAL FORMATTING INSTRUCTION: Ensure every paragraph and every numbered step is separated by a clear newline (\\n) so it renders cleanly as distinct paragraphs and bullet points!`;

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
              canResolve: { type: "BOOLEAN", description: "True if Knowledge Base fully answers the query" },
              confidence: { type: "NUMBER", description: "Confidence score between 0.0 and 1.0" },
              kbQuestionMatched: { type: "STRING", description: "The specific Knowledge Base question heading matched" },
              solutionReply: { type: "STRING", description: "Polite customer solution reply based on KB" },
              category: { type: "STRING", enum: validCategories, description: "Classified ticket category" },
              reasoning: { type: "STRING", description: "Brief rationale" },
            },
            required: ["canResolve", "confidence", "category"],
          },
        },
      }),
    });

    if (!response.ok) {
      console.warn("⚠️ [KB Solver] Gemini API request failed. Reverting status to OPEN.");
      await prisma.ticket.update({
        where: { id: ticketId },
        data: { status: TicketStatus.OPEN },
      });
      return TicketStatus.OPEN;
    }

    const data: any = await response.json();
    const responseText = data.candidates?.[0]?.content?.parts?.[0]?.text?.trim() || "";

    let evalResult: KBEvaluationResult = { canResolve: false, confidence: 0 };
    if (responseText) {
      try {
        evalResult = JSON.parse(responseText);
      } catch {
        console.warn("⚠️ [KB Solver] Could not parse JSON response from Gemini.");
      }
    }

    const category = (evalResult.category && validCategories.includes(evalResult.category as TicketCategory))
      ? (evalResult.category as TicketCategory)
      : null;

    const isMatch = evalResult.canResolve && (evalResult.confidence ?? 0) >= 0.75 && !!evalResult.solutionReply;

    if (isMatch) {
      const solutionBody = evalResult.solutionReply!.trim();

      // Convert line breaks and numbered items into clean paragraphs and lists for bodyHtml
      const formattedHtml = solutionBody
        .split(/\n+/)
        .map((line) => line.trim())
        .filter(Boolean)
        .map((line) => {
          if (/^\d+[\.\)]\s*/.test(line)) {
            return `<li style="margin-bottom: 4px;">${line.replace(/^\d+[\.\)]\s*/, "")}</li>`;
          }
          return `<p style="margin-bottom: 8px;">${line}</p>`;
        })
        .join("");

      const bodyHtml = formattedHtml.includes("<li")
        ? `<p style="margin-bottom: 8px;">${solutionBody.split("\n")[0]}</p><ol style="list-style-type: decimal; padding-left: 20px; margin-bottom: 8px;">${formattedHtml.replace(/<p[^>]*>.*?<\/p>/g, "")}</ol>`
        : formattedHtml;

      // Create AI solution message
      await prisma.message.create({
        data: {
          id: crypto.randomUUID(),
          ticketId,
          body: solutionBody,
          bodyHtml: bodyHtml,
          sender: "AI",
          senderEmail: "ai-assistant@support.local",
        },
      });

      const updated = await prisma.ticket.update({
        where: { id: ticketId },
        data: {
          status: TicketStatus.RESOLVED,
          category: category || ticket.category,
          aiSummary: `Auto-resolved via Knowledge Base: ${evalResult.kbQuestionMatched || "Direct match"}`,
        },
      });

      console.log(`🎉 [KB Solver] Ticket #${ticketId} AUTO-RESOLVED by AI!`);
      if (evalResult.reasoning) console.log(`💡 [KB Solver] Reasoning: ${evalResult.reasoning}`);

      // Dispatch auto-resolution email to customer
      if (ticket.customerEmail) {
        sendOutboundEmail({
          to: ticket.customerEmail,
          subject: ticket.subject,
          text: solutionBody,
          html: bodyHtml,
          ticketId,
        }).catch((err) => {
          console.error("❌ Failed to dispatch AI auto-resolution email:", err);
        });
      }

      return updated.status;
    } else {
      // No match found -> Move to OPEN for human agent
      const updated = await prisma.ticket.update({
        where: { id: ticketId },
        data: {
          status: TicketStatus.OPEN,
          category: category || ticket.category,
        },
      });

      console.log(`📌 [KB Solver] Ticket #${ticketId} could not be auto-resolved. Status updated to OPEN.`);
      if (evalResult.reasoning) console.log(`💡 [KB Solver] Reasoning: ${evalResult.reasoning}`);

      return updated.status;
    }
  } catch (error) {
    console.error(`❌ [KB Solver] Unexpected error processing ticket #${ticketId}:`, error);
    await prisma.ticket.update({
      where: { id: ticketId },
      data: { status: TicketStatus.OPEN },
    }).catch(() => {});
    return TicketStatus.OPEN;
  }
}

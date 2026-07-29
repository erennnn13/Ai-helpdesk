import type { Request, Response, NextFunction } from "express";
import { prisma } from "../lib/prisma";
import { TicketStatus } from "@prisma/client";
import { enqueueAutoResolveJob } from "../lib/queue";
import { createError } from "../middleware/error.middleware";

/**
 * Extract ticket ID from subject or MailboxHash.
 * e.g., "Re: [Ticket #42] Cannot reset password" -> 42
 * e.g., "ticket-42" -> 42
 */
function extractTicketId(subject: string, mailboxHash?: string): number | null {
  if (mailboxHash) {
    const hashMatch = mailboxHash.match(/^(?:ticket-)?(\d+)$/i);
    if (hashMatch) {
      const parsed = parseInt(hashMatch[1]!, 10);
      if (!isNaN(parsed) && parsed > 0) return parsed;
    }
  }

  if (subject) {
    const subjectMatch = subject.match(/\[Ticket\s*#(\d+)\]/i) || subject.match(/\[#(\d+)\]/i);
    if (subjectMatch) {
      const parsed = parseInt(subjectMatch[1]!, 10);
      if (!isNaN(parsed) && parsed > 0) return parsed;
    }
  }

  return null;
}

/**
 * Extract clean sender name and email from Postmark fields.
 */
function parseSender(body: any): { customerEmail: string; customerName: string } {
  let email = body.FromFull?.Email || body.From || "";
  let name = body.FromFull?.Name || body.FromName || "";

  // If From is in format "John Doe <john@example.com>"
  if (typeof email === "string" && email.includes("<")) {
    const match = email.match(/(?:"?([^"]*)"?\s)?<([^>]+)>/);
    if (match) {
      name = name || match[1] || "";
      email = match[2] || "";
    }
  }

  email = (email || "").trim().toLowerCase();
  if (!name || !name.trim()) {
    name = email.includes("@") ? email.split("@")[0]! : "Customer";
  } else {
    name = name.trim();
  }

  return { customerEmail: email, customerName: name };
}

/**
 * POST /api/webhooks/postmark
 * Inbound webhook handler for Postmark emails.
 */
export async function handlePostmarkInbound(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    // Optional secret verification
    const webhookSecret = process.env.POSTMARK_WEBHOOK_SECRET;
    if (webhookSecret) {
      const authHeader = req.headers["x-postmark-secret"] || req.query.secret;
      if (authHeader !== webhookSecret) {
        return next(createError("Unauthorized webhook request", 401));
      }
    }

    const payload = req.body;
    if (!payload || typeof payload !== "object") {
      return next(createError("Invalid webhook body", 400));
    }

    const { customerEmail, customerName } = parseSender(payload);

    if (!customerEmail) {
      console.warn("⚠️ [Postmark Webhook] Received email payload missing sender email.");
      res.status(200).json({ status: "ignored", reason: "missing_sender" });
      return;
    }

    const subject = (payload.Subject || "(no subject)").trim();
    
    // Extract true Internet Message-ID header from Headers array (e.g. <CAGx...=123@mail.gmail.com>)
    let rawMessageId = payload.MessageID || payload.MessageId || `postmark-${Date.now()}-${Math.random()}`;
    if (Array.isArray(payload.Headers)) {
      const msgIdHeader = payload.Headers.find(
        (h: any) => h && h.Name && String(h.Name).toLowerCase() === "message-id"
      );
      if (msgIdHeader && msgIdHeader.Value && String(msgIdHeader.Value).trim()) {
        rawMessageId = String(msgIdHeader.Value).trim();
      }
    }

    const textBody = (payload.TextBody || "").trim();
    const htmlBody = (payload.HtmlBody || "").trim();

    // Plain text body fallback
    const bodyContent = textBody || (htmlBody ? htmlBody.replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim() : "(no body)");

    // Deduplication check
    if (payload.MessageID) {
      const existingLog = await prisma.emailLog.findUnique({
        where: { messageId: payload.MessageID },
      });

      if (existingLog) {
        console.log(`📧 [Postmark Webhook] Duplicate MessageID ${payload.MessageID} — skipping`);
        res.status(200).json({ status: "duplicate", ticketId: existingLog.ticketId });
        return;
      }
    }

    // Thread matching check
    const potentialTicketId = extractTicketId(subject, payload.MailboxHash);

    if (potentialTicketId) {
      const existingTicket = await prisma.ticket.findUnique({
        where: { id: potentialTicketId },
      });

      if (existingTicket) {
        // Thread message to existing ticket
        const result = await prisma.$transaction(async (tx) => {
          const newMsg = await tx.message.create({
            data: {
              ticketId: existingTicket.id,
              body: bodyContent,
              bodyHtml: htmlBody || null,
              sender: "CUSTOMER",
              senderEmail: customerEmail,
            },
          });

          await tx.emailLog.create({
            data: {
              messageId: rawMessageId,
              ticketId: existingTicket.id,
            },
          });

          // Re-open ticket if it was resolved or closed
          if (
            existingTicket.status === TicketStatus.RESOLVED ||
            existingTicket.status === TicketStatus.CLOSED
          ) {
            await tx.ticket.update({
              where: { id: existingTicket.id },
              data: { status: TicketStatus.OPEN },
            });
          }

          return newMsg;
        });

        console.log(`✅ [Postmark Webhook] Appended message to existing ticket #${existingTicket.id} from ${customerEmail}`);
        res.status(200).json({
          status: "threaded",
          ticketId: existingTicket.id,
          messageId: result.id,
        });
        return;
      }
    }

    // Create new ticket + first message
    const newTicket = await prisma.$transaction(async (tx) => {
      const createdTicket = await tx.ticket.create({
        data: {
          subject,
          customerName,
          customerEmail,
          source: "EMAIL",
          messages: {
            create: {
              body: bodyContent,
              bodyHtml: htmlBody || null,
              sender: "CUSTOMER",
              senderEmail: customerEmail,
            },
          },
        },
      });

      await tx.emailLog.create({
        data: {
          messageId: rawMessageId,
          ticketId: createdTicket.id,
        },
      });

      return createdTicket;
    });

    console.log(`✅ [Postmark Webhook] Created new ticket #${newTicket.id} from ${customerEmail} — "${subject}"`);

    // Trigger AI KB auto-resolution worker
    enqueueAutoResolveJob(newTicket.id);

    res.status(201).json({
      status: "created",
      ticketId: newTicket.id,
    });
  } catch (error) {
    next(error);
  }
}

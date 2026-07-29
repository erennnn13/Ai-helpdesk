import type { Request, Response, NextFunction } from "express";
import { Role } from "@prisma/client";
import { prisma } from "../lib/prisma";
import { createError } from "../middleware/error.middleware";
import { sendOutboundEmail } from "../lib/mailer";

function resolveSenderType(sender: string): "CUSTOMER" | "AGENT" | "ADMIN" | "AI" {
  const upper = (sender || "").toUpperCase();
  if (upper === "CUSTOMER") return "CUSTOMER";
  if (upper === "ADMIN") return "ADMIN";
  if (upper === "AI") return "AI";
  return "AGENT";
}

/**
 * GET /api/tickets/:id/messages
 * Get all messages for a ticket
 */
export async function getMessages(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const id = parseInt(String(req.params.id), 10);

    if (isNaN(id)) {
      return next(createError("Invalid ticket ID", 400));
    }

    // Verify ticket exists
    const ticket = await prisma.ticket.findUnique({ where: { id } });
    if (!ticket) {
      return next(createError("Ticket not found", 404));
    }

    const rawMessages = await prisma.message.findMany({
      where: { ticketId: id },
      orderBy: { createdAt: "asc" },
    });

    const messages = rawMessages.map((msg) => ({
      ...msg,
      senderType: resolveSenderType(msg.sender),
    }));

    res.json({ messages });
  } catch (error) {
    next(error);
  }
}

/**
 * POST /api/tickets/:id/messages
 * Add a message to a ticket (agent reply)
 */
export async function createMessage(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const id = parseInt(String(req.params.id), 10);

    if (isNaN(id)) {
      return next(createError("Invalid ticket ID", 400));
    }

    const { body, bodyHtml } = req.body;

    if (!body || !body.trim()) {
      return next(createError("Message body is required", 400));
    }

    // Verify ticket exists
    const ticket = await prisma.ticket.findUnique({ where: { id } });
    if (!ticket) {
      return next(createError("Ticket not found", 404));
    }

    // Get the current user's email and role for sender tracking
    const user = await prisma.user.findUnique({
      where: { id: res.locals.user?.id },
    });

    const senderRole = user?.role ? String(user.role) : Role.AGENT;

    const rawMessage = await prisma.message.create({
      data: {
        ticketId: id,
        body: body.trim(),
        bodyHtml: typeof bodyHtml === "string" && bodyHtml.trim() ? bodyHtml.trim() : null,
        sender: senderRole,
        senderEmail: user?.email,
      },
    });

    // Send outbound email to customer asynchronously for AGENT or ADMIN replies
    if (ticket.customerEmail && (senderRole === Role.AGENT || senderRole === Role.ADMIN)) {
      sendOutboundEmail({
        to: ticket.customerEmail,
        subject: ticket.subject,
        text: body.trim(),
        html: typeof bodyHtml === "string" && bodyHtml.trim() ? bodyHtml.trim() : undefined,
        ticketId: id,
      }).catch((err) => {
        console.error("❌ Failed to dispatch outbound email for agent reply:", err);
      });
    }

    const message = {
      ...rawMessage,
      senderType: resolveSenderType(rawMessage.sender),
    };

    res.status(201).json({ message });
  } catch (error) {
    next(error);
  }
}


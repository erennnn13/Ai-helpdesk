import type { Request, Response, NextFunction } from "express";
import { prisma } from "../lib/prisma";
import { createError } from "../middleware/error.middleware";
import { type Prisma, TicketStatus, TicketCategory } from "@prisma/client";
import type { TicketQuery } from "core";

/**
 * GET /api/tickets/stats
 * Returns counts per status — used by the dashboard, avoids fetching all ticket data
 */
export async function getTicketStats(
  _req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const [total, open, resolved, closed, aiResolved] = await Promise.all([
      prisma.ticket.count(),
      prisma.ticket.count({ where: { status: 'OPEN' } }),
      prisma.ticket.count({ where: { status: 'RESOLVED' } }),
      prisma.ticket.count({ where: { status: 'CLOSED' } }),
      prisma.ticket.count({ where: { aiSummary: { not: null } } }) // Approximate AI resolved
    ]);

    res.json({ stats: { open, resolved, closed, total, aiResolved } });
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/tickets
 * List tickets with filtering, sorting, and pagination
 */

// Scalar fields on Ticket that Prisma accepts in orderBy
const ALLOWED_SORT_FIELDS = new Set([
  "id",
  "subject",
  "status",
  "category",
  "source",
  "customerEmail",
  "customerName",
  "createdAt",
  "updatedAt",
]);

export async function getTickets(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    // validateQuery middleware stores parsed+defaulted values in res.locals.query
    // Fall back to req.query (as strings) if middleware wasn't used
    const q: TicketQuery = res.locals.query ?? req.query;

    const {
      status,
      category,
      assignedToId,
      aiResolved,
      search,
      sortBy: rawSortBy,
      sortOrder,
      page,
      limit,
    } = q as any;

    // Validate sortBy — fall back to createdAt if value is a relation or unknown field
    const sortBy = ALLOWED_SORT_FIELDS.has(rawSortBy) ? rawSortBy : "createdAt";

    const where: Prisma.TicketWhereInput = {};

    if (status) where.status = status as TicketStatus;
    if (category) where.category = category as TicketCategory;
    if (assignedToId) where.assignedToId = assignedToId;
    if (aiResolved === "true" || aiResolved === true) {
      where.status = "RESOLVED";
      where.messages = { some: { sender: "AI" } };
    }
    if (search) {
      where.OR = [
        { subject: { contains: search, mode: "insensitive" } },
        { customerName: { contains: search, mode: "insensitive" } },
        { customerEmail: { contains: search, mode: "insensitive" } },
      ];
    }

    const pageNum = typeof page === "number" ? page : (parseInt(page as any, 10) || 1);
    const limitNum = typeof limit === "number" ? limit : (parseInt(limit as any, 10) || 15);
    const skip = (pageNum - 1) * limitNum;

    const [ticketsRaw, total] = await Promise.all([
      prisma.ticket.findMany({
        where,
        include: {
          assignedTo: {
            select: { id: true, name: true, email: true, deletedAt: true },
          },
          _count: { select: { messages: true } },
        },
        orderBy: { [sortBy]: sortOrder },
        skip,
        take: limitNum,
      }),
      prisma.ticket.count({ where }),
    ]);

    const tickets = ticketsRaw.map((t) => ({
      ...t,
      assignedTo: t.assignedTo?.deletedAt ? null : t.assignedTo,
    }));

    res.json({
      tickets,
      pagination: {
        page: pageNum,
        limit: limitNum,
        total,
        totalPages: Math.ceil(total / limitNum),
      },
    });
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/tickets/:id
 * Get a single ticket with its messages
 */
export async function getTicketById(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const id = parseInt(String(req.params.id), 10);

    if (isNaN(id)) {
      return next(createError("Invalid ticket ID", 400));
    }

    const ticketRaw = await prisma.ticket.findUnique({
      where: { id },
      include: {
        assignedTo: {
          select: { id: true, name: true, email: true, deletedAt: true },
        },
        messages: {
          orderBy: { createdAt: "asc" },
        },
      },
    });

    if (!ticketRaw) {
      return next(createError("Ticket not found", 404));
    }

    const ticket = {
      ...ticketRaw,
      assignedTo: ticketRaw.assignedTo?.deletedAt ? null : ticketRaw.assignedTo,
      messages: ticketRaw.messages.map((msg) => {
        const upper = (msg.sender || "").toUpperCase();
        const senderType = upper === "CUSTOMER" ? "CUSTOMER" : upper === "ADMIN" ? "ADMIN" : upper === "AI" ? "AI" : "AGENT";
        return {
          ...msg,
          senderType,
        };
      }),
    };

    res.json({ ticket });
  } catch (error) {
    next(error);
  }
}

/**
 * PATCH /api/tickets/:id
 * Update ticket status, category, or assignment
 */
export async function updateTicket(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const id = parseInt(String(req.params.id), 10);

    if (isNaN(id)) {
      return next(createError("Invalid ticket ID", 400));
    }

    const { status, category, assignedToId } = req.body;

    const data: Prisma.TicketUpdateInput = {};
    if (status) data.status = status;
    if (category !== undefined) data.category = category ?? null;

    if (assignedToId !== undefined) {
      if (assignedToId) {
        // Validate that assignedToId corresponds to a valid, active user
        const targetUser = await prisma.user.findFirst({
          where: { id: assignedToId, deletedAt: null },
        });

        if (!targetUser) {
          return next(createError("Invalid assigned user ID: user does not exist", 400));
        }

        data.assignedTo = { connect: { id: assignedToId } };
      } else {
        data.assignedTo = { disconnect: true };
      }
    }

    const ticket = await prisma.ticket.update({
      where: { id },
      data,
      include: {
        assignedTo: {
          select: { id: true, name: true, email: true },
        },
      },
    });

    res.json({ ticket });
  } catch (error) {
    next(error);
  }
}

/**
 * POST /api/tickets
 * Create a new support ticket (and optional initial message)
 */
export async function createTicket(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { subject, customerName, customerEmail, body, category } = req.body;

    if (!subject || typeof subject !== "string" || !subject.trim()) {
      return next(createError("Subject is required", 400));
    }
    if (!customerEmail || typeof customerEmail !== "string" || !customerEmail.trim()) {
      return next(createError("Customer email is required", 400));
    }

    const email = customerEmail.trim().toLowerCase();
    const name = (customerName || "").trim() || email.split("@")[0];

    const ticket = await prisma.ticket.create({
      data: {
        subject: subject.trim(),
        customerName: name,
        customerEmail: email,
        category: category || null,
        source: "WEB",
        messages: body && typeof body === "string" && body.trim()
          ? {
              create: {
                body: body.trim(),
                sender: "CUSTOMER",
                senderEmail: email,
              },
            }
          : undefined,
      },
    });

    // Enqueue KB auto-resolution & classification job in background
    const { enqueueAutoResolveJob } = await import("../lib/queue");
    enqueueAutoResolveJob(ticket.id);

    res.status(201).json({ ticket });
  } catch (error) {
    next(error);
  }
}



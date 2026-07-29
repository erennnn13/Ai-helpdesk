import { z } from "zod";
// Force IDE reload

export type TicketStatus = "NEW" | "PROCESSING" | "OPEN" | "RESOLVED" | "CLOSED";
export type TicketCategory = "GENERAL" | "TECHNICAL" | "REFUND";
export type MessageSender = "CUSTOMER" | "AGENT" | "ADMIN" | "AI";

const emptyToUndefined = (val: unknown) => (val === "" ? undefined : val);

export const ticketQuerySchema = z.object({
  status: z.preprocess(emptyToUndefined, z.enum(["NEW", "PROCESSING", "OPEN", "RESOLVED", "CLOSED"]).optional()),
  category: z.preprocess(emptyToUndefined, z.enum(["GENERAL", "TECHNICAL", "REFUND"]).optional()),
  assignedToId: z.preprocess(emptyToUndefined, z.string().optional()),
  aiResolved: z.preprocess(emptyToUndefined, z.string().optional()),
  search: z.preprocess(emptyToUndefined, z.string().optional()),
  sortBy: z.preprocess(
    emptyToUndefined,
    z.enum(["id", "subject", "status", "category", "source", "customerEmail", "customerName", "createdAt", "updatedAt"])
      .default("createdAt")
  ),
  sortOrder: z.preprocess(emptyToUndefined, z.enum(["asc", "desc"]).default("desc")),
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(10),
});

export type TicketQuery = z.infer<typeof ticketQuerySchema>;

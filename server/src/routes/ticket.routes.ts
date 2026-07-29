import { Router } from "express";
import {
  getTickets,
  getTicketById,
  getTicketStats,
  updateTicket,
  createTicket,
} from "../controllers/ticket.controller";
import {
  getMessages,
  createMessage,
} from "../controllers/message.controller";
import { polishReply, summarizeTicket, classifyTicket } from "../controllers/ai.controller";
import { requireAuth } from "../middleware/auth.middleware";
import { validateQuery } from "../middleware/validate.middleware";
import { ticketQuerySchema } from "core";

export const ticketRouter = Router();

// All ticket routes require auth
ticketRouter.use(requireAuth);

// Stats & Polish endpoints — must be before /:id to avoid being matched as an ID
ticketRouter.get("/stats", getTicketStats);
ticketRouter.post("/polish", polishReply);

ticketRouter.get("/", validateQuery(ticketQuerySchema), getTickets);
ticketRouter.post("/", createTicket);
ticketRouter.get("/:id", getTicketById);
ticketRouter.patch("/:id", updateTicket);
ticketRouter.post("/:id/summarize", summarizeTicket);
ticketRouter.post("/:id/classify", classifyTicket);

// Nested message routes
ticketRouter.get("/:id/messages", getMessages);
ticketRouter.post("/:id/messages", createMessage);


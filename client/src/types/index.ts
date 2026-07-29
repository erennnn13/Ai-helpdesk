import { Role } from "core";
import type { TicketStatus, TicketCategory, MessageSender } from "core";

export interface Ticket {
  id: string | number;
  subject: string;
  status: TicketStatus;
  category: TicketCategory | null;
  customerEmail: string;
  customerName: string;
  aiSummary: string | null;
  assignedToId: string | null;
  assignedTo: {
    id: string;
    name: string;
    email: string;
  } | null;
  createdAt: string;
  updatedAt: string;
  _count?: {
    messages: number;
  };
  messages?: Message[];
}

export type MessageSenderType = "CUSTOMER" | "AGENT" | "ADMIN" | "AI";

export interface Message {
  id: string;
  ticketId: string | number;
  body: string;
  bodyHtml?: string | null;
  sender: MessageSender;
  senderType?: MessageSenderType;
  senderEmail: string | null;
  createdAt: string;
}

export interface PaginationInfo {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface TicketListResponse {
  tickets: Ticket[];
  pagination: PaginationInfo;
}

export interface User {
  id: string;
  email: string;
  name: string;
  role: Role;
  createdAt: string;
  updatedAt?: string;
}

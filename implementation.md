# AI-Based Ticketing System — Implementation Plan

Build a full-stack ticket management system that uses AI to classify, summarize, and suggest replies for support tickets received via email.

---

## Decisions Required

> [!IMPORTANT]
> **AI Provider**: The tech stack lists Gemini and OpenAI as options. This plan assumes **Google Gemini API** (free tier). Confirm if you'd prefer OpenAI instead.

> [!IMPORTANT]
> **Inbound Email**: The tech stack marks inbound email as TBD. This plan uses **IMAP polling** (simplest to develop locally, no webhook infrastructure needed). Confirm if you'd prefer SendGrid Inbound Parse or Mailgun Routes.

> [!IMPORTANT]
> **Authentication**: The tech stack mentions database sessions. This plan uses **express-session + connect-pg-simple** for session-based auth with PostgreSQL. Confirm if acceptable.

## Open Questions

1. **Knowledge Base** — The project mentions "auto-generate responses using a knowledge base." Should this be a simple table of FAQ-style entries that admins can CRUD, or something more complex (e.g., document uploads with vector search)?
2. **Real-time updates** — Should the dashboard update in real-time (WebSockets) or is polling / manual refresh acceptable for v1?
3. **Multi-tenancy** — Is this a single-organization system, or should it support multiple orgs/companies?

---

## Project Structure

```
Ai based ticketing System/
├── client/                  # React frontend
│   ├── src/
│   │   ├── components/      # Reusable UI components
│   │   ├── pages/           # Route-level pages
│   │   ├── hooks/           # Custom React hooks
│   │   ├── services/        # API client functions
│   │   ├── types/           # TypeScript interfaces
│   │   ├── context/         # Auth & app context
│   │   └── utils/           # Helper functions
│   ├── index.html
│   ├── tailwind.config.js
│   ├── tsconfig.json
│   └── vite.config.ts
├── server/
│   ├── src/
│   │   ├── routes/          # Express route handlers
│   │   ├── controllers/     # Business logic
│   │   ├── middleware/       # Auth, validation, error handling
│   │   ├── services/        # AI, email, ticket services
│   │   ├── prisma/          # Schema & migrations
│   │   ├── utils/           # Helpers
│   │   └── index.ts         # Entry point
│   ├── tsconfig.json
│   └── .env
├── docker-compose.yml
├── project.md
├── tech-stack.md
└── implementation.md
```

## Database Schema

```
User          { id, email, name, passwordHash, role(ADMIN/AGENT), createdAt, updatedAt }
Ticket        { id, subject, status(OPEN/RESOLVED/CLOSED), category, priority,
                customerEmail, customerName, assignedToId?, aiSummary?,
                createdAt, updatedAt }
Message       { id, ticketId, body, sender(CUSTOMER/AGENT/AI), senderEmail?,
                createdAt }
KnowledgeBase { id, question, answer, category, createdAt, updatedAt }
AuditLog      { id, userId, action, entityType, entityId, createdAt }
```

---

## Phases

The project is broken into **7 phases**, ordered by dependency. Each phase is self-contained and delivers a testable increment.

---

### Phase 1 — Project Scaffolding & Database

Set up the monorepo structure, tooling, database schema, and dev environment.

| # | Task | Details |
|---|------|---------|
| 1.1 | Initialize monorepo structure | Create `client/` (React + Vite) and `server/` (Express) directories |
| 1.2 | Set up server project | `npm init`, install Express, TypeScript, ts-node-dev, dotenv, cors |
| 1.3 | Set up client project | Vite + React 19 + TypeScript, install React Router 7, Tailwind CSS 3 |
| 1.4 | Configure TypeScript | `tsconfig.json` for both client and server with strict mode |
| 1.5 | Set up Docker Compose | PostgreSQL 16 container + pgAdmin for local dev |
| 1.6 | Initialize Prisma | `prisma init`, configure `DATABASE_URL`, create initial schema |
| 1.7 | Design database schema | Tables: `User`, `Ticket`, `Message`, `TicketCategory`, `AuditLog` |
| 1.8 | Run initial migration | `prisma migrate dev` to create all tables |
| 1.9 | Seed script | Create default admin user + sample ticket data for development |

---

### Phase 2 — Authentication & User Management

Implement session-based auth, login/register flows, and admin user management.

| # | Task | Details |
|---|------|---------|
| 2.1 | Install auth dependencies | bcryptjs, express-session, connect-pg-simple |
| 2.2 | Create auth middleware | `requireAuth`, `requireAdmin` middleware functions |
| 2.3 | Build auth routes | `POST /api/auth/login`, `POST /api/auth/logout`, `GET /api/auth/me` |
| 2.4 | Password hashing utilities | bcrypt hash & compare wrappers |
| 2.5 | Build user management API | `GET /api/users`, `POST /api/users` (admin-only), `PATCH /api/users/:id`, `DELETE /api/users/:id` |
| 2.6 | Build Login page (frontend) | Email + password form, error handling, redirect on success |
| 2.7 | Build Auth context | React context for current user, login/logout functions |
| 2.8 | Build protected route wrapper | Redirect unauthenticated users to login |
| 2.9 | Build User Management page | Admin-only page: list agents, create new agent, edit/delete |
| 2.10 | Build app layout shell | Sidebar navigation, header with user info, logout button |

---

### Phase 3 — Ticket CRUD & Core UI

Build the ticket management backbone — listing, filtering, detail view, and messaging.

| # | Task | Details |
|---|------|---------|
| 3.1 | Build ticket API routes | `GET /api/tickets` (with filters), `GET /api/tickets/:id`, `PATCH /api/tickets/:id` |
| 3.2 | Build message API routes | `GET /api/tickets/:id/messages`, `POST /api/tickets/:id/messages` |
| 3.3 | Implement ticket filters | Filter by status, category, assignee; sort by date/priority |
| 3.4 | Implement pagination | Cursor-based or offset pagination for ticket list |
| 3.5 | Build Ticket List page | Table/card view with status badges, category tags, search bar |
| 3.6 | Build Ticket Detail page | Ticket metadata panel + message thread (chronological) |
| 3.7 | Build reply composer | Text area for agent replies, send button |
| 3.8 | Build status/category update UI | Dropdowns to change ticket status and category |
| 3.9 | Build ticket assignment UI | Assign/reassign ticket to an agent |
| 3.10 | Build ticket search | Full-text search across subject and message body |

---

### Phase 4 — AI Integration

Wire up Gemini API for classification, summarization, and suggested replies.

| # | Task | Details |
|---|------|---------|
| 4.1 | Set up Gemini SDK | Install `@google/generative-ai`, configure API key |
| 4.2 | Build AI service layer | `services/ai.ts` — abstraction over Gemini calls with retries and error handling |
| 4.3 | Implement ticket classification | Prompt engineering: classify into General / Technical / Refund based on message content |
| 4.4 | Implement thread summarization | Summarize full ticket conversation into 2-3 sentences |
| 4.5 | Implement suggested reply generation | Generate 1-3 reply suggestions based on thread context + knowledge base entries |
| 4.6 | Build classification API endpoint | `POST /api/tickets/:id/classify` — auto-classify and update ticket |
| 4.7 | Build summarization API endpoint | `POST /api/tickets/:id/summarize` — generate and store summary |
| 4.8 | Build suggested replies endpoint | `GET /api/tickets/:id/suggestions` — return AI-generated reply options |
| 4.9 | Auto-classify on ticket creation | Hook classification into the ticket creation flow |
| 4.10 | Build AI UI components | "Classify" button, summary card, suggested reply chips on ticket detail page |
| 4.11 | Knowledge base CRUD API | `GET/POST/PATCH/DELETE /api/knowledge-base` — manage FAQ entries used as AI context |
| 4.12 | Knowledge base management page | Admin page to add/edit/delete knowledge base entries |

---

### Phase 5 — Email Integration

Receive inbound support emails and send outbound replies.

| # | Task | Details |
|---|------|---------|
| 5.1 | Set up Nodemailer | Configure SMTP transport for outbound emails |
| 5.2 | Build email service | `services/email.ts` — send templated replies to customers |
| 5.3 | Build email templates | HTML templates for: new ticket acknowledgment, agent reply |
| 5.4 | Set up IMAP client | Install `imapflow`, configure mailbox credentials |
| 5.5 | Build inbound email poller | Poll inbox every N seconds, parse sender/subject/body |
| 5.6 | Implement ticket creation from email | Create ticket + first message when new email arrives |
| 5.7 | Implement thread matching | Match reply emails to existing tickets (via subject or `In-Reply-To` header) |
| 5.8 | Auto-classify + acknowledge | On new ticket from email: classify with AI, send acknowledgment email |
| 5.9 | Send reply as email | When agent replies in UI, also send the reply via email to customer |
| 5.10 | Email settings UI | Admin page to configure SMTP/IMAP settings |

---

### Phase 6 — Dashboard & Analytics

Build the main dashboard with ticket stats, charts, and agent performance metrics.

| # | Task | Details |
|---|------|---------|
| 6.1 | Build stats API endpoint | `GET /api/dashboard/stats` — open/resolved/closed counts, avg response time |
| 6.2 | Build category breakdown API | Tickets per category, trend over time |
| 6.3 | Build agent performance API | Tickets resolved per agent, avg resolution time |
| 6.4 | Build Dashboard page | Stat cards (total open, resolved today, avg response time) |
| 6.5 | Add charts | Category distribution (pie/donut), ticket volume over time (line/bar) |
| 6.6 | Add recent tickets widget | Last 5-10 tickets on the dashboard for quick access |
| 6.7 | Add agent leaderboard | Table of agents ranked by tickets resolved |

---

### Phase 7 — Polish, Testing & Deployment

Harden the system, add error handling, write tests, and deploy.

| # | Task | Details |
|---|------|---------|
| 7.1 | Global error handling | Express error middleware, React error boundaries |
| 7.2 | Input validation | Zod schemas for all API inputs |
| 7.3 | Rate limiting | Rate-limit auth and AI endpoints |
| 7.4 | Loading & empty states | Skeletons, spinners, "no tickets found" states |
| 7.5 | Toast notifications | Success/error toasts for user actions |
| 7.6 | Responsive design pass | Ensure all pages work on tablet and mobile |
| 7.7 | Write API tests | Jest/Vitest tests for critical endpoints (auth, tickets, AI) |
| 7.8 | Write component tests | React Testing Library tests for key components |
| 7.9 | Dockerize the app | Dockerfiles for client (nginx) and server (Node), update docker-compose |
| 7.10 | CI/CD pipeline | GitHub Actions: lint → test → build → deploy |
| 7.11 | Deploy to cloud | Deploy to Railway / Fly.io / AWS (as chosen) |
| 7.12 | Production env config | Secrets management, CORS, HTTPS, logging |

---

## Phase Summary

| Phase | Name | Key Deliverable | Tasks |
|-------|------|-----------------|-------|
| 1 | Scaffolding & Database | Running dev environment with DB schema | 9 |
| 2 | Auth & User Management | Login flow, admin can create agents | 10 |
| 3 | Ticket CRUD & Core UI | Full ticket management workflow | 10 |
| 4 | AI Integration | Classification, summaries, suggested replies | 12 |
| 5 | Email Integration | Receive & send support emails | 10 |
| 6 | Dashboard & Analytics | Stats, charts, agent performance | 7 |
| 7 | Polish & Deployment | Production-ready system | 12 |
| | | **Total** | **70** |

---

## Verification Plan

### Automated Tests
- `npm test` — API integration tests (auth flow, ticket CRUD, AI endpoints)
- `npm run test:client` — Component tests (login form, ticket list, detail page)
- `npx prisma migrate deploy` — Verify migrations run cleanly

### Manual Verification
- Create admin → create agent → login as agent → verify permissions
- Receive email → auto-create ticket → verify classification → reply → verify email sent
- Open dashboard → verify stats match actual ticket data
- Test all filters, sorting, and pagination on ticket list
- Verify AI classification accuracy across all 3 categories
- Test responsive layout on mobile viewport

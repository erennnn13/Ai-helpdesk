# AI-Based Ticketing System — Project Memory

## Project Overview

An AI-powered ticket management system that automatically classifies, responds to, and routes support tickets. It delivers faster, more personalized support while reducing agent workload.

### Core Features
- Receive support emails and create tickets
- AI-powered ticket classification (General / Technical / Refund)
- Auto-generate human-friendly responses using a knowledge base
- AI summaries of ticket threads
- AI suggested replies
- Ticket list with filtering, sorting, and detail view
- User management (Admin & Agent roles)
- Dashboard to view and manage all tickets

### Ticket Statuses
- `OPEN` → `RESOLVED` → `CLOSED`

### User Roles
- **ADMIN**: Deployed with the system. Can create and manage agents.
- **AGENT**: Created by admin. Can view and manage tickets.

---

## Tech Stack

### Frontend (`/client`)
| Technology       | Version | Purpose                          |
|------------------|---------|----------------------------------|
| React            | 19      | Component-based UI framework     |
| TypeScript       | ~6.0    | Type safety                      |
| Vite             | 8.x     | Build tool & dev server          |
| React Router     | 8.x     | Client-side routing              |
| Tailwind CSS     | 4.x     | Utility-first CSS (v4 with @tailwindcss/vite plugin) |
| Shadcn/ui        | latest  | UI Component Library (Zinc default theme) |
| React Hook Form  | 7.x     | Form state management            |
| Zod              | 3.x     | Schema validation                |
| TanStack Query   | 5.x     | Server state & data fetching     |
| Axios            | 1.x     | HTTP client (replaces fetch)     |

- Dev server runs on `http://localhost:5173`

### Backend (`/server`)
| Technology       | Version | Purpose                          |
|------------------|---------|----------------------------------|
| Bun              | latest  | JavaScript runtime (replaces Node.js) |
| Express.js       | 5.x     | REST API framework               |
| TypeScript       | ^5      | Type safety                      |
| Prisma           | 7.x     | ORM (with driver adapter pattern) |
| PostgreSQL       | 16      | Primary database (via Docker)    |
| better-auth      | 1.1.x   | Authentication framework (replaces express-session) |
| bcryptjs         | 3.x     | Password hashing (custom override for better-auth) |
| express-rate-limit | 7.x   | Global API rate limiting         |
| helmet           | 8.x     | Security HTTP headers            |

- API server runs on `http://localhost:3001`
- API routes are prefixed with `/api`

### Infrastructure
| Technology       | Purpose                          |
|------------------|----------------------------------|
| Docker Compose   | PostgreSQL + pgAdmin containers  |
| PostgreSQL 16    | `localhost:5432`, db: `helpdesk` (main), `helpdesk_test` (e2e), user: `postgres` |
| pgAdmin          | `localhost:5050`, login: `admin@admin.com` / `admin` |

### Testing
- **Component Tests (Vitest & RTL)**: Rely mostly on component tests. Use them for all UI variations, edge cases, error states, and form validations.
- **E2E Tests (Playwright)**: Only use E2E tests when absolutely necessary. Keep them restricted strictly to core critical user journeys (e.g. login, full ticket flow) to avoid test flake and slow execution times.

---

## Important: Prisma v7 Configuration

Prisma v7 introduced breaking changes:

1. **No `url` in `schema.prisma` datasource block** — The `url` property is no longer allowed when using `prisma.config.ts`.
2. **`prisma.config.ts`** handles CLI operations (migrate, generate) and reads `DATABASE_URL` from `.env`.
3. **Runtime requires a driver adapter** — `PrismaClient` must be instantiated with an `adapter` (e.g., `@prisma/adapter-pg`) or `accelerateUrl`.
4. **`datasourceUrl` removed from constructor** — Cannot pass `datasourceUrl` to `new PrismaClient()`.

### Current Prisma setup (`/server/src/lib/prisma.ts`):
```typescript
import "dotenv/config";
import { PrismaClient } from "@prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";
import pg from "pg";

const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool);
export const prisma = new PrismaClient({ adapter });
```

---

## Project Structure

```
├── client/                  # Frontend (React + Vite)
│   ├── src/
│   │   ├── components/      # Reusable UI components
│   │   ├── context/         # React context (AuthContext)
│   │   ├── pages/           # Page components (Login, Dashboard, Tickets)
│   │   ├── App.tsx          # Root app component
│   │   ├── main.tsx         # Entry point
│   │   └── index.css        # Global styles (Tailwind)
│   └── package.json
│
├── server/                  # Backend (Bun + Express)
│   ├── src/
│   │   ├── lib/             # Shared utilities (prisma.ts)
│   │   ├── middleware/      # Express middleware (error handler)
│   │   ├── routes/          # API route handlers (auth, users, tickets)
│   │   └── index.ts         # Server entry point
│   ├── prisma/
│   │   ├── schema.prisma    # Database schema
│   │   └── seed.ts          # Database seed script
│   ├── prisma.config.ts     # Prisma v7 configuration
│   ├── .env                 # Environment variables
│   └── package.json
│
├── docker-compose.yml       # PostgreSQL + pgAdmin
├── project.md               # Project requirements
├── tech-stack.md            # Technology decisions
└── claude.md                # This file — AI project memory
```

---

## API Endpoints

| Method | Route                   | Purpose              |
|--------|-------------------------|----------------------|
| GET    | `/api/health`           | Health check         |
| POST   | `/api/auth/sign-in`     | User login (better-auth) |
| POST   | `/api/auth/sign-out`    | User logout (better-auth) |
| GET    | `/api/auth/get-session` | Get current session (better-auth) |
| GET    | `/api/users`       | List users           |
| GET    | `/api/tickets`     | List tickets         |
| GET    | `/api/tickets/:id` | Get ticket detail    |

---

## Commands

### Client
```bash
cd client
npm run dev          # Start dev server (localhost:5173)
npm run build        # Production build
```

### Testing (Root)
```bash
npm run db:setup:test  # Resets test DB, runs migrations, and seeds test DB
npm run test:e2e       # Runs Playwright E2E tests
```

### Server
```bash
cd server
bun run dev          # Start dev server with watch (localhost:3001)
bun prisma generate  # Regenerate Prisma client
bun prisma migrate dev  # Run database migrations
bun prisma db push   # Push schema to database
bun run prisma/seed.ts  # Seed database
bun prisma studio    # Open Prisma Studio
```

### Docker
```bash
docker compose up -d    # Start PostgreSQL + pgAdmin
docker compose down     # Stop containers
```

---

## Context7 — Up-to-date Documentation

When working with any library in this project, use the **Context7 MCP server** to fetch current documentation instead of relying on training data. This is especially important for rapidly evolving libraries like Prisma, React, and Tailwind CSS.

### How to use Context7

**Step 1: Resolve the library ID**
```
Tool: context7 → resolve-library-id
Args: { "libraryName": "Prisma", "query": "how to use driver adapters" }
```

**Step 2: Query documentation with the resolved ID**
```
Tool: context7 → query-docs
Args: { "libraryId": "/prisma/prisma", "query": "driver adapter setup for PostgreSQL" }
```

### When to use Context7
- ✅ API syntax, configuration, version migration
- ✅ Library-specific debugging and setup
- ✅ CLI tool usage and options
- ✅ Any question about React, Express, Prisma, Tailwind, etc.
- ❌ Refactoring, writing scripts from scratch, debugging business logic

### Key Library IDs (resolve first if unsure)
| Library        | Likely ID (verify with resolve-library-id) |
|----------------|-------------------------------------------|
| React          | `/facebook/react`                         |
| Prisma         | `/prisma/prisma`                          |
| Express.js     | `/expressjs/express`                      |
| Tailwind CSS   | `/tailwindlabs/tailwindcss`               |
| React Router   | `/remix-run/react-router`                 |
| Vite           | `/vitejs/vite`                            |

> **Rule**: Always use Context7 before answering questions about library APIs or configuration. Training data may be outdated, especially for Prisma v7, Tailwind v4, React 19, and Express v5.

---

## Known Issues & Gotchas

1. **PowerShell execution policy** — `npm` commands fail in PowerShell. Use `cmd /c "npm run dev"` as a workaround. (We now use `bun run` mostly to bypass this).
2. **Prisma v7 breaking changes** — See the Prisma section above. Never use `datasourceUrl` in constructor or `url` in schema when `prisma.config.ts` exists.
3. **dotenv loading order** — `prisma.ts` imports `dotenv/config` at the top because it's imported before `dotenv.config()` runs in `index.ts`.
4. **Docker required** — PostgreSQL must be running via `docker compose up -d` before starting the server.
5. **Better Auth with bcryptjs** — Better Auth requires explicit `hash` and `verify` overrides in its configuration to support bcryptjs-hashed passwords from seed data, avoiding "Invalid password hash" errors.
6. **Role-Based Access Control (RBAC)** — The custom Prisma `Role` enum is exposed to the frontend session by using `additionalFields: { role: { type: "string" } }` in the better-auth server config. The frontend `Session` type in `auth-client.ts` manually extends this to prevent TypeScript errors. 
7. **Database Seeding** — The database seed script (`bun run prisma/seed.ts`) deterministically upserts `admin@example.com` (`ADMIN`) and `agent@example.com` (`AGENT`) for testing role-based UI flows (like the restricted `/users` page).
8. **Rate Limiting** — Both `express-rate-limit` and `better-auth` rate limiting are conditionally enabled *only* in production (`NODE_ENV === "production"`) to avoid blocking local E2E tests and development.
9. **Test Database & Prisma CLI** — Prisma CLI defaults to `.env` even if `NODE_ENV=test` is passed. Always use `npx dotenv -e .env.test -- bun prisma ...` when executing CLI commands against the `helpdesk_test` database.
10. **Prisma Migrations vs DB Push** — When migrating schemas that add native Enums, always generate a migration (`prisma migrate dev`). Bypassing migrations using `db push` causes downstream resets (`prisma migrate reset`) to fail when recreating the database structure.

---

## Recent UI & Architecture Updates (Session Memory)

1. **Brand Update:** The application has been rebranded from "Ticket AI" to **"Helpdesk"** across all UI elements and metadata.
2. **Data Fetching:** Successfully migrated all frontend data fetching from native `fetch` + `useEffect` to **Axios** and **@tanstack/react-query**. This provides built-in caching, revalidation, and loading states.
3. **Shadcn Integration:** Completely refactored `DashboardPage`, `TicketListPage`, `TicketDetailPage`, and `Users` pages to use Shadcn UI components (Cards, Tables, Badges, Buttons, Textareas).
4. **Premium Aesthetics:** 
   - Applied a premium glassmorphic feel to the layout (`bg-background/50 backdrop-blur-3xl`) with ambient background blurs matching the login page.
   - Integrated **Dicebear API** for dynamic avatars. Admin users use the `micah` style (configured with light skin tones), while Agent avatars are intentionally hidden to keep their profile section minimal.
5. **Loading States:** Replaced all text-based loading messages with smooth, animated **Shadcn Skeleton** loaders across the Dashboard, Ticket List, Ticket Detail, and Users pages to match the premium aesthetic.
6. **Frontend Testing Suite:**
   - Initialized testing environment using **Vitest**, **React Testing Library**, `jsdom`, and `@testing-library/user-event`.
   - Extracted testing utilities (including `renderWithProviders` with a mock QueryClient and MemoryRouter) into a reusable `test-utils.tsx` module.
   - Wrote comprehensive component tests for the `Users.tsx` page (verifying loading states, API fetches, modal interactions, and form submissions). All tests pass.
7. **User Management Refactor & Zod Validation:**
   - Extracted the User list table to a standalone `UserTable.tsx` component.
   - Refactored `CreateUserForm` to `UserForm` to dynamically handle both User Creation and User Editing. Implemented conditional password validation (required for creation, optional/omitted for edit updates) via a new `updateUserSchema` in the shared `core` package.
   - Removed the generic `USER` role from the frontend options since the system is exclusively for internal `AGENT` and `ADMIN` roles.
   - Consolidated multiple `<Dialog>` instances in `Users.tsx` into a single, clean state (`dialogConfig`) mapping to a single modal.
   - DRY'd up Zod validation in the Express backend by extracting a generic `validate.middleware.ts` which automatically parses the body and passes the typed payload to controllers, removing duplicate parsing logic across endpoints.
8. **Email-to-Ticket Ingestion:**
   - Implemented an IMAP email poller (`node-imap`) to continuously listen for incoming emails at the support address and auto-convert them into Tickets.
   - Ensured the sender name is required when creating tickets from emails.
9. **E2E Testing Suite (Playwright):**
   - Developed a comprehensive and resilient E2E test suite covering Auth, Dashboard, Tickets, Users, and Edge Cases.
   - Implemented state-independent test strategies (e.g., actively patching tickets to `OPEN` before testing reply behaviors) to solve database state leakage across test runs.
   - Replaced fragile assertions with reliable `waitForURL`, `waitForLoadState('networkidle')`, and explicit network interception (`waitForResponse`).
10. **Database & Type Architecture:**
    - Refactored `Ticket` ID generation from `UUID` to auto-incrementing `Int`.
    - Made `category` on Tickets completely optional (nullable) without default values.
    - Updated shared models in `core/src/schemas/ticket.ts` to export standard TypeScript union types (`TicketStatus`, `TicketCategory`, `MessageSender`) instead of Enums, utilizing `import type` where appropriate to adhere to `verbatimModuleSyntax`.

import express from "express";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import { toNodeHandler } from "better-auth/node";
import { fileURLToPath } from "url";
import path from "path";
import dotenv from "dotenv";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
dotenv.config({
  path: process.env.NODE_ENV === "test"
    ? path.join(__dirname, "../.env.test")
    : path.join(__dirname, "../.env"),
  override: true
});

import { auth } from "./lib/auth";
import { initSentry, Sentry } from "./lib/sentry";
import { userRouter } from "./routes/user.routes";
import { ticketRouter } from "./routes/ticket.routes";
import { webhookRouter } from "./routes/webhook.routes";
import { errorHandler } from "./middleware/error.middleware";
import { startClassifyWorker } from "./workers/classify.worker";
import { startAutoResolveWorker } from "./workers/autoresolve.worker";

// ─── Sentry (must be initialized before express app) ────
initSentry();

const app = express();
app.set("trust proxy", 1); // Trust first proxy (NGINX) to allow express-rate-limit to read X-Forwarded-For
const PORT = process.env.PORT || 3001;

// ─── Security Headers ───────────────────────────────────
app.use(helmet());

// ─── CORS ───────────────────────────────────────────────

app.use(
  cors({
    origin: process.env.CLIENT_URL || "http://localhost:5173",
    credentials: true,
  })
);

// ─── Better Auth Handler ────────────────────────────────
// Must be mounted BEFORE express.json() middleware

app.all("/api/auth/{*splat}", toNodeHandler(auth));

// ─── Body Parsing ───────────────────────────────────────

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ─── Rate Limiting ──────────────────────────────────────

if (process.env.NODE_ENV === "production") {
  const apiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per `window` (here, per 15 minutes)
    standardHeaders: true,
    legacyHeaders: false,
  });

  app.use("/api", apiLimiter);
}

// ─── Routes ─────────────────────────────────────────────

app.get("/api/health", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

app.use("/api/users", userRouter);
app.use("/api/tickets", ticketRouter);
app.use("/api/webhooks", webhookRouter);



// ─── Error Handling ─────────────────────────────────────

// Sentry error handler must come BEFORE our own errorHandler
Sentry.setupExpressErrorHandler(app);
app.use(errorHandler);

// ─── Start Server ───────────────────────────────────────

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📋 Health check: http://localhost:${PORT}/api/health`);
  console.log(`🔐 Auth check: http://localhost:${PORT}/api/auth/ok`);

  // Start pg-boss worker for background ticket classification & KB auto-resolution
  startClassifyWorker().catch((err) => {
    console.error("❌ Failed to start classify worker:", err);
  });
  startAutoResolveWorker().catch((err) => {
    console.error("❌ Failed to start auto-resolve worker:", err);
  });
});

export default app;

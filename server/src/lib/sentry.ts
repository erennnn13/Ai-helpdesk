import * as Sentry from "@sentry/node";

const DSN = process.env.SENTRY_DSN;

/**
 * Initialize Sentry. Safe to call even if SENTRY_DSN is not set —
 * Sentry will be a no-op in that case.
 */
export function initSentry(): void {
  if (!DSN) {
    console.log("ℹ️  [Sentry] SENTRY_DSN not set — error tracking disabled.");
    return;
  }

  Sentry.init({
    dsn: DSN,
    environment: process.env.NODE_ENV || "development",
    // Capture 100% of transactions in dev, tune down in production
    tracesSampleRate: process.env.NODE_ENV === "production" ? 0.2 : 1.0,
    // Capture all unhandled promise rejections
    integrations: [Sentry.captureConsoleIntegration({ levels: ["error"] })],
  });

  console.log(`✅ [Sentry] Initialized (env: ${process.env.NODE_ENV || "development"})`);
}

/**
 * Manually report an error to Sentry with optional extra context.
 */
export function captureError(
  err: unknown,
  context?: Record<string, unknown>
): void {
  if (!DSN) return;
  Sentry.withScope((scope) => {
    if (context) {
      scope.setExtras(context);
    }
    Sentry.captureException(err);
  });
}

export { Sentry };

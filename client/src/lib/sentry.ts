import * as Sentry from "@sentry/react";

const DSN = import.meta.env.VITE_SENTRY_DSN as string | undefined;
const ENV = import.meta.env.VITE_SENTRY_ENVIRONMENT as string | undefined;

/**
 * Initialize Sentry for the React client.
 * Safe no-op when VITE_SENTRY_DSN is not set.
 */
export function initSentry(): void {
  if (!DSN) {
    console.log("ℹ️  [Sentry] VITE_SENTRY_DSN not set — client error tracking disabled.");
    return;
  }

  Sentry.init({
    dsn: DSN,
    environment: ENV || import.meta.env.MODE || "development",
    // Capture 100% of sessions in dev, reduce in production
    tracesSampleRate: import.meta.env.PROD ? 0.2 : 1.0,
    // Replay 10% of sessions, 100% on error
    replaysSessionSampleRate: 0.1,
    replaysOnErrorSampleRate: 1.0,
    integrations: [
      Sentry.browserTracingIntegration(),
      Sentry.replayIntegration(),
    ],
  });
}

export { Sentry };

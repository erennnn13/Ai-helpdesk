import type { Request, Response, NextFunction } from "express";
import { captureError } from "../lib/sentry";

export interface AppError extends Error {
  status?: number;
}

export function errorHandler(
  err: AppError,
  req: Request,
  res: Response,
  _next: NextFunction
): void {
  const status = err.status || 500;

  // Report server errors (5xx) to Sentry with request context
  if (status >= 500) {
    captureError(err, {
      method: req.method,
      url: req.originalUrl,
      status,
    });
  }

  console.error(`[ERROR] ${err.message}`, err.stack);

  const message =
    process.env.NODE_ENV === "production" && status === 500
      ? "Internal Server Error"
      : err.message;

  res.status(status).json({
    error: {
      message,
      status,
    },
  });
}

export function createError(message: string, status: number): AppError {
  const error = new Error(message) as AppError;
  error.status = status;
  return error;
}

import type { Request, Response, NextFunction } from "express";
import { Role } from "@prisma/client";
import { auth } from "../lib/auth";
import { prisma } from "../lib/prisma";
import { fromNodeHeaders } from "better-auth/node";
import { createError } from "./error.middleware";

/**
 * Middleware: Require authenticated session (Better Auth)
 *
 * Fetches the session from Better Auth using the request headers,
 * then attaches `session` and `user` to `res.locals` for downstream use.
 */
export async function requireAuth(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const session = await auth.api.getSession({
      headers: fromNodeHeaders(req.headers),
    });

    if (!session) {
      return next(createError("Authentication required", 401));
    }

    // Verify user is active and not soft-deleted
    const dbUser = await prisma.user.findUnique({
      where: { id: session.user.id },
      select: { deletedAt: true },
    });

    if (!dbUser || dbUser.deletedAt) {
      return next(createError("Account has been deactivated", 401));
    }

    res.locals.session = session.session;
    res.locals.user = session.user;
    next();
  } catch (error) {
    next(error);
  }
}

/**
 * Middleware: Require ADMIN role
 * Must be used after requireAuth
 */
export function requireAdmin(
  _req: Request,
  res: Response,
  next: NextFunction
): void {
  if (res.locals.user?.role !== Role.ADMIN) {
    return next(createError("Admin access required", 403));
  }
  next();
}

import { ZodError, type ZodSchema } from "zod";
import type { Request, Response, NextFunction } from "express";
import { createError } from "./error.middleware";

export function validate(schema: ZodSchema) {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      req.body = schema.parse(req.body);
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        return next(createError(error.issues[0]?.message || "Validation failed", 400));
      }
      next(error);
    }
  };
}

export function validateQuery(schema: ZodSchema) {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      const parsed = schema.parse(req.query);
      // Store parsed values in res.locals — req.query is readonly in Express 5
      res.locals.query = parsed;
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        return next(createError(error.issues[0]?.message || "Query validation failed", 400));
      }
      next(error);
    }
  };
}

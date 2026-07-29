import { Router } from "express";
import { handlePostmarkInbound } from "../controllers/webhook.controller";

export const webhookRouter = Router();

// POST /api/webhooks/postmark
webhookRouter.post("/postmark", handlePostmarkInbound);

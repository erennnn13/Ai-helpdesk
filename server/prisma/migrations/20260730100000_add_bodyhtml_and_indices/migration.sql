-- AlterTable
ALTER TABLE "message" ADD COLUMN "bodyHtml" TEXT;

-- CreateIndex
CREATE INDEX "ticket_status_idx" ON "ticket"("status");

-- CreateIndex
CREATE INDEX "ticket_createdAt_idx" ON "ticket"("createdAt");

-- CreateIndex
CREATE INDEX "ticket_status_createdAt_idx" ON "ticket"("status", "createdAt");

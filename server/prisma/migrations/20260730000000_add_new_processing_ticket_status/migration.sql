-- AlterEnum: Add 'NEW' and 'PROCESSING' values to TicketStatus
-- These were missing from the original migration but present in schema.prisma

ALTER TYPE "TicketStatus" ADD VALUE IF NOT EXISTS 'NEW';
ALTER TYPE "TicketStatus" ADD VALUE IF NOT EXISTS 'PROCESSING';

-- AlterTable: Update default value from 'OPEN' to 'NEW'
ALTER TABLE "Ticket" ALTER COLUMN "status" SET DEFAULT 'NEW';

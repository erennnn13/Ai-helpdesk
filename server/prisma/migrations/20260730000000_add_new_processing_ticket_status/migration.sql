-- AlterEnum: Add 'NEW' and 'PROCESSING' to TicketStatus
-- Uses create-new-enum + swap approach (safe inside transactions)

-- 1. Create new enum with all values
CREATE TYPE "TicketStatus_new" AS ENUM ('NEW', 'PROCESSING', 'OPEN', 'RESOLVED', 'CLOSED');

-- 2. Drop the column default (it references the old enum type)
ALTER TABLE "Ticket" ALTER COLUMN "status" DROP DEFAULT;

-- 3. Swap the column type to the new enum
ALTER TABLE "Ticket"
  ALTER COLUMN "status" TYPE "TicketStatus_new"
  USING ("status"::text::"TicketStatus_new");

-- 4. Drop the old enum and rename the new one
DROP TYPE "TicketStatus";
ALTER TYPE "TicketStatus_new" RENAME TO "TicketStatus";

-- 5. Restore the default to 'NEW'
ALTER TABLE "Ticket" ALTER COLUMN "status" SET DEFAULT 'NEW';

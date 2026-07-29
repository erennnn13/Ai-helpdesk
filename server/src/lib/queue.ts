import { PgBoss } from "pg-boss";

/**
 * The queue name used for ticket classification jobs.
 */
export const CLASSIFY_QUEUE = "ticket-classify";

/**
 * Job payload shape for classify jobs.
 */
export interface ClassifyJobData {
  ticketId: number;
}

let boss: PgBoss | null = null;

/**
 * Returns the singleton pg-boss instance, creating and starting it if needed.
 * Uses the same DATABASE_URL as Prisma so no extra connection config is needed.
 */
export async function getQueue(): Promise<PgBoss> {
  if (boss) return boss;

  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    throw new Error("DATABASE_URL environment variable is not set.");
  }

  boss = new PgBoss({
    connectionString,
    // Maintenance runs every minute
    maintenanceIntervalSeconds: 60,
  });

  boss.on("error", (err) => {
    console.error("❌ [pg-boss] Internal error:", err);
  });

  await boss.start();
  await boss.createQueue(CLASSIFY_QUEUE).catch(() => {});
  await boss.createQueue(AUTO_RESOLVE_QUEUE).catch(() => {});
  console.log("✅ [pg-boss] Queue started.");

  return boss;
}

/**
 * Enqueues a ticket classification job.
 * Jobs are deduplicated by ticketId — if a job for the same ticket is already
 * queued or running, a new duplicate will NOT be inserted.
 *
 * pg-boss retry policy:
 *  - retryLimit: 3   → retried up to 3 times on failure
 *  - retryDelay: 60  → 60-second back-off between retries
 *  - expireInSeconds → job fails if not started within 5 minutes
 */
export async function enqueueClassifyJob(ticketId: number): Promise<void> {
  try {
    const queue = await getQueue();
    const jobId = await queue.send(
      CLASSIFY_QUEUE,
      { ticketId } satisfies ClassifyJobData,
      {
        // Dedup: one pending/active job per ticket at a time
        singletonKey: `ticket-${ticketId}`,
        retryLimit: 3,
        retryDelay: 60,
        expireInSeconds: 300,
      }
    );
    if (jobId) {
      console.log(`📬 [pg-boss] Enqueued classify job for ticket #${ticketId} (job: ${jobId})`);
    } else {
      console.log(`ℹ️ [pg-boss] Classify job for ticket #${ticketId} already queued — skipped duplicate.`);
    }
  } catch (err) {
    // Log but never throw — classification failure must not crash request handlers
    console.error(`❌ [pg-boss] Failed to enqueue classify job for ticket #${ticketId}:`, err);
  }
}

/**
 * Queue name used for ticket auto-resolution jobs.
 */
export const AUTO_RESOLVE_QUEUE = "ticket-autoresolve";

/**
 * Enqueues a KB ticket auto-resolution job.
 */
export async function enqueueAutoResolveJob(ticketId: number): Promise<void> {
  try {
    const queue = await getQueue();
    const jobId = await queue.send(
      AUTO_RESOLVE_QUEUE,
      { ticketId } satisfies ClassifyJobData,
      {
        singletonKey: `autoresolve-ticket-${ticketId}`,
        retryLimit: 2,
        retryDelay: 30,
        expireInSeconds: 300,
      }
    );
    if (jobId) {
      console.log(`📬 [pg-boss] Enqueued auto-resolve job for ticket #${ticketId} (job: ${jobId})`);
    } else {
      console.log(`ℹ️ [pg-boss] Auto-resolve job for ticket #${ticketId} already queued — skipped duplicate.`);
    }
  } catch (err) {
    console.error(`❌ [pg-boss] Failed to enqueue auto-resolve job for ticket #${ticketId}:`, err);
  }
}

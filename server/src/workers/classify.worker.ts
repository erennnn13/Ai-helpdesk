import { getQueue, CLASSIFY_QUEUE, type ClassifyJobData } from "../lib/queue";
import { classifyTicketHelper } from "../controllers/ai.controller";

/**
 * Starts the pg-boss worker that processes ticket:classify jobs.
 *
 * Worker settings:
 *  - teamSize: 2   → process up to 2 jobs concurrently
 *  - teamConcurrency: 2 → same concurrency limit for the work callback
 *  - pollingIntervalSeconds: 5 → check for new jobs every 5 seconds
 *
 * Each job payload is { ticketId: number }. On failure pg-boss will retry
 * automatically according to the retryLimit / retryDelay set when the job
 * was enqueued (see lib/queue.ts).
 */
export async function startClassifyWorker(): Promise<void> {
  const queue = await getQueue();
  await queue.createQueue(CLASSIFY_QUEUE).catch(() => {});

  await queue.work<ClassifyJobData>(
    CLASSIFY_QUEUE,
    {
      localConcurrency: 2,
      pollingIntervalSeconds: 5,
    },
    async (jobs) => {
      for (const job of jobs) {
        const { ticketId } = job.data;
        console.log(`⚙️  [Classify Worker] Processing job ${job.id} — ticket #${ticketId}`);

        const category = await classifyTicketHelper(ticketId);

        if (!category) {
          // Throw so pg-boss marks the job as failed and retries it
          throw new Error(`Classification returned null for ticket #${ticketId}`);
        }

        console.log(`✅ [Classify Worker] Job ${job.id} complete — ticket #${ticketId} → ${category}`);
      }
    }
  );

  console.log(`👷 [Classify Worker] Listening on queue "${CLASSIFY_QUEUE}"`);
}

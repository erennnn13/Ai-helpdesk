import { getQueue, AUTO_RESOLVE_QUEUE, type ClassifyJobData } from "../lib/queue";
import { processTicketAutoResolution } from "../lib/kb-solver.lib";

/**
 * Starts the pg-boss worker that processes ticket:autoresolve jobs.
 */
export async function startAutoResolveWorker(): Promise<void> {
  const queue = await getQueue();
  await queue.createQueue(AUTO_RESOLVE_QUEUE).catch(() => {});

  await queue.work<ClassifyJobData>(
    AUTO_RESOLVE_QUEUE,
    {
      localConcurrency: 2,
      pollingIntervalSeconds: 5,
    },
    async (jobs) => {
      for (const job of jobs) {
        const { ticketId } = job.data;
        console.log(`⚙️  [AutoResolve Worker] Processing job ${job.id} — ticket #${ticketId}`);

        try {
          const finalStatus = await processTicketAutoResolution(ticketId);
          console.log(`✅ [AutoResolve Worker] Job ${job.id} finished — ticket #${ticketId} status → ${finalStatus}`);
        } catch (err) {
          console.error(`❌ [AutoResolve Worker] Exception generated during job ${job.id} for ticket #${ticketId}:`, err);
          const { prisma } = await import("../lib/prisma");
          const { TicketStatus } = await import("@prisma/client");
          await prisma.ticket.update({
            where: { id: ticketId },
            data: { status: TicketStatus.OPEN },
          }).catch(() => {});
        }
      }
    }
  );

  console.log(`👷 [AutoResolve Worker] Listening on queue "${AUTO_RESOLVE_QUEUE}"`);
}

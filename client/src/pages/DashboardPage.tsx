import { useNavigate } from "react-router";
import { useQuery } from "@tanstack/react-query";
import { api } from "../services/api";
import type { Ticket } from "../types";
import { Skeleton } from "@/components/ui/skeleton";
import { ArrowRight, Ticket as TicketIcon, CheckCircle2, Circle, Lock, Bot, TrendingUp } from "lucide-react";
import { PieChart, type PieChartSegment } from "@/components/PieChart";

interface TicketStats {
  open: number;
  resolved: number;
  closed: number;
  total: number;
  aiResolved?: number;
}

const statusConfig: Record<string, { label: string; className: string }> = {
  OPEN: { label: "Open", className: "badge-open" },
  RESOLVED: { label: "Resolved", className: "badge-resolved" },
  CLOSED: { label: "Closed", className: "badge-closed" },
};

export default function DashboardPage() {
  const navigate = useNavigate();

  const { data: statsData, isLoading: loadingStats } = useQuery({
    queryKey: ["tickets", "stats"],
    queryFn: () => api.get<{ stats: TicketStats }>("/tickets/stats"),
  });

  const { data: recentData, isLoading: loadingRecent } = useQuery({
    queryKey: ["tickets", "recent"],
    queryFn: () =>
      api.get<{ tickets: Ticket[] }>(
        "/tickets?limit=5&sortBy=createdAt&sortOrder=desc"
      ),
  });

  const stats = statsData?.stats ?? { open: 0, resolved: 0, closed: 0, total: 0, aiResolved: 0 };
  const recentTickets = recentData?.tickets || [];
  const loading = loadingStats || loadingRecent;

  const aiResolvedCount = stats.aiResolved ?? 0;
  const humanResolvedCount = Math.max(0, stats.resolved - aiResolvedCount);

  const statCards = [
    { label: "Total", value: stats.total, icon: TicketIcon, accent: "#4F46E5", bg: "#EEF2FF", path: "/tickets" },
    { label: "Open", value: stats.open, icon: Circle, accent: "#059669", bg: "#ECFDF5", path: "/tickets?status=OPEN" },
    { label: "Resolved", value: stats.resolved, icon: CheckCircle2, accent: "#2563EB", bg: "#EFF6FF", path: "/tickets?status=RESOLVED" },
    { label: "AI Resolved", value: aiResolvedCount, icon: Bot, accent: "#7C3AED", bg: "#F5F3FF", path: "/tickets?status=RESOLVED&aiResolved=true" },
    { label: "Closed", value: stats.closed, icon: Lock, accent: "#6B7280", bg: "#F3F4F6", path: "/tickets?status=CLOSED" },
  ];

  const pieSegments: PieChartSegment[] = [
    { label: "Open", value: stats.open, color: "#4F46E5" },
    { label: "Resolved (Human)", value: humanResolvedCount, color: "#059669" },
    { label: "Resolved by AI", value: aiResolvedCount, color: "#7C3AED" },
    { label: "Closed", value: stats.closed, color: "#9CA3AF" },
  ];

  const aiPct = stats.total > 0 ? Math.round((aiResolvedCount / stats.total) * 100) : 0;

  if (loading) {
    return (
      <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
        <div>
          <Skeleton className="h-10 w-56 mb-2" style={{ background: "#E7E5E0" }} />
          <Skeleton className="h-5 w-72" style={{ background: "#E7E5E0" }} />
        </div>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(5, 1fr)", gap: 14 }}>
          {[...Array(5)].map((_, i) => (
            <Skeleton key={i} className="h-28 w-full rounded-xl" style={{ background: "#E7E5E0" }} />
          ))}
        </div>
        <div style={{ display: "grid", gridTemplateColumns: "5fr 7fr", gap: 20 }}>
          <Skeleton className="h-80 w-full rounded-xl" style={{ background: "#E7E5E0" }} />
          <Skeleton className="h-80 w-full rounded-xl" style={{ background: "#E7E5E0" }} />
        </div>
      </div>
    );
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 28 }}>

      {/* ── Page header ── */}
      <div>
        <h1 style={{
          fontFamily: "'Fraunces', Georgia, serif",
          fontSize: 34,
          fontWeight: 700,
          letterSpacing: "-0.02em",
          color: "#1C1917",
          lineHeight: 1.15,
          marginBottom: 6,
        }}>
          Dashboard
        </h1>
        <p style={{ fontSize: 14, color: "#78716C" }}>
          Your support queue, at a glance.
        </p>
      </div>

      {/* ── Stat cards ── */}
      <div style={{ display: "grid", gridTemplateColumns: "repeat(5, 1fr)", gap: 14 }}>
        {statCards.map((card) => (
          <div
            key={card.label}
            className="card-lift"
            onClick={() => navigate(card.path)}
            style={{
              background: "#FFFFFF",
              border: "1px solid #E7E5E0",
              borderRadius: 14,
              padding: "18px 20px",
              display: "flex",
              flexDirection: "column",
              gap: 12,
              cursor: "pointer",
            }}
          >
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
              <span style={{ fontSize: 12.5, fontWeight: 600, color: "#78716C" }}>{card.label}</span>
              <div style={{
                width: 30, height: 30, borderRadius: 8,
                background: card.bg,
                display: "flex", alignItems: "center", justifyContent: "center",
              }}>
                <card.icon style={{ width: 14, height: 14, color: card.accent }} />
              </div>
            </div>
            <div className="stat-value">{card.value}</div>
          </div>
        ))}
      </div>

      {/* ── AI Insight banner ── */}
      {aiPct > 0 && (
        <div
          onClick={() => navigate("/tickets?status=RESOLVED&aiResolved=true")}
          style={{
            background: "#F5F3FF",
            border: "1px solid #DDD6FE",
            borderRadius: 12,
            padding: "14px 20px",
            display: "flex",
            alignItems: "center",
            gap: 12,
            cursor: "pointer",
          }}
        >
          <div style={{
            width: 34, height: 34, borderRadius: 8,
            background: "#EDE9FE",
            display: "flex", alignItems: "center", justifyContent: "center",
            flexShrink: 0,
          }}>
            <TrendingUp style={{ width: 16, height: 16, color: "#7C3AED" }} />
          </div>
          <div>
            <span style={{ fontSize: 13.5, fontWeight: 600, color: "#5B21B6" }}>
              AI resolved {aiPct}% of all tickets
            </span>
            <span style={{ fontSize: 13, color: "#7C3AED", marginLeft: 6 }}>
              — {aiResolvedCount} of {stats.total} total, freeing your team to focus on complex cases.
            </span>
          </div>
        </div>
      )}

      {/* ── Charts + Recent tickets ── */}
      <div style={{ display: "grid", gridTemplateColumns: "5fr 7fr", gap: 20, alignItems: "start" }}>

        {/* Pie chart card */}
        <div style={{
          background: "#FFFFFF",
          border: "1px solid #E7E5E0",
          borderRadius: 16,
          overflow: "hidden",
        }}>
          <div style={{
            padding: "18px 22px",
            borderBottom: "1px solid #E7E5E0",
            display: "flex", alignItems: "center", justifyContent: "space-between",
          }}>
            <span style={{ fontSize: 14, fontWeight: 600, color: "#1C1917" }}>Ticket Breakdown</span>
          </div>
          <div style={{ padding: "24px 22px", display: "flex", justifyContent: "center" }}>
            <PieChart
              data={pieSegments}
              size={170}
              strokeWidth={22}
              centerLabel="Total"
              centerValue={stats.total}
            />
          </div>
        </div>

        {/* Recent tickets card */}
        <div style={{
          background: "#FFFFFF",
          border: "1px solid #E7E5E0",
          borderRadius: 16,
          overflow: "hidden",
        }}>
          <div style={{
            padding: "18px 22px",
            borderBottom: "1px solid #E7E5E0",
            display: "flex", alignItems: "center", justifyContent: "space-between",
          }}>
            <span style={{ fontSize: 14, fontWeight: 600, color: "#1C1917" }}>Recent Tickets</span>
            <button
              onClick={() => navigate("/tickets")}
              style={{
                display: "flex", alignItems: "center", gap: 4,
                background: "transparent", border: "none", cursor: "pointer",
                color: "#4F46E5", fontSize: 12.5, fontWeight: 600,
                padding: "4px 0",
                fontFamily: "'Instrument Sans Variable', sans-serif",
              }}
            >
              View all <ArrowRight style={{ width: 13, height: 13 }} />
            </button>
          </div>

          {recentTickets.length === 0 ? (
            <div style={{ padding: "40px 22px", textAlign: "center", fontSize: 13, color: "#A8A29E" }}>
              No tickets yet
            </div>
          ) : (
            <div>
              {recentTickets.slice(0, 5).map((ticket, idx) => {
                const statusRowClass = ticket.status === "OPEN"
                  ? "ticket-row-open"
                  : ticket.status === "RESOLVED"
                  ? "ticket-row-resolved"
                  : "ticket-row-closed";

                const badgeCfg = statusConfig[ticket.status] ?? { label: ticket.status, className: "badge-closed" };

                return (
                  <div
                    key={ticket.id}
                    className={`${statusRowClass} ${idx % 2 === 0 ? "ticket-row-even" : "ticket-row-odd"}`}
                    onClick={() => navigate(`/tickets/${ticket.id}`)}
                    style={{
                      padding: "12px 20px",
                      cursor: "pointer",
                      display: "flex",
                      alignItems: "center",
                      gap: 12,
                      transition: "background 0.12s ease",
                    }}
                  >
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <p style={{ fontSize: 13.5, fontWeight: 500, color: "#1C1917", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", marginBottom: 3 }}>
                        {ticket.subject}
                      </p>
                      <p style={{ fontSize: 11.5, color: "#A8A29E", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                        {ticket.customerName} · {ticket.customerEmail}
                      </p>
                    </div>
                    {ticket.category && (
                      <span style={{
                        fontSize: 10.5, fontWeight: 500,
                        background: "#F0EEE9", color: "#78716C",
                        border: "1px solid #E7E5E0",
                        padding: "2px 7px", borderRadius: 5,
                        flexShrink: 0, whiteSpace: "nowrap",
                      }}>
                        {ticket.category}
                      </span>
                    )}
                    <span className={badgeCfg.className} style={{
                      fontSize: 10.5, padding: "2px 7px", borderRadius: 5,
                      flexShrink: 0, whiteSpace: "nowrap",
                    }}>
                      {badgeCfg.label}
                    </span>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

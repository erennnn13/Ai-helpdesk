import { useState, type FormEvent } from "react";
import DOMPurify from "dompurify";
import { useParams, useNavigate } from "react-router";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../services/api";
import { useAuth } from "../context/AuthContext";
import type { Ticket, Message, User as UserType } from "../types";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { ArrowLeft, Send, Sparkles, User, Bot, Headset, UserCheck, ShieldCheck, RefreshCw } from "lucide-react";

const getSenderConfig = (msg: Message) => {
  const type = (msg.senderType || msg.sender || "").toUpperCase();
  if (type === "CUSTOMER") {
    return {
      label: "Customer",
      icon: <User className="h-3.5 w-3.5" />,
      styles: "bg-card border text-card-foreground",
    };
  }
  if (type === "ADMIN") {
    return {
      label: "Admin",
      icon: <ShieldCheck className="h-3.5 w-3.5 text-indigo-500" />,
      styles: "bg-indigo-500/10 text-foreground ml-auto border border-indigo-500/20",
    };
  }
  if (type === "AI") {
    return {
      label: "AI Support",
      icon: <Bot className="h-3.5 w-3.5 text-violet-500" />,
      styles: "bg-violet-500/10 text-violet-900 dark:text-violet-200 ml-auto border border-violet-500/20",
    };
  }
  return {
    label: "Agent",
    icon: <Headset className="h-3.5 w-3.5 text-primary" />,
    styles: "bg-primary/10 text-foreground ml-auto border border-primary/20",
  };
};

function MessageItem({ message }: { message: Message }) {
  const config = getSenderConfig(message);
  const rawContent = message.bodyHtml || message.body;
  const sanitizedContent = DOMPurify.sanitize(rawContent);
  return (
    <div className={`rounded-xl p-4 max-w-[80%] shadow-sm ${config.styles}`}>
      <div className="flex items-center gap-2 mb-2">
        <span className="text-xs font-semibold flex items-center gap-1.5">
          {config.icon} {config.label}
        </span>
        {message.senderEmail && (
          <span className="text-xs opacity-60">({message.senderEmail})</span>
        )}
        <span className="text-xs opacity-50 ml-auto">
          {new Date(message.createdAt).toLocaleString()}
        </span>
      </div>
      <div
        className="text-sm leading-relaxed whitespace-pre-wrap"
        dangerouslySetInnerHTML={{ __html: sanitizedContent }}
      />
    </div>
  );
}

export default function TicketDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { session } = useAuth();
  const [replyText, setReplyText] = useState("");
  const [isPolishing, setIsPolishing] = useState(false);
  const [polishError, setPolishError] = useState<string | null>(null);
  const [isSummarizing, setIsSummarizing] = useState(false);
  const [summarizeError, setSummarizeError] = useState<string | null>(null);

  const { data: ticketData, isLoading: loading } = useQuery({
    queryKey: ["tickets", id],
    queryFn: () =>
      api.get<{ ticket: Ticket & { messages: Message[] } }>(`/tickets/${id}`),
    enabled: !!id,
  });

  const { data: usersData } = useQuery({
    queryKey: ["users"],
    queryFn: () => api.get<{ users: UserType[] }>("/users"),
  });

  const ticket = ticketData?.ticket;
  const messages = ticket?.messages || [];
  const users = usersData?.users || [];

  const replyMutation = useMutation({
    mutationFn: (body: string) =>
      api.post<{ message: Message }>(`/tickets/${id}/messages`, { body }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["tickets", id] });
      setReplyText("");
      setPolishError(null);
    },
    onError: (err) => {
      console.error("Failed to send reply:", err);
    },
  });

  const statusMutation = useMutation({
    mutationFn: (status: string) =>
      api.patch<{ ticket: Ticket }>(`/tickets/${id}`, { status }),
    onSuccess: (data) => {
      queryClient.setQueryData(["tickets", id], (old: any) => ({
        ...old,
        ticket: { ...old.ticket, ...data.ticket },
      }));
      queryClient.invalidateQueries({ queryKey: ["tickets", id] });
      queryClient.invalidateQueries({ queryKey: ["tickets"] });
    },
    onError: (err) => {
      console.error("Failed to update status:", err);
    },
  });

  const categoryMutation = useMutation({
    mutationFn: (category: string | null) =>
      api.patch<{ ticket: Ticket }>(`/tickets/${id}`, { category }),
    onSuccess: (data) => {
      queryClient.setQueryData(["tickets", id], (old: any) => ({
        ...old,
        ticket: { ...old.ticket, ...data.ticket },
      }));
      queryClient.invalidateQueries({ queryKey: ["tickets", id] });
      queryClient.invalidateQueries({ queryKey: ["tickets"] });
    },
    onError: (err) => {
      console.error("Failed to update category:", err);
    },
  });

  const assignMutation = useMutation({
    mutationFn: (assignedToId: string | null) =>
      api.patch<{ ticket: Ticket }>(`/tickets/${id}`, { assignedToId }),
    onSuccess: (data) => {
      queryClient.setQueryData(["tickets", id], (old: any) => ({
        ...old,
        ticket: { ...old.ticket, ...data.ticket },
      }));
      queryClient.invalidateQueries({ queryKey: ["tickets", id] });
      queryClient.invalidateQueries({ queryKey: ["tickets"] });
    },
    onError: (err) => {
      console.error("Failed to assign ticket:", err);
    },
  });

  const handleSendReply = async (e: FormEvent) => {
    e.preventDefault();
    if (!replyText.trim() || replyMutation.isPending || isPolishing) return;
    replyMutation.mutate(replyText);
  };

  const handlePolish = async () => {
    if (!replyText.trim() || isPolishing || replyMutation.isPending) return;
    try {
      setIsPolishing(true);
      setPolishError(null);
      const res = await api.post<{ polishedText: string }>("/tickets/polish", {
        draft: replyText,
        subject: ticket?.subject,
        customerName: ticket?.customerName,
        agentName: ticket?.assignedTo?.name || session?.user?.name,
      });
      if (res.polishedText) {
        setReplyText(res.polishedText);
      }
    } catch (err: any) {
      console.error("Failed to polish reply:", err);
      setPolishError(err?.message || "Failed to polish reply with AI");
    } finally {
      setIsPolishing(false);
    }
  };

  const handleStatusChange = (status: string | null) => {
    if (status) statusMutation.mutate(status);
  };

  const handleSummarize = async () => {
    if (isSummarizing || !id) return;
    try {
      setIsSummarizing(true);
      setSummarizeError(null);
      const res = await api.post<{ aiSummary: string }>(`/tickets/${id}/summarize`, {});
      if (res.aiSummary) {
        queryClient.setQueryData(["tickets", id], (old: any) =>
          old ? { ...old, ticket: { ...old.ticket, aiSummary: res.aiSummary } } : old
        );
      }
    } catch (err: any) {
      console.error("Failed to summarize ticket:", err);
      setSummarizeError(err?.message || "Failed to generate summary");
    } finally {
      setIsSummarizing(false);
    }
  };

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto space-y-6">
        <div>
          <Skeleton className="h-4 w-24 mb-4" />
          <Skeleton className="h-10 w-3/4 mb-2" />
          <div className="flex gap-4">
            <Skeleton className="h-5 w-32" />
            <Skeleton className="h-5 w-24 rounded-full" />
            <Skeleton className="h-5 w-24 rounded-full" />
          </div>
        </div>
        <div className="space-y-4">
          {[...Array(3)].map((_, i) => (
            <Card key={i}>
              <CardHeader className="flex flex-row items-center gap-4">
                <Skeleton className="h-10 w-10 rounded-full" />
                <div className="space-y-2">
                  <Skeleton className="h-4 w-32" />
                  <Skeleton className="h-3 w-24" />
                </div>
              </CardHeader>
              <CardContent>
                <Skeleton className="h-4 w-full mb-2" />
                <Skeleton className="h-4 w-5/6 mb-2" />
                <Skeleton className="h-4 w-4/6" />
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    );
  }

  if (!ticket) {
    return (
      <div className="text-center py-12 relative z-10">
        <p className="text-4xl mb-3">😕</p>
        <p className="text-muted-foreground font-medium">Ticket not found</p>
        <Button variant="link" onClick={() => navigate("/tickets")} className="mt-2">
          <ArrowLeft className="mr-2 h-4 w-4" /> Back to tickets
        </Button>
      </div>
    );
  }

  return (
    <div className="max-w-6xl space-y-6 relative z-10">
      {/* Header */}
      <div>
        <Button variant="ghost" onClick={() => navigate("/tickets")} className="mb-4 -ml-4 text-muted-foreground">
          <ArrowLeft className="mr-2 h-4 w-4" /> Back to tickets
        </Button>
        <div>
          <h1 className="text-2xl font-bold text-foreground">
            {ticket.subject}
          </h1>
          <p className="text-sm text-muted-foreground mt-1">
            From <span className="font-medium text-foreground">{ticket.customerName}</span> ({ticket.customerEmail})
          </p>
        </div>
      </div>

      {/* 2-Column Grid Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* Left Column: Conversation & Reply (lg:col-span-8) */}
        <div className="lg:col-span-8 space-y-6">
          {/* AI Summary */}
          <Card className="shadow-xs border-border bg-card overflow-hidden">
            <CardHeader className="py-3 px-4 flex flex-row items-center justify-between border-b border-border/60 bg-transparent">
              <div className="flex items-center gap-2">
                <Sparkles className="h-4 w-4 text-primary" />
                <h3 className="text-xs font-semibold text-foreground tracking-tight uppercase">AI Summary</h3>
              </div>
              <Button
                type="button"
                variant="ghost"
                size="sm"
                onClick={handleSummarize}
                disabled={isSummarizing}
                className="gap-1.5 text-xs font-medium h-7 px-2.5 text-muted-foreground hover:text-foreground hover:bg-muted/60 transition-colors"
              >
                <RefreshCw className={`h-3 w-3 ${isSummarizing ? "animate-spin" : ""}`} />
                <span>{isSummarizing ? "Generating..." : ticket.aiSummary ? "Re-generate" : "Generate"}</span>
              </Button>
            </CardHeader>
            <CardContent className="p-4 pt-3 text-sm text-foreground leading-relaxed">
              {ticket.aiSummary ? (
                <p className="text-sm text-foreground/90 font-normal leading-relaxed">{ticket.aiSummary}</p>
              ) : (
                <p className="text-sm text-muted-foreground italic font-normal">
                  No summary yet. Click "Generate" to summarize this ticket.
                </p>
              )}
              {summarizeError && (
                <p className="text-xs text-destructive mt-2">{summarizeError}</p>
              )}
            </CardContent>
          </Card>

          {/* Messages */}
          <div className="space-y-4">
            <h2 className="text-sm font-semibold text-muted-foreground uppercase tracking-wider">
              Conversation
            </h2>
            <div className="space-y-4 max-h-[500px] overflow-y-auto pr-2">
              {messages.map((msg) => (
                <MessageItem key={msg.id} message={msg} />
              ))}
            </div>
          </div>

          {/* Reply Composer */}
          {ticket.status !== "CLOSED" && (
            <Card className="shadow-sm">
              <form onSubmit={handleSendReply}>
                <CardContent className="p-4">
                  <Textarea
                    value={replyText}
                    onChange={(e) => {
                      setReplyText(e.target.value);
                      if (polishError) setPolishError(null);
                    }}
                    placeholder="Type your reply..."
                    rows={4}
                    className="resize-none"
                    disabled={replyMutation.isPending || isPolishing}
                  />
                  {polishError && (
                    <p className="text-xs text-destructive mt-2">{polishError}</p>
                  )}
                  <div className="flex items-center justify-between mt-4">
                    <Button
                      type="button"
                      size="sm"
                      onClick={handlePolish}
                      disabled={!replyText.trim() || replyMutation.isPending || isPolishing}
                      className="gap-2 text-xs font-semibold bg-violet-600 hover:bg-violet-700 text-white border-0 shadow-xs transition-all disabled:opacity-50"
                    >
                      <Sparkles className={`h-3.5 w-3.5 text-amber-300 ${isPolishing ? "animate-spin" : ""}`} />
                      {isPolishing ? "Polishing with AI..." : "Polish with AI"}
                    </Button>

                    <Button
                      type="submit"
                      disabled={!replyText.trim() || replyMutation.isPending || isPolishing}
                      className="gap-2"
                    >
                      {replyMutation.isPending ? "Sending..." : "Send Reply"}
                      {!replyMutation.isPending && <Send className="h-4 w-4" />}
                    </Button>
                  </div>
                </CardContent>
              </form>
            </Card>
          )}
        </div>

        {/* Right Column: Ticket Controls & Options Panel (lg:col-span-4) */}
        <div className="lg:col-span-4 space-y-6 lg:sticky lg:top-6">
          <Card className="shadow-sm">
            <CardHeader className="py-2.5 px-4 border-b">
              <h3 className="font-semibold text-sm text-foreground">Ticket Options</h3>
            </CardHeader>
            <CardContent className="p-4 pt-2.5 space-y-3.5">
              {/* Status */}
              <div>
                <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
                  Status
                </label>
                <Select
                  value={ticket.status}
                  onValueChange={(val) => handleStatusChange(val)}
                  disabled={statusMutation.isPending}
                >
                  <SelectTrigger className="w-full h-9 text-xs font-medium" aria-label="Status">
                    <SelectValue placeholder="Status">
                      {ticket.status === "OPEN" && "🟢 Open"}
                      {ticket.status === "RESOLVED" && "✅ Resolved"}
                      {ticket.status === "CLOSED" && "🔒 Closed"}
                      {!["OPEN", "RESOLVED", "CLOSED"].includes(ticket.status) && ticket.status}
                    </SelectValue>
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="OPEN">🟢 Open</SelectItem>
                    <SelectItem value="RESOLVED">✅ Resolved</SelectItem>
                    <SelectItem value="CLOSED">🔒 Closed</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              {/* Category */}
              <div>
                <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-2">
                  Category
                </label>
                <Select
                  value={ticket.category || "UNCATEGORIZED"}
                  onValueChange={(val) => categoryMutation.mutate(val === "UNCATEGORIZED" ? null : val)}
                  disabled={categoryMutation.isPending}
                >
                  <SelectTrigger className="w-full h-9 text-xs font-medium">
                    <SelectValue placeholder="Category">
                      {ticket.category || "Uncategorized"}
                    </SelectValue>
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="UNCATEGORIZED">Uncategorized</SelectItem>
                    <SelectItem value="GENERAL">General</SelectItem>
                    <SelectItem value="TECHNICAL">Technical</SelectItem>
                    <SelectItem value="REFUND">Refund</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              {/* Assignment */}
              <div>
                <label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-2">
                  Assigned Agent
                </label>
                <div className="space-y-2">
                  {(() => {
                    const assignedAgentName = ticket.assignedToId
                      ? ticket.assignedTo?.name || users.find((u) => u.id === ticket.assignedToId)?.name || "Assigned Agent"
                      : "Unassigned";
                    return (
                      <Select
                        value={ticket.assignedToId || "UNASSIGNED"}
                        onValueChange={(val) =>
                          assignMutation.mutate(val === "UNASSIGNED" ? null : val)
                        }
                        disabled={assignMutation.isPending}
                      >
                        <SelectTrigger className="w-full h-9 text-xs font-medium">
                          <SelectValue placeholder="Unassigned">
                            {assignedAgentName}
                          </SelectValue>
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="UNASSIGNED">Unassigned</SelectItem>
                          {users.map((u) => (
                            <SelectItem key={u.id} value={u.id}>
                              {u.name} ({u.role})
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    );
                  })()}

                  {session?.user?.id && ticket.assignedToId !== session.user.id && (
                    <Button
                      variant="outline"
                      size="sm"
                      className="w-full h-8 text-xs gap-1.5 mt-1"
                      onClick={() => assignMutation.mutate(session.user.id)}
                      disabled={assignMutation.isPending}
                    >
                      <UserCheck className="h-3.5 w-3.5" />
                      Assign to me
                    </Button>
                  )}
                </div>
              </div>

              <div className="pt-3 border-t space-y-2.5 text-xs text-muted-foreground">
                <div className="flex justify-between items-center">
                  <span>Customer</span>
                  <span className="text-foreground font-medium">{ticket.customerName}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span>Email</span>
                  <span className="text-foreground font-medium truncate max-w-[160px]" title={ticket.customerEmail}>
                    {ticket.customerEmail}
                  </span>
                </div>
                <div className="flex justify-between items-center">
                  <span>Created</span>
                  <span className="text-foreground font-medium">
                    {new Date(ticket.createdAt).toLocaleDateString()}
                  </span>
                </div>
                <div className="flex justify-between items-center">
                  <span>Updated</span>
                  <span className="text-foreground font-medium">
                    {new Date(ticket.updatedAt).toLocaleDateString()}
                  </span>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}

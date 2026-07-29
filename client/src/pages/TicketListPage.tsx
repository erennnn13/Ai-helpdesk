import { useState, useMemo, useEffect } from "react";
import { useNavigate, useSearchParams } from "react-router";
import { useQuery } from "@tanstack/react-query";
import {
  createColumnHelper,
  flexRender,
  getCoreRowModel,
  useReactTable,
  type SortingState,
} from "@tanstack/react-table";
import { api } from "../services/api";
import type { Ticket, TicketListResponse, User as UserType } from "../types";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Search, ArrowDown, ArrowUp, ArrowUpDown } from "lucide-react";

const columnHelper = createColumnHelper<Ticket>();

export default function TicketListPage() {
  const [searchParams, setSearchParams] = useSearchParams();

  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState(searchParams.get("status") || "");
  const [categoryFilter, setCategoryFilter] = useState(searchParams.get("category") || "");
  const [assignedToFilter, setAssignedToFilter] = useState(searchParams.get("assignedToId") || "");
  const [aiResolvedFilter, setAiResolvedFilter] = useState(searchParams.get("aiResolved") || "");
  const [page, setPage] = useState(1);
  const [sorting, setSorting] = useState<SortingState>([{ id: "createdAt", desc: true }]);

  const navigate = useNavigate();

  useEffect(() => {
    setStatusFilter(searchParams.get("status") || "");
    setCategoryFilter(searchParams.get("category") || "");
    setAssignedToFilter(searchParams.get("assignedToId") || "");
    setAiResolvedFilter(searchParams.get("aiResolved") || "");
    setPage(1);
  }, [searchParams]);

  const { data: usersData } = useQuery({
    queryKey: ["users"],
    queryFn: () => api.get<{ users: UserType[] }>("/users"),
  });
  const users = usersData?.users || [];

  const { data, isLoading: loading, error } = useQuery({
    queryKey: ["tickets", { page, search, statusFilter, categoryFilter, assignedToFilter, aiResolvedFilter, sorting }],
    queryFn: async () => {
      const params = new URLSearchParams();
      params.set("page", String(page));
      params.set("limit", "15");

      const sortBy = sorting.length > 0 ? sorting[0].id : "createdAt";
      const sortOrder = sorting.length > 0 ? (sorting[0].desc ? "desc" : "asc") : "desc";

      params.set("sortBy", sortBy);
      params.set("sortOrder", sortOrder);

      if (search) params.set("search", search);
      if (statusFilter) params.set("status", statusFilter);
      if (categoryFilter) params.set("category", categoryFilter);
      if (assignedToFilter) params.set("assignedToId", assignedToFilter);
      if (aiResolvedFilter) params.set("aiResolved", aiResolvedFilter);

      return api.get<TicketListResponse>(`/tickets?${params.toString()}`);
    }
  });

  const tickets = data?.tickets || [];
  const totalPages = data?.pagination?.totalPages || 1;
  const totalResults = data?.pagination?.total || 0;
  const limit = data?.pagination?.limit || 15;

  const columns = useMemo(
    () => [
      columnHelper.accessor("subject", {
        header: "Subject",
        cell: (info) => (
          <p className="font-medium truncate max-w-[300px]">{info.getValue()}</p>
        ),
      }),
      columnHelper.accessor("customerName", {
        header: "Customer",
        cell: (info) => (
          <div>
            <p className="text-sm font-medium">{info.getValue()}</p>
            <p className="text-xs text-muted-foreground">{info.row.original.customerEmail}</p>
          </div>
        ),
      }),
      columnHelper.accessor("category", {
        header: "Category",
        cell: (info) => {
          const category = info.getValue();
          switch (category) {
            case "TECHNICAL":
              return (
                <Badge className="bg-purple-600 text-white hover:bg-purple-700 font-semibold border-0 shadow-xs">
                  TECHNICAL
                </Badge>
              );
            case "REFUND":
              return (
                <Badge className="bg-rose-600 text-white hover:bg-rose-700 font-semibold border-0 shadow-xs">
                  REFUND
                </Badge>
              );
            case "GENERAL":
              return (
                <Badge className="bg-blue-600 text-white hover:bg-blue-700 font-semibold border-0 shadow-xs">
                  GENERAL
                </Badge>
              );
            default:
              return (
                <Badge variant="outline" className="text-muted-foreground font-semibold">
                  Uncategorized
                </Badge>
              );
          }
        },
      }),
      columnHelper.accessor("status", {
        header: "Status",
        cell: (info) => {
          const status = info.getValue();
          switch (status) {
            case "NEW":
              return (
                <Badge className="bg-amber-500/10 text-amber-700 dark:text-amber-400 border-amber-500/20 font-medium">
                  NEW
                </Badge>
              );
            case "PROCESSING":
              return (
                <Badge className="bg-indigo-500/10 text-indigo-700 dark:text-indigo-400 border-indigo-500/20 font-medium animate-pulse">
                  PROCESSING
                </Badge>
              );
            case "OPEN":
              return (
                <Badge className="bg-emerald-500/10 text-emerald-700 dark:text-emerald-400 border-emerald-500/20 font-medium">
                  OPEN
                </Badge>
              );
            case "RESOLVED":
              return (
                <Badge variant="secondary" className="bg-blue-500/10 text-blue-700 dark:text-blue-400 border-blue-500/20 font-medium">
                  RESOLVED
                </Badge>
              );
            case "CLOSED":
              return (
                <Badge variant="outline" className="text-muted-foreground font-medium">
                  CLOSED
                </Badge>
              );
            default:
              return <Badge variant="outline">{status}</Badge>;
          }
        },
      }),
      columnHelper.accessor((row) => row.assignedTo?.name || "Unassigned", {
        id: "assignedTo",
        header: "Assigned To",
        enableSorting: false,
        cell: (info) => {
          const row = info.row.original;
          const agentName = row.assignedToId
            ? row.assignedTo?.name || users.find((u) => u.id === row.assignedToId)?.name || "Assigned Agent"
            : "Unassigned";
          return (
            <span className="text-sm text-muted-foreground font-medium">
              {agentName}
            </span>
          );
        },
      }),
      columnHelper.accessor("createdAt", {
        header: "Date",
        cell: (info) => (
          <span className="text-muted-foreground">
            {new Date(info.getValue()).toLocaleDateString()}
          </span>
        ),
      }),
    ],
    [users]
  );

  const table = useReactTable({
    data: tickets,
    columns,
    state: {
      sorting,
    },
    onSortingChange: setSorting,
    getCoreRowModel: getCoreRowModel(),
    manualSorting: true,
  });

  return (
    <div className="space-y-8 relative z-10">
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-foreground">Tickets</h1>
        <p className="text-muted-foreground mt-1">
          Manage and respond to support tickets
        </p>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex-1 min-w-[250px] relative">
          <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
          <Input
            type="text"
            placeholder="Search tickets..."
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              setPage(1);
            }}
            className="pl-9"
          />
        </div>
        <Select
          value={aiResolvedFilter === "true" ? "AI_RESOLVED" : (statusFilter || "ALL")}
          onValueChange={(val) => {
            const nextParams = new URLSearchParams(searchParams);
            if (val === "ALL" || !val) {
              nextParams.delete("status");
              nextParams.delete("aiResolved");
            } else if (val === "AI_RESOLVED") {
              nextParams.set("status", "RESOLVED");
              nextParams.set("aiResolved", "true");
            } else {
              nextParams.set("status", val);
              nextParams.delete("aiResolved");
            }
            setSearchParams(nextParams);
          }}
        >
          <SelectTrigger className="w-[180px]" aria-label="Status Filter">
            <SelectValue placeholder="All Statuses" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="ALL">All Statuses</SelectItem>
            <SelectItem value="OPEN">Open</SelectItem>
            <SelectItem value="NEW">New</SelectItem>
            <SelectItem value="PROCESSING">Processing</SelectItem>
            <SelectItem value="RESOLVED">Resolved</SelectItem>
            <SelectItem value="AI_RESOLVED">AI Resolved</SelectItem>
            <SelectItem value="CLOSED">Closed</SelectItem>
          </SelectContent>
        </Select>

        <Select
          value={categoryFilter}
          onValueChange={(val) => {
            setCategoryFilter(val === "ALL" || !val ? "" : val);
            setPage(1);
          }}
        >
          <SelectTrigger className="w-[180px]" aria-label="Category Filter">
            <SelectValue placeholder="All Categories" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="ALL">All Categories</SelectItem>
            <SelectItem value="GENERAL">General</SelectItem>
            <SelectItem value="TECHNICAL">Technical</SelectItem>
            <SelectItem value="REFUND">Refund</SelectItem>
          </SelectContent>
        </Select>

        <Select
          value={assignedToFilter}
          onValueChange={(val) => {
            setAssignedToFilter(val === "ALL" || !val ? "" : val);
            setPage(1);
          }}
        >
          <SelectTrigger className="w-[180px]" aria-label="Agent Filter">
            <SelectValue placeholder="All Assignees">
              {assignedToFilter ? users.find((u) => u.id === assignedToFilter)?.name || "Agent" : "All Assignees"}
            </SelectValue>
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="ALL">All Assignees</SelectItem>
            {users.map((u) => (
              <SelectItem key={u.id} value={u.id}>
                {u.name}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {/* Ticket Table */}
      <Card className="shadow-sm border-border overflow-hidden">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id}>
                {headerGroup.headers.map((header) => {
                  return (
                    <TableHead key={header.id}>
                      {header.isPlaceholder ? null : (
                        <div
                          {...{
                            className: header.column.getCanSort()
                              ? "cursor-pointer select-none flex items-center gap-1 hover:text-foreground transition-colors"
                              : "flex items-center gap-1",
                            onClick: header.column.getToggleSortingHandler(),
                          }}
                        >
                          {flexRender(
                            header.column.columnDef.header,
                            header.getContext()
                          )}
                          {{
                            asc: <ArrowUp className="h-4 w-4" />,
                            desc: <ArrowDown className="h-4 w-4" />,
                          }[header.column.getIsSorted() as string] ?? (header.column.getCanSort() ? <ArrowUpDown className="h-4 w-4 opacity-50" /> : null)}
                        </div>
                      )}
                    </TableHead>
                  );
                })}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {loading ? (
              [...Array(5)].map((_, i) => (
                <TableRow key={i}>
                  <TableCell><Skeleton className="h-4 w-12" /></TableCell>
                  <TableCell><Skeleton className="h-4 w-48" /></TableCell>
                  <TableCell><Skeleton className="h-4 w-24" /></TableCell>
                  <TableCell><Skeleton className="h-5 w-20 rounded-full" /></TableCell>
                  <TableCell><Skeleton className="h-5 w-16 rounded-full" /></TableCell>
                  <TableCell><Skeleton className="h-4 w-24" /></TableCell>
                </TableRow>
              ))
            ) : error ? (
              <TableRow>
                <TableCell colSpan={columns.length} className="h-48 text-center">
                  <div className="flex flex-col items-center justify-center text-destructive gap-2">
                    <p className="font-bold text-lg">⚠ API Error</p>
                    <p className="font-medium text-sm font-mono bg-red-50 px-4 py-2 rounded border border-red-200 max-w-lg break-all">
                      {(error as any)?.message || String(error)}
                    </p>
                    <p className="text-xs text-muted-foreground">Check browser console (F12) for full details</p>
                  </div>
                </TableCell>
              </TableRow>
            ) : table.getRowModel().rows?.length === 0 ? (
              <TableRow>
                <TableCell colSpan={columns.length} className="h-48 text-center">
                  <div className="flex flex-col items-center justify-center text-muted-foreground">
                    <Search className="h-8 w-8 mb-2 opacity-50" />
                    <p className="font-medium">No tickets found</p>
                    <p className="text-sm opacity-70">Try adjusting your search or filters to find what you're looking for.</p>
                  </div>
                </TableCell>
              </TableRow>
            ) : (
              table.getRowModel().rows.map((row) => (
                <TableRow
                  key={row.id}
                  onClick={() => navigate(`/tickets/${row.original.id}`)}
                  className="cursor-pointer transition-colors"
                >
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>

        {totalPages > 1 && (
          <div className="flex flex-wrap items-center justify-between gap-4 px-6 py-4 border-t">
            <p className="text-sm text-muted-foreground">
              Showing <span className="font-medium text-foreground">{totalResults > 0 ? (page - 1) * limit + 1 : 0}</span> to{" "}
              <span className="font-medium text-foreground">{Math.min(page * limit, totalResults)}</span> of{" "}
              <span className="font-medium text-foreground">{totalResults}</span> results
            </p>
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={page === 1}
              >
                Previous
              </Button>
              <span className="text-sm font-medium px-3 py-1 text-foreground rounded-md bg-muted/50 border border-border select-none">
                Page {page} of {totalPages}
              </span>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                disabled={page === totalPages}
              >
                Next
              </Button>
            </div>
          </div>
        )}
      </Card>
    </div>
  );
}

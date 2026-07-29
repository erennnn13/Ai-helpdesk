import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../services/api";
import { useAuth } from "../context/AuthContext";
import { Navigate } from "react-router";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { UserForm } from "@/components/UserForm";
import { UserTable, type User } from "@/components/UserTable";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Plus } from "lucide-react";
import { Role } from "core";



export function Users() {
  const { session, isPending } = useAuth();
  const queryClient = useQueryClient();
  
  const [dialogConfig, setDialogConfig] = useState<{
    isOpen: boolean;
    user?: User;
  }>({ isOpen: false });

  const handleOpenCreate = () => setDialogConfig({ isOpen: true });
  const handleOpenEdit = (user: User) => setDialogConfig({ isOpen: true, user });
  const handleCloseDialog = () => setDialogConfig({ isOpen: false });

  const [deleteDialogConfig, setDeleteDialogConfig] = useState<{
    isOpen: boolean;
    userId: string | null;
  }>({ isOpen: false, userId: null });

  const { data, isLoading: loading } = useQuery({
    queryKey: ["users"],
    queryFn: () => api.get<{ users: User[] }>("/users"),
  });
  const users = data?.users || [];


  const deleteMutation = useMutation({
    mutationFn: (id: string) => api.delete(`/users/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
    },
    onError: (error) => {
      console.error("Failed to delete user:", error);
      alert("Cannot delete user (you might be trying to delete yourself).");
    }
  });



  const handleDeleteUserClick = (id: string) => {
    setDeleteDialogConfig({ isOpen: true, userId: id });
  };

  const handleConfirmDelete = () => {
    if (deleteDialogConfig.userId) {
      deleteMutation.mutate(deleteDialogConfig.userId);
    }
    setDeleteDialogConfig({ isOpen: false, userId: null });
  };

  if (isPending) return null;
  if (!session || session.user.role !== Role.ADMIN) {
    return <Navigate to="/" replace />;
  }

  return (
    <div className="space-y-8 relative z-10">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">User Management</h1>
          <p className="text-muted-foreground mt-1">Manage system access and roles</p>
        </div>

        <Button onClick={handleOpenCreate} className="inline-flex shrink-0 items-center justify-center rounded-lg text-sm font-medium h-10 px-4 py-2 bg-primary text-primary-foreground shadow hover:bg-primary/90 gap-2 cursor-pointer">
          <Plus className="h-4 w-4" /> Add User
        </Button>

        <Dialog open={dialogConfig.isOpen} onOpenChange={(open) => !open && handleCloseDialog()}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>{dialogConfig.user ? "Edit User" : "Create New User"}</DialogTitle>
            </DialogHeader>
            <UserForm 
              initialData={dialogConfig.user} 
              onSuccess={handleCloseDialog} 
            />
          </DialogContent>
        </Dialog>
      </div>

      <Card className="shadow-sm border-border overflow-hidden">
        <UserTable 
          users={users} 
          loading={loading} 
          currentUserId={session.user.id} 
          onEdit={handleOpenEdit}
          onDelete={handleDeleteUserClick} 
        />
      </Card>

      <AlertDialog 
        open={deleteDialogConfig.isOpen} 
        onOpenChange={(isOpen) => setDeleteDialogConfig({ isOpen, userId: isOpen ? deleteDialogConfig.userId : null })}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Are you absolutely sure?</AlertDialogTitle>
            <AlertDialogDescription>
              This action will softly delete this user's account and revoke their access. 
              They will no longer be able to log in to the system.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleConfirmDelete} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
              Delete User
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

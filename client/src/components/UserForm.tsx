import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { userSchema, updateUserSchema, type UpdateUserFormValues, Role } from "core";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../services/api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import type { User } from "./UserTable";

interface UserFormProps {
  initialData?: User;
  onSuccess: () => void;
}

export function UserForm({ initialData, onSuccess }: UserFormProps) {
  const queryClient = useQueryClient();
  const isEditing = !!initialData;

  const {
    register,
    handleSubmit,
    control,
    reset,
    setError,
    formState: { errors },
  } = useForm<UpdateUserFormValues>({
    resolver: zodResolver(isEditing ? updateUserSchema : userSchema),
    defaultValues: {
      name: initialData?.name || "",
      email: initialData?.email || "",
      password: "",
      role: initialData?.role || Role.AGENT,
    },
  });

  const mutation = useMutation({
    mutationFn: (data: UpdateUserFormValues) => {
      // If password is empty during edit, do not send it
      const payload = { ...data };
      if (isEditing && !payload.password) {
        delete payload.password;
      }
      return isEditing
        ? api.patch(`/users/${initialData.id}`, payload)
        : api.post("/users", payload);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
      reset();
      onSuccess();
    },
    onError: (error: any) => {
      console.error(`Failed to ${isEditing ? "update" : "create"} user:`, error);
      if (error.status === 409) {
        setError("email", { type: "server", message: "Email already exists" });
      } else {
        alert(`Failed to ${isEditing ? "update" : "create"} user. See console for details.`);
      }
    }
  });

  const onSubmit = (data: UpdateUserFormValues) => {
    mutation.mutate(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4 pt-4" noValidate>
      <div className="space-y-2">
        <label htmlFor="name" className="text-sm font-medium">Name</label>
        <Input
          id="name"
          {...register("name")}
          placeholder="John Doe"
          className={errors.name ? "border-destructive focus-visible:ring-destructive" : ""}
        />
        {errors.name && <p className="text-sm text-destructive font-medium">{errors.name.message}</p>}
      </div>
      <div className="space-y-2">
        <label htmlFor="email" className="text-sm font-medium">Email</label>
        <Input
          id="email"
          type="email"
          {...register("email")}
          placeholder="john@example.com"
          className={errors.email ? "border-destructive focus-visible:ring-destructive" : ""}
        />
        {errors.email && <p className="text-sm text-destructive font-medium">{errors.email.message}</p>}
      </div>
      <div className="space-y-2">
        <label htmlFor="password" className="text-sm font-medium">
          {isEditing ? "New Password (Optional)" : "Password"}
        </label>
        <Input
          id="password"
          type="password"
          {...register("password")}
          placeholder={isEditing ? "Leave blank to keep current" : "••••••••"}
          className={errors.password ? "border-destructive focus-visible:ring-destructive" : ""}
        />
        {errors.password && <p className="text-sm text-destructive font-medium">{errors.password.message}</p>}
      </div>

      <div className="pt-4 flex justify-end">
        <Button type="submit" disabled={mutation.isPending}>
          {mutation.isPending ? (isEditing ? "Saving..." : "Creating...") : (isEditing ? "Save Changes" : "Create User")}
        </Button>
      </div>
    </form>
  );
}

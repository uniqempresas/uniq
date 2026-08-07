import { getAuthSession } from "@/lib/auth";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { LogOut } from "lucide-react";
import { logout } from "@/app/dashboard/actions";
import { MobileSidebar } from "./sidebar";

export async function Header() {
  const session = await getAuthSession();

  const initials = session?.profile?.nome_usuario
    ?.split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2) ?? "U";

  return (
    <header className="sticky top-0 z-20 flex items-center justify-between gap-4 border-b border-border bg-white px-4 py-3 sm:px-6">
      <div className="flex items-center gap-3">
        {/* Mobile menu button */}
        <MobileSidebar />

        <div className="flex flex-col">
          <h1 className="text-base font-heading font-semibold text-grafite leading-tight">
            Olá, {session?.profile?.nome_usuario ?? "Usuário"}
          </h1>
          <p className="text-xs font-body text-cinza-verde">
            {session?.empresa?.nome_fantasia ?? "Empresa"}
          </p>
        </div>
      </div>

      <div className="flex items-center gap-3">
        <div className="hidden sm:flex items-center gap-2">
          <span className="text-xs text-cinza-verde font-body">
            {session?.user?.email}
          </span>
        </div>

        <Avatar size="default" className="size-8 ring-2 ring-menta/20">
          <AvatarImage
            src={session?.empresa?.logo_url ?? undefined}
            alt={session?.profile?.nome_usuario ?? "Avatar"}
          />
          <AvatarFallback className="bg-menta/10 text-menta font-heading font-semibold text-xs">
            {initials}
          </AvatarFallback>
        </Avatar>

        <form action={logout}>
          <Button
            type="submit"
            variant="ghost"
            size="icon-sm"
            className="text-cinza-verde hover:text-grafite hover:bg-muted"
            aria-label="Sair"
          >
            <LogOut className="size-4" />
          </Button>
        </form>
      </div>
    </header>
  );
}

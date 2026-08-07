import { logout } from "./actions";
import { Button } from "@/components/ui/button";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-background">
      {/* Header escuro */}
      <header className="bg-grafite border-b border-grafite-light">
        <div className="flex items-center justify-between px-6 py-3">
          <h1 className="text-lg font-heading font-bold text-white tracking-tight">
            Base UNIQ
          </h1>
          <form action={logout}>
            <Button
              type="submit"
              variant="ghost"
              className="text-white/70 hover:text-white hover:bg-white/10 text-sm"
            >
              Sair
            </Button>
          </form>
        </div>
      </header>

      {/* Conteúdo */}
      <main className="p-6 max-w-5xl mx-auto">{children}</main>
    </div>
  );
}

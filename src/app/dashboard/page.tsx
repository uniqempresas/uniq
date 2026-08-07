import { redirect } from "next/navigation";
import { getAuthSession } from "@/lib/auth";
import { getEmpresaModulos } from "@/lib/modulos";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  MessageCircle,
  ArrowRight,
  Bot,
  Sparkles,
  LayoutDashboard,
  Users,
  Store,
  Wallet,
  Package,
  Puzzle,
  Calendar,
  BarChart3,
} from "lucide-react";
import Link from "next/link";

const moduloIconMap: Record<string, React.ElementType> = {
  attendant: MessageCircle,
  crm: Users,
  storefront: Store,
  finance: Wallet,
  inventory: Package,
  team: Users,
  reports: BarChart3,
  agenda: Calendar,
};

export default async function DashboardPage() {
  const session = await getAuthSession();

  if (!session) {
    redirect("/login");
  }

  const modulos = await getEmpresaModulos(session.empresa.id);

  const ativos = modulos.filter((m) => m.status === "ativo");
  const pendentes = modulos.filter((m) => m.status === "pendente");

  return (
    <div className="space-y-8">
      {/* Hero / Welcome */}
      <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-grafite to-grafite-light p-6 sm:p-8">
        {/* Decorative elements */}
        <div className="absolute -top-6 -right-6 size-32 rounded-full bg-menta/10 blur-3xl" />
        <div className="absolute -bottom-8 -left-8 size-40 rounded-full bg-petroleo/10 blur-3xl" />

        <div className="relative flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div className="space-y-2">
            <div className="flex items-center gap-2">
              <LayoutDashboard className="size-5 text-menta" />
              <span className="text-xs font-heading font-semibold uppercase tracking-wider text-menta/80">
                Dashboard
              </span>
            </div>
            <h1 className="text-2xl font-heading font-bold text-white sm:text-3xl">
              {session.empresa.nome_fantasia}
            </h1>
            <p className="text-sm text-white/60 font-body max-w-lg">
              Sua central de operações com a Melissa. Aqui você gerencia seus
              módulos, acompanha resultados e conversa com sua parceira digital.
            </p>
          </div>

          <Link href="/chat">
            <Button className="bg-menta hover:bg-menta-light text-white font-heading font-semibold shadow-lg shadow-menta/25 gap-2">
              <MessageCircle className="size-4" />
              Conversar com Melissa
              <ArrowRight className="size-4" />
            </Button>
          </Link>
        </div>
      </div>

      {/* Quick Stats */}
      <div className="grid gap-4 sm:grid-cols-3">
        <Card className="shadow-card">
          <CardContent className="flex items-center gap-4 p-5">
            <div className="flex size-12 items-center justify-center rounded-xl bg-menta/10">
              <Bot className="size-6 text-menta" />
            </div>
            <div>
              <p className="text-2xl font-heading font-bold text-grafite">
                {ativos.length}
              </p>
              <p className="text-xs font-body text-cinza-verde">
                Módulos ativos
              </p>
            </div>
          </CardContent>
        </Card>

        <Card className="shadow-card">
          <CardContent className="flex items-center gap-4 p-5">
            <div className="flex size-12 items-center justify-center rounded-xl bg-warning/10">
              <Sparkles className="size-6 text-warning" />
            </div>
            <div>
              <p className="text-2xl font-heading font-bold text-grafite">
                {pendentes.length}
              </p>
              <p className="text-xs font-body text-cinza-verde">
                Pendentes de ativação
              </p>
            </div>
          </CardContent>
        </Card>

        <Card className="shadow-card">
          <CardContent className="flex items-center gap-4 p-5">
            <div className="flex size-12 items-center justify-center rounded-xl bg-petroleo/10">
              <LayoutDashboard className="size-6 text-petroleo" />
            </div>
            <div>
              <p className="text-2xl font-heading font-bold text-grafite">
                {modulos.length}
              </p>
              <p className="text-xs font-body text-cinza-verde">
                Total disponível
              </p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Módulos */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-heading font-semibold text-grafite">
            Seus módulos
          </h2>
          {pendentes.length > 0 && (
            <Badge
              variant="secondary"
              className="bg-warning/15 text-warning font-heading text-xs"
            >
              {pendentes.length} pendente{pendentes.length !== 1 ? "s" : ""}
            </Badge>
          )}
        </div>

        {modulos.length === 0 ? (
          <Card className="shadow-card">
            <CardContent className="flex flex-col items-center justify-center py-12 text-center">
              <Puzzle className="size-10 text-cinza-verde/40 mb-3" />
              <p className="text-sm font-body text-cinza-verde">
                Nenhum módulo disponível no momento.
              </p>
              <p className="text-xs font-body text-cinza-verde/60 mt-1">
                Em breve você poderá ativar novos módulos aqui.
              </p>
            </CardContent>
          </Card>
        ) : (
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {modulos.map((modulo) => {
              const IconComponent = moduloIconMap[modulo.codigo] ?? Puzzle;

              return (
                <Card
                  key={modulo.codigo}
                  className={`shadow-card transition-all duration-200 hover:shadow-elevated ${
                    modulo.status === "ativo"
                      ? "ring-1 ring-menta/20"
                      : modulo.status === "pendente"
                        ? "ring-1 ring-warning/20"
                        : "opacity-70"
                  }`}
                >
                  <CardHeader className="flex flex-row items-start justify-between gap-3">
                    <div className="flex items-center gap-3">
                      <div
                        className={`flex size-10 items-center justify-center rounded-lg ${
                          modulo.status === "ativo"
                            ? "bg-menta/10 text-menta"
                            : modulo.status === "pendente"
                              ? "bg-warning/10 text-warning"
                              : "bg-surface text-cinza-verde"
                        }`}
                      >
                        <IconComponent className="size-5" />
                      </div>
                      <CardTitle className="text-sm font-heading font-semibold text-grafite">
                        {modulo.nome}
                      </CardTitle>
                    </div>
                    <Badge
                      variant={
                        modulo.status === "ativo"
                          ? "default"
                          : modulo.status === "pendente"
                            ? "secondary"
                            : "outline"
                      }
                      className={`text-[10px] leading-none px-2 py-1 ${
                        modulo.status === "ativo"
                          ? "bg-menta text-white"
                          : modulo.status === "pendente"
                            ? "bg-warning/15 text-warning"
                            : "bg-surface text-cinza-verde"
                      }`}
                    >
                      {modulo.status === "ativo"
                        ? "Ativo"
                        : modulo.status === "pendente"
                          ? "Pendente"
                          : "Inativo"}
                    </Badge>
                  </CardHeader>
                  {modulo.descricao && (
                    <CardContent className="pt-0">
                      <p className="text-xs font-body text-cinza-verde leading-relaxed">
                        {modulo.descricao}
                      </p>
                    </CardContent>
                  )}
                </Card>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}

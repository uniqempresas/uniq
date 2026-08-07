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

export default async function DashboardPage() {
  const session = await getAuthSession();

  if (!session) {
    redirect("/login");
  }

  const modulos = await getEmpresaModulos(session.empresa.id);

  return (
    <div className="space-y-8">
      {/* Saudação */}
      <div>
        <h1 className="text-2xl font-heading font-bold text-grafite">
          Olá, {session.profile.nome_usuario}
        </h1>
        <p className="text-cinza-verde text-sm mt-1">
          {session.empresa.nome_fantasia} &middot; {session.user.email}
        </p>
      </div>

      {/* Módulos */}
      <div>
        <h2 className="text-lg font-heading font-semibold text-grafite mb-4">
          Seus módulos
        </h2>

        {modulos.length === 0 ? (
          <p className="text-cinza-verde text-sm">
            Nenhum módulo disponível no momento.
          </p>
        ) : (
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {modulos.map((modulo) => (
              <Card key={modulo.codigo}>
                <CardHeader className="flex flex-row items-center justify-between gap-2">
                  <CardTitle className="text-base font-heading font-semibold">
                    {modulo.nome}
                  </CardTitle>
                  <Badge
                    variant={
                      modulo.status === "ativo"
                        ? "default"
                        : modulo.status === "pendente"
                          ? "secondary"
                          : "outline"
                    }
                  >
                    {modulo.status === "ativo"
                      ? "Ativo"
                      : modulo.status === "pendente"
                        ? "Pendente"
                        : "Inativo"}
                  </Badge>
                </CardHeader>
                {modulo.descricao && (
                  <CardContent>
                    <p className="text-sm text-cinza-verde">
                      {modulo.descricao}
                    </p>
                  </CardContent>
                )}
              </Card>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

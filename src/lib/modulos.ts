import { createClient } from "@/lib/supabase/server";

export type ModuloInfo = {
  codigo: string;
  nome: string;
  descricao: string | null;
  icone: string | null;
  status: "ativo" | "pendente" | "inativo";
};

/**
 * Busca os módulos disponíveis no sistema e retorna o status
 * de cada um para a empresa informada.
 */
export async function getEmpresaModulos(
  empresaId: string
): Promise<ModuloInfo[]> {
  const supabase = await createClient();

  // Buscar todos os módulos do sistema
  const { data: modulosSistema } = await supabase
    .from("unq_modulos_sistema")
    .select("*")
    .order("nome");

  if (!modulosSistema) return [];

  // Buscar módulos ativos da empresa
  const { data: empresaModulos } = await supabase
    .from("unq_empresa_modulos")
    .select("*")
    .eq("empresa_id", empresaId);

  const empresaModulosMap = new Map(
    (empresaModulos ?? []).map((m) => [m.modulo_codigo, m])
  );

  return modulosSistema.map((modulo) => {
    const empresaModulo = empresaModulosMap.get(modulo.codigo);
    let status: ModuloInfo["status"] = "inativo";

    if (empresaModulo) {
      status = empresaModulo.ativo ? "ativo" : "inativo";
    }

    return {
      codigo: modulo.codigo,
      nome: modulo.nome,
      descricao: modulo.descricao ?? null,
      icone: modulo.icone ?? null,
      status,
    };
  });
}

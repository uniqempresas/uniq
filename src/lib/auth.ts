import { createClient } from "@/lib/supabase/server";

export type UserProfile = {
  id: string;
  empresa_id: string;
  nome_usuario: string;
  email: string;
  cargo: number;
  role: string;
  ativo: boolean;
};

export type EmpresaInfo = {
  id: string;
  nome_fantasia: string;
  email: string;
  telefone: string;
  slug: string;
  logo_url: string;
};

export type AuthSession = {
  user: {
    id: string;
    email: string;
  };
  profile: UserProfile;
  empresa: EmpresaInfo;
};

/**
 * Retorna o usuário logado, seu perfil em me_usuario e a empresa em me_empresa.
 * Se algo estiver inconsistente (perfil ausente, empresa ausente, inativo),
 * retorna null para que o middleware possa redirecionar.
 */
export async function getAuthSession(): Promise<AuthSession | null> {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) return null;

  // Buscar perfil do usuário
  const { data: profile } = await supabase
    .from("me_usuario")
    .select("*")
    .eq("id", user.id)
    .single();

  if (!profile || !profile.ativo) return null;

  // Buscar empresa
  const { data: empresa } = await supabase
    .from("me_empresa")
    .select("*")
    .eq("id", profile.empresa_id)
    .single();

  if (!empresa) return null;

  return {
    user: {
      id: user.id,
      email: user.email ?? "",
    },
    profile: profile as UserProfile,
    empresa: empresa as EmpresaInfo,
  };
}

/**
 * Retorna apenas o perfil do usuário logado (mais leve).
 */
export async function getUserProfile(): Promise<UserProfile | null> {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) return null;

  const { data: profile } = await supabase
    .from("me_usuario")
    .select("*")
    .eq("id", user.id)
    .single();

  if (!profile || !profile.ativo) return null;

  return profile as UserProfile;
}

/**
 * Retorna apenas a empresa do usuário logado.
 */
export async function getUserEmpresa(): Promise<EmpresaInfo | null> {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) return null;

  const { data: profile } = await supabase
    .from("me_usuario")
    .select("empresa_id")
    .eq("id", user.id)
    .single();

  if (!profile) return null;

  const { data: empresa } = await supabase
    .from("me_empresa")
    .select("*")
    .eq("id", profile.empresa_id)
    .single();

  return empresa as EmpresaInfo | null;
}

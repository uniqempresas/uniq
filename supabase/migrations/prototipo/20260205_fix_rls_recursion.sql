-- =============================================================================
-- MIGRATION: 20260205_fix_rls_recursion.sql
-- DESCRIÇÃO: Corrige erro 500 (Recursão Infinita) causado pela policy anterior.
-- Motivo: A policy consultava a própria tabela 'me_usuario', criando um loop infinito.
-- Solução: Criar função SECURITY DEFINER para buscar o ID da empresa bypassing RLS.
-- =============================================================================

-- 1. Criar função segura para obter ID da empresa do usuário atual
CREATE OR REPLACE FUNCTION public.get_my_empresa_id()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER -- Roda com permissões de admin (bypassa RLS)
SET search_path = public
STABLE
AS $$
  SELECT empresa_id FROM public.me_usuario WHERE id = auth.uid() LIMIT 1;
$$;

-- Permissões para a função
GRANT EXECUTE ON FUNCTION public.get_my_empresa_id TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_my_empresa_id TO anon;

-- 2. Recriar as Policies problemáticas usando a nova função

-- Remover policies antigas (que causam o crash)
DROP POLICY IF EXISTS "Usuários podem ver colaboradores da mesma empresa" ON public.me_usuario;
DROP POLICY IF EXISTS "Usuários podem criar novos colaboradores" ON public.me_usuario;
DROP POLICY IF EXISTS "Usuários podem atualizar colaboradores da mesma empresa" ON public.me_usuario;
DROP POLICY IF EXISTS "Usuários podem remover colaboradores da mesma empresa" ON public.me_usuario;

-- Recriar SELECT (Visualização)
CREATE POLICY "fix_select_me_usuario"
ON public.me_usuario
FOR SELECT
USING (
  -- Usuário vê a si mesmo OU usuários da mesma empresa
  -- A função get_my_empresa_id() não dispara RLS novamente
  id = auth.uid() OR empresa_id = get_my_empresa_id()
);

-- Recriar INSERT (Criação)
CREATE POLICY "fix_insert_me_usuario"
ON public.me_usuario
FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' AND
  empresa_id = get_my_empresa_id()
);

-- Recriar UPDATE (Edição)
CREATE POLICY "fix_update_me_usuario"
ON public.me_usuario
FOR UPDATE
USING (
  empresa_id = get_my_empresa_id()
);

-- Recriar DELETE (Exclusão)
CREATE POLICY "fix_delete_me_usuario"
ON public.me_usuario
FOR DELETE
USING (
  empresa_id = get_my_empresa_id()
);

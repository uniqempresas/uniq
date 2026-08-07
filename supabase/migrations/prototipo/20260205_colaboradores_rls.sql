-- =============================================================================
-- MIGRATION: 20260205_colaboradores_rls.sql
-- DESCRIÇÃO: Configura Policies (RLS) para gestão de colaboradores na tabela me_usuario
-- DATA: 05/02/2026
-- =============================================================================

-- Habilitar RLS na tabela me_usuario (já deve estar, mas garantindo)
ALTER TABLE public.me_usuario ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- POLICY: Visualização (SELECT)
-- -----------------------------------------------------------------------------
-- Regra: Usuário pode ver todos os colaboradores da SUA empresa.
DROP POLICY IF EXISTS "Usuários podem ver colaboradores da mesma empresa" ON public.me_usuario;

CREATE POLICY "Usuários podem ver colaboradores da mesma empresa"
ON public.me_usuario
FOR SELECT
USING (
  empresa_id IN (
    SELECT empresa_id 
    FROM public.me_usuario 
    WHERE id = auth.uid()
  )
);

-- -----------------------------------------------------------------------------
-- POLICY: Inserção (INSERT)
-- -----------------------------------------------------------------------------
-- Regra: Apenas usuários autenticados podem criar colaboradores.
-- Idealmente restringiríamos para role='admin' ou 'dono', mas no MVP 
-- qualquer usuário da empresa pode convidar (ou verificaremos no frontend).
DROP POLICY IF EXISTS "Usuários podem criar novos colaboradores" ON public.me_usuario;

CREATE POLICY "Usuários podem criar novos colaboradores"
ON public.me_usuario
FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' AND
  empresa_id IN (
    SELECT empresa_id 
    FROM public.me_usuario 
    WHERE id = auth.uid()
  )
);

-- -----------------------------------------------------------------------------
-- POLICY: Atualização (UPDATE)
-- -----------------------------------------------------------------------------
-- Regra: Usuário pode editar dados da mesma empresa.
DROP POLICY IF EXISTS "Usuários podem atualizar colaboradores da mesma empresa" ON public.me_usuario;

CREATE POLICY "Usuários podem atualizar colaboradores da mesma empresa"
ON public.me_usuario
FOR UPDATE
USING (
  empresa_id IN (
    SELECT empresa_id 
    FROM public.me_usuario 
    WHERE id = auth.uid()
  )
);

-- -----------------------------------------------------------------------------
-- POLICY: Exclusão (DELETE)
-- -----------------------------------------------------------------------------
-- Regra: Usuário pode remover colaboradores da mesma empresa.
DROP POLICY IF EXISTS "Usuários podem remover colaboradores da mesma empresa" ON public.me_usuario;

CREATE POLICY "Usuários podem remover colaboradores da mesma empresa"
ON public.me_usuario
FOR DELETE
USING (
  empresa_id IN (
    SELECT empresa_id 
    FROM public.me_usuario 
    WHERE id = auth.uid()
  )
);

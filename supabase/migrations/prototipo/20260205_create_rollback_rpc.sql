-- =============================================================================
-- MIGRATION: 20260205_create_rollback_rpc.sql
-- DESCRIÇÃO: Cria RPC para permitir rollback de cadastro (deletar usuário)
-- DATA: 05/02/2026
-- =============================================================================

-- Função para limpar usuário se o cadastro falhar
-- Deve ser chamada pelo frontend em caso de erro na criação da empresa
-- IMPORTANTE: Esta função tem SECURITY DEFINER para poder deletar de auth.users
CREATE OR REPLACE FUNCTION public.clean_up_failed_registration()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid;
BEGIN
  -- Identificar usuário chamador
  v_user_id := auth.uid();

  -- 1. Verificar se usuário está autenticado
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Não autorizado. Usuário não identificado.';
  END IF;

  -- 2. Verificar se usuário JÁ tem empresa ou perfil (segurança contra deleção acidental)
  -- Se o usuário já existe na tabela de perfil, significa que o cadastro funcionou parcialmente ou é uma conta antiga.
  -- Neste caso, NÃO deletamos para evitar perda de dados.
  IF EXISTS (SELECT 1 FROM public.me_usuario WHERE id = v_user_id) THEN
    RAISE EXCEPTION 'Abortando rollback: Usuário já possui perfil vinculado. Intervenção manual necessária.';
  END IF;

  -- 3. Deletar usuário do Auth
  -- Como usamos SECURITY DEFINER, esta função roda com permissões de admin do banco
  DELETE FROM auth.users WHERE id = v_user_id;

  -- Log (opcional, dependendo de como você gerencia logs)
  RAISE NOTICE 'Rollback executado com sucesso para usuário %', v_user_id;
END;
$$;

-- Permissões
-- Necessário dar permissão para que o usuário (mesmo que recém criado) possa chamar
GRANT EXECUTE ON FUNCTION public.clean_up_failed_registration TO authenticated;
GRANT EXECUTE ON FUNCTION public.clean_up_failed_registration TO anon; -- Segurança adicional caso o login não tenha propagado totalmente

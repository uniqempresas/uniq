-- =============================================================================
-- MIGRATION: 20260216_add_ativo_me_usuario.sql
-- DESCRIÇÃO: Adiciona coluna 'ativo' na tabela me_usuario para controle de status.
-- =============================================================================

ALTER TABLE public.me_usuario 
ADD COLUMN IF NOT EXISTS ativo BOOLEAN DEFAULT TRUE;

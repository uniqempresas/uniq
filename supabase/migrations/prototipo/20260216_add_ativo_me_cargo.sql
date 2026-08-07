-- =============================================================================
-- MIGRATION: 20260216_add_ativo_me_cargo.sql
-- DESCRIÇÃO: Adiciona coluna 'ativo' na tabela me_cargo (solicitado via erro de teste manual)
-- =============================================================================

ALTER TABLE public.me_cargo 
ADD COLUMN IF NOT EXISTS ativo BOOLEAN DEFAULT TRUE;

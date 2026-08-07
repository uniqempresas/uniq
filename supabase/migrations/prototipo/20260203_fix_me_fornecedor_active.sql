-- Migration: Corrigir colunas faltantes em me_fornecedor
-- Data: 2026-02-03
-- Motivo: Erro PGRST204 (coluna ativo não encontrada)

ALTER TABLE me_fornecedor 
ADD COLUMN IF NOT EXISTS ativo BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS observacoes TEXT;

-- Recarregar schema cache do PostgREST
NOTIFY pgrst, 'reload schema';

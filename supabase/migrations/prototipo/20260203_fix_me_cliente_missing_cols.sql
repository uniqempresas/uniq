-- Migration: Adicionar TODAS as colunas potencialmente faltantes em me_cliente
-- Data: 2026-02-03
-- Motivo: Erros sucessivos de colunas inexistentes (ativo, cidade) indicam tabela base incompleta.

ALTER TABLE me_cliente 
ADD COLUMN IF NOT EXISTS ativo BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS observacoes TEXT,
ADD COLUMN IF NOT EXISTS cidade TEXT,
ADD COLUMN IF NOT EXISTS estado TEXT,
ADD COLUMN IF NOT EXISTS cep TEXT,
ADD COLUMN IF NOT EXISTS endereco TEXT, -- Usado como logradouro
ADD COLUMN IF NOT EXISTS telefone TEXT,
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS data_nascimento DATE;

-- Forçar recarregamento do cache de schema
NOTIFY pgrst, 'reload schema';

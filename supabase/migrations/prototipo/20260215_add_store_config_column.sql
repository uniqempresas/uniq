-- Migration: Adicionar coluna store_config na tabela me_empresa
-- Data: 2026-02-15
-- Descrição: Adiciona coluna JSONB para armazenar configurações da loja virtual

-- Adicionar coluna store_config como JSONB
ALTER TABLE me_empresa
ADD COLUMN IF NOT EXISTS store_config JSONB DEFAULT '{}'::jsonb;

-- Comentário na coluna
COMMENT ON COLUMN me_empresa.store_config IS 'Configurações da loja virtual em formato JSON (aparência, contato, operacional, etc)';

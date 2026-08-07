-- Migration: Garantir TODAS as colunas de endereço/contato em me_fornecedor
-- Data: 2026-02-03
-- Motivo: Tabela original incompleta (faltando cidade, estado, etc.)

ALTER TABLE me_fornecedor 
-- Colunas de Endereço
ADD COLUMN IF NOT EXISTS endereco TEXT, -- Usado como logradouro
ADD COLUMN IF NOT EXISTS numero TEXT,
ADD COLUMN IF NOT EXISTS complemento TEXT,
ADD COLUMN IF NOT EXISTS bairro TEXT,
ADD COLUMN IF NOT EXISTS cidade TEXT,
ADD COLUMN IF NOT EXISTS estado TEXT,
ADD COLUMN IF NOT EXISTS cep TEXT,
-- Colunas de Contato/Dados
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS telefone TEXT,
ADD COLUMN IF NOT EXISTS contato_nome TEXT,
ADD COLUMN IF NOT EXISTS cpf_cnpj TEXT,
ADD COLUMN IF NOT EXISTS ie_rg TEXT,
ADD COLUMN IF NOT EXISTS razao_social TEXT;

-- Recarregar schema cache
NOTIFY pgrst, 'reload schema';

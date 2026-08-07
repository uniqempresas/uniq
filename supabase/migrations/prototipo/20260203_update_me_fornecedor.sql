-- Migration: Atualização da tabela me_fornecedor (Padronização com Clientes)
-- Data: 2026-02-03
-- Objetivo: Adicionar colunas de endereço estruturado e documentos faltantes

-- Renomear colunas se necessário (nome já existe, vamos mantê-lo como principal)

ALTER TABLE me_fornecedor
ADD COLUMN IF NOT EXISTS razao_social TEXT, -- Opcional, se 'nome' for usado como Fantasia
ADD COLUMN IF NOT EXISTS cpf_cnpj TEXT,    -- Para padronizar (era 'cnpj')
ADD COLUMN IF NOT EXISTS ie_rg TEXT,       -- Inscrição Estadual
ADD COLUMN IF NOT EXISTS contato_nome TEXT,-- Nome pessoa contato
-- Endereço Estruturado (endereco já existe como logradouro)
ADD COLUMN IF NOT EXISTS numero TEXT,
ADD COLUMN IF NOT EXISTS complemento TEXT,
ADD COLUMN IF NOT EXISTS bairro TEXT,
ADD COLUMN IF NOT EXISTS cep TEXT;

-- Migrar dados antigos de cnpj para cpf_cnpj se houver
UPDATE me_fornecedor SET cpf_cnpj = cnpj WHERE cpf_cnpj IS NULL AND cnpj IS NOT NULL;

-- Garantir índices
CREATE INDEX IF NOT EXISTS idx_me_fornecedor_cpf_cnpj ON me_fornecedor(cpf_cnpj);

-- Recarregar schema cache
NOTIFY pgrst, 'reload schema';

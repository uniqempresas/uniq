-- Migration: Adequação da tabela me_cliente
-- Data: 2026-02-03
-- Objetivo: Adicionar colunas faltantes para o cadastro completo

-- Adicionar colunas de identificação e metadata
ALTER TABLE me_cliente 
ADD COLUMN IF NOT EXISTS rg_ie TEXT,
ADD COLUMN IF NOT EXISTS foto_url TEXT,
ADD COLUMN IF NOT EXISTS origem TEXT;

-- Adicionar colunas detalhadas de endereço
-- A tabela já possui: endereco ("logradouro"), cidade, estado, cep
ALTER TABLE me_cliente 
ADD COLUMN IF NOT EXISTS numero TEXT,
ADD COLUMN IF NOT EXISTS complemento TEXT,
ADD COLUMN IF NOT EXISTS bairro TEXT,
ADD COLUMN IF NOT EXISTS cpf_cnpj TEXT;

-- Melhoria: Renomear 'endereco' para 'logradouro' para clareza (opcional, mas recomendado)
-- Vamos manter 'endereco' como logradouro para evitar quebrar legado se houver, 
-- mas no código trataremos como logradouro.

-- Garantir índices
CREATE INDEX IF NOT EXISTS idx_me_cliente_cpf_cnpj ON me_cliente(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_me_cliente_email ON me_cliente(email);

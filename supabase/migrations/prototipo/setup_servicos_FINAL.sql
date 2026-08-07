-- =============================================================================
-- SCRIPT DE CONFIGURAÇÃO FINAL - MÓDULO DE SERVIÇOS
-- Data: 03/02/2026
-- =============================================================================

-- 1. TABELA DE IMAGENS DE SERVIÇOS
-- Cria se não existir
CREATE TABLE IF NOT EXISTS me_servico_imagem (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    empresa_id UUID NOT NULL REFERENCES me_empresa(id) ON DELETE CASCADE,
    servico_id BIGINT NOT NULL REFERENCES me_servico(id) ON DELETE CASCADE,
    imagem_url TEXT NOT NULL,
    ordem_exibicao INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS para Tabela
ALTER TABLE me_servico_imagem ENABLE ROW LEVEL SECURITY;

-- Remove policies antigas se existirem para evitar conflito na criação
DROP POLICY IF EXISTS "Servico Imagem: Acesso permitido para empresa" ON me_servico_imagem;
DROP POLICY IF EXISTS "Servico Imagem: Criação permitida para empresa" ON me_servico_imagem;
DROP POLICY IF EXISTS "Servico Imagem: Deleção permitida para empresa" ON me_servico_imagem;

-- Policies
CREATE POLICY "Servico Imagem: Acesso permitido para empresa"
    ON me_servico_imagem FOR SELECT
    USING (auth.uid() IN (SELECT id FROM me_usuario WHERE empresa_id = me_servico_imagem.empresa_id));

CREATE POLICY "Servico Imagem: Criação permitida para empresa"
    ON me_servico_imagem FOR INSERT
    WITH CHECK (auth.uid() IN (SELECT id FROM me_usuario WHERE empresa_id = me_servico_imagem.empresa_id));

CREATE POLICY "Servico Imagem: Deleção permitida para empresa"
    ON me_servico_imagem FOR DELETE
    USING (auth.uid() IN (SELECT id FROM me_usuario WHERE empresa_id = me_servico_imagem.empresa_id));

-- 2. CONFIGURAÇÃO DE STORAGE (BUCKET)
-- Cria bucket 'company-assets' se não existir
INSERT INTO storage.buckets (id, name, public)
VALUES ('company-assets', 'company-assets', true)
ON CONFLICT (id) DO NOTHING;

-- Policies para Storage
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Upload" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Update" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Delete" ON storage.objects;

-- Permitir leitura pública
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'company-assets' );

-- Permitir upload autenticado
CREATE POLICY "Authenticated Upload"
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id = 'company-assets' AND auth.role() = 'authenticated' );

-- Permitir update/delete autenticado
CREATE POLICY "Authenticated Update"
ON storage.objects FOR UPDATE
USING ( bucket_id = 'company-assets' AND auth.role() = 'authenticated' );

CREATE POLICY "Authenticated Delete"
ON storage.objects FOR DELETE
USING ( bucket_id = 'company-assets' AND auth.role() = 'authenticated' );

-- FIM

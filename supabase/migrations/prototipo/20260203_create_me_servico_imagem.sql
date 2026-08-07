-- Migration: Create me_servico_imagem table
-- Created at: 2026-02-03
-- Author: Antigravity

-- Tabela: me_servico_imagem
-- Descrição: Imagens de serviços (galeria)
CREATE TABLE IF NOT EXISTS me_servico_imagem (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    empresa_id UUID NOT NULL REFERENCES me_empresa(id) ON DELETE CASCADE,
    servico_id BIGINT NOT NULL REFERENCES me_servico(id) ON DELETE CASCADE,
    imagem_url TEXT NOT NULL,
    ordem_exibicao INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS Policies
ALTER TABLE me_servico_imagem ENABLE ROW LEVEL SECURITY;

-- Policy: Select (Ler)
CREATE POLICY "Servico Imagem: Acesso permitido para empresa"
    ON me_servico_imagem FOR SELECT
    USING (auth.uid() IN (
        SELECT id FROM me_usuario WHERE empresa_id = me_servico_imagem.empresa_id
    ));

-- Policy: Insert (Criar)
CREATE POLICY "Servico Imagem: Criação permitida para empresa"
    ON me_servico_imagem FOR INSERT
    WITH CHECK (auth.uid() IN (
        SELECT id FROM me_usuario WHERE empresa_id = me_servico_imagem.empresa_id
    ));

-- Policy: Delete (Deletar)
CREATE POLICY "Servico Imagem: Deleção permitida para empresa"
    ON me_servico_imagem FOR DELETE
    USING (auth.uid() IN (
        SELECT id FROM me_usuario WHERE empresa_id = me_servico_imagem.empresa_id
    ));

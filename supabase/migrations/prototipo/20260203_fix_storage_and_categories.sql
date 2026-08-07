-- Migration: Fix Storage and Categories
-- Created at: 2026-02-03
-- Author: Antigravity

-- 1. Storage Bucket: company-assets
-- Cria o bucket se não existir
INSERT INTO storage.buckets (id, name, public)
VALUES ('company-assets', 'company-assets', true)
ON CONFLICT (id) DO NOTHING;

-- Policies para Storage
-- Permitir leitura pública
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'company-assets' );

-- Permitir upload autenticado (qualquer usuario logado)
CREATE POLICY "Authenticated Upload"
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id = 'company-assets' AND auth.role() = 'authenticated' );

-- Permitir update/delete do próprio usuario ou da empresa (simplificado para authenticated por enquanto)
CREATE POLICY "Authenticated Update"
ON storage.objects FOR UPDATE
USING ( bucket_id = 'company-assets' AND auth.role() = 'authenticated' );

CREATE POLICY "Authenticated Delete"
ON storage.objects FOR DELETE
USING ( bucket_id = 'company-assets' AND auth.role() = 'authenticated' );

-- NOTA: As policies acima são permissivas para MVP. 
-- Em produção idealmente restringir por folder (empresa_id).

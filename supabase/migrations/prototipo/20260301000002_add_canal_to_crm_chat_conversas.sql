-- Migration: 20260301000002_add_canal_to_crm_chat_conversas.sql
-- Sprint 10: Unificação CRM + Atendente
-- Adiciona suporte a múltiplos canais nas conversas

-- Adicionar coluna canal
ALTER TABLE public.crm_chat_conversas 
ADD COLUMN IF NOT EXISTS canal varchar(20) NOT NULL DEFAULT 'whatsapp';

-- Adicionar coluna canal_id (identificador externo)
ALTER TABLE public.crm_chat_conversas 
ADD COLUMN IF NOT EXISTS canal_id varchar(100);

-- Adicionar coluna canal_dados (JSON com dados específicos do canal)
ALTER TABLE public.crm_chat_conversas 
ADD COLUMN IF NOT EXISTS canal_dados jsonb DEFAULT '{}'::jsonb;

-- Constraint para valores válidos
ALTER TABLE public.crm_chat_conversas 
ADD CONSTRAINT valid_canal CHECK (canal IN ('whatsapp', 'email', 'chat', 'instagram', 'facebook', 'telegram'));

-- Index para busca por canal
CREATE INDEX IF NOT EXISTS idx_crm_chat_conversas_canal ON public.crm_chat_conversas(canal);
CREATE INDEX IF NOT EXISTS idx_crm_chat_conversas_canal_id ON public.crm_chat_conversas(canal_id);

-- Atualizar conversas existentes para ter canal explícito
UPDATE public.crm_chat_conversas 
SET canal = 'whatsapp' 
WHERE canal IS NULL OR canal = '';

-- Comentários
COMMENT ON COLUMN public.crm_chat_conversas.canal IS 'Canal de comunicação (whatsapp, email, chat, instagram, facebook, telegram)';
COMMENT ON COLUMN public.crm_chat_conversas.canal_id IS 'ID externo do canal (telefone, email, etc)';
COMMENT ON COLUMN public.crm_chat_conversas.canal_dados IS 'Dados específicos do canal (JSON)';

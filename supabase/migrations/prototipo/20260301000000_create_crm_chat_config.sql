-- Migration: 20260301000000_create_crm_chat_config.sql
-- Sprint 10: Unificação CRM + Atendente
-- Cria tabela de configuração do chat no CRM

CREATE TABLE IF NOT EXISTS public.crm_chat_config (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  empresa_id uuid NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
  
  -- Configurações do Agente
  agente_nome varchar(100) NOT NULL DEFAULT 'Assistente Virtual',
  agente_avatar_url text,
  mensagem_boas_vindas text NOT NULL DEFAULT 'Olá! Como posso ajudar?',
  mensagem_ausencia text NOT NULL DEFAULT 'Nosso horário de atendimento é de segunda a sexta, das 8h às 18h. Retornaremos em breve!',
  
  -- Horário de Funcionamento (JSONB)
  horario_funcionamento jsonb NOT NULL DEFAULT '{
    "dias": ["seg", "ter", "qua", "qui", "sex"],
    "inicio": "08:00",
    "fim": "18:00"
  }'::jsonb,
  
  -- Configurações de Resposta
  tempo_resposta_minutos integer NOT NULL DEFAULT 5,
  agente_ativo boolean NOT NULL DEFAULT true,
  
  -- URA (Unidade de Resposta Audível)
  ura_ativa boolean NOT NULL DEFAULT false,
  ura_config jsonb DEFAULT '{
    "boas_vindas": "Bem-vindo! Escolha uma opção:",
    "opcoes": [
      {"id": "1", "label": "Suporte Técnico", "acao": "transferir", "destino": "suporte"},
      {"id": "2", "label": "Comercial", "acao": "transferir", "destino": "comercial"},
      {"id": "3", "label": "Falar com Atendente", "acao": "transferir", "destino": "humano"}
    ],
    "tempo_espera": 30
  }'::jsonb,
  
  -- Timestamps
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  
  -- Constraints
  CONSTRAINT valid_horario CHECK (
    (horario_funcionamento->>'inicio') ~ '^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$' AND
    (horario_funcionamento->>'fim') ~ '^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$'
  )
);

-- RLS
ALTER TABLE public.crm_chat_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Empresa pode ver config" ON public.crm_chat_config
  FOR SELECT USING (empresa_id IN (
    SELECT empresa_id FROM public.usuario_empresas WHERE usuario_id = auth.uid()
  ));

CREATE POLICY "Admin pode modificar config" ON public.crm_chat_config
  FOR ALL USING (empresa_id IN (
    SELECT empresa_id FROM public.usuario_empresas 
    WHERE usuario_id = auth.uid() AND papel = 'admin'
  ));

-- Trigger updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_crm_chat_config_updated_at
  BEFORE UPDATE ON public.crm_chat_config
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Index
CREATE INDEX idx_crm_chat_config_empresa ON public.crm_chat_config(empresa_id);

-- Comentários
COMMENT ON TABLE public.crm_chat_config IS 'Configurações do chat e agente virtual do CRM';
COMMENT ON COLUMN public.crm_chat_config.horario_funcionamento IS 'JSON com dias (array), inicio e fim (HH:mm)';
COMMENT ON COLUMN public.crm_chat_config.ura_config IS 'JSON com boas_vindas, opcoes (array) e tempo_espera';

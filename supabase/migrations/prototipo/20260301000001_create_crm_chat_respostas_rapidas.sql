-- Migration: 20260301000001_create_crm_chat_respostas_rapidas.sql
-- Sprint 10: Unificação CRM + Atendente
-- Cria tabela de respostas rápidas do chat

CREATE TABLE IF NOT EXISTS public.crm_chat_respostas_rapidas (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  empresa_id uuid NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
  
  -- Conteúdo
  titulo varchar(100) NOT NULL,
  conteudo text NOT NULL,
  atalho varchar(50), -- Ex: "/suporte"
  
  -- Categoria
  categoria varchar(50) DEFAULT 'geral',
  cor_tag varchar(7) DEFAULT '#6B7280', -- Hex color
  
  -- Ordenação
  ordem integer NOT NULL DEFAULT 0,
  
  -- Status
  ativo boolean NOT NULL DEFAULT true,
  
  -- Timestamps
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid REFERENCES auth.users(id)
);

-- RLS
ALTER TABLE public.crm_chat_respostas_rapidas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Empresa pode ver respostas" ON public.crm_chat_respostas_rapidas
  FOR SELECT USING (empresa_id IN (
    SELECT empresa_id FROM public.usuario_empresas WHERE usuario_id = auth.uid()
  ));

CREATE POLICY "Admin/Atendente pode gerenciar" ON public.crm_chat_respostas_rapidas
  FOR ALL USING (empresa_id IN (
    SELECT empresa_id FROM public.usuario_empresas 
    WHERE usuario_id = auth.uid() AND papel IN ('admin', 'atendente', 'gerente')
  ));

-- Trigger
CREATE TRIGGER update_crm_chat_respostas_rapidas_updated_at
  BEFORE UPDATE ON public.crm_chat_respostas_rapidas
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Indexes
CREATE INDEX idx_crm_chat_respostas_empresa ON public.crm_chat_respostas_rapidas(empresa_id);
CREATE INDEX idx_crm_chat_respostas_ativo ON public.crm_chat_respostas_rapidas(ativo);
CREATE INDEX idx_crm_chat_respostas_ordem ON public.crm_chat_respostas_rapidas(ordem);

-- Comentários
COMMENT ON TABLE public.crm_chat_respostas_rapidas IS 'Respostas rápidas pré-cadastradas para o chat';
COMMENT ON COLUMN public.crm_chat_respostas_rapidas.atalho IS 'Atalho para inserir a resposta (ex: /suporte)';

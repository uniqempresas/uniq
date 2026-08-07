-- Migration: Módulo Atendente UNIQ - Sprint 09
-- Data: 2025-02-24
-- Descrição: Cria tabelas para o sistema de atendimento via WhatsApp

-- ============================================
-- TABELA: atd_config (Configuração do Atendente)
-- ============================================
CREATE TABLE IF NOT EXISTS atd_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID REFERENCES me_empresa(id) ON DELETE CASCADE,
  agent_name VARCHAR(100) NOT NULL DEFAULT 'Atendente UNIQ',
  agent_personality TEXT,
  mode VARCHAR(10) CHECK (mode IN ('ura', 'agent')) DEFAULT 'ura',
  avatar_url TEXT,
  
  -- Configurações comuns
  welcome_message TEXT DEFAULT 'Olá! Bem-vindo à {nome_empresa}. Como posso ajudar?',
  away_message TEXT DEFAULT 'Nosso horário de atendimento é {horario}. Retornaremos em breve!',
  business_hours JSONB DEFAULT '{"mon":{"open":"09:00","close":"18:00"},"tue":{"open":"09:00","close":"18:00"},"wed":{"open":"09:00","close":"18:00"},"thu":{"open":"09:00","close":"18:00"},"fri":{"open":"09:00","close":"18:00"},"sat":{"open":"09:00","close":"12:00"},"sun":null}',
  phone_number VARCHAR(20),
  evolution_instance_id VARCHAR(100),
  
  -- Config URA (Modelo 1)
  ura_rules JSONB DEFAULT '[]',
  
  -- Config Agente (Modelo 2)
  n8n_workflow_id VARCHAR(100),
  
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'paused')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT unique_empresa_config UNIQUE (id_empresa)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_atd_config_empresa ON atd_config(id_empresa);
CREATE INDEX IF NOT EXISTS idx_atd_config_status ON atd_config(status);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_atd_config_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_atd_config_updated_at ON atd_config;
CREATE TRIGGER trigger_atd_config_updated_at
  BEFORE UPDATE ON atd_config
  FOR EACH ROW
  EXECUTE FUNCTION update_atd_config_updated_at();

-- ============================================
-- TABELA: atd_conversas (Conversas)
-- ============================================
CREATE TABLE IF NOT EXISTS atd_conversas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID REFERENCES me_empresa(id) ON DELETE CASCADE,
  id_cliente UUID REFERENCES me_cliente(id) ON DELETE SET NULL,
  remote_phone VARCHAR(20) NOT NULL,
  remote_name VARCHAR(100),
  status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'pending', 'resolved', 'archived')),
  assigned_to UUID REFERENCES me_usuario(id) ON DELETE SET NULL,
  last_message_at TIMESTAMPTZ,
  last_message_preview TEXT,
  unread_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_atd_conversas_empresa ON atd_conversas(id_empresa);
CREATE INDEX IF NOT EXISTS idx_atd_conversas_status ON atd_conversas(status);
CREATE INDEX IF NOT EXISTS idx_atd_conversas_last_message ON atd_conversas(last_message_at DESC NULLS LAST);
CREATE INDEX IF NOT EXISTS idx_atd_conversas_phone ON atd_conversas(remote_phone);
CREATE INDEX IF NOT EXISTS idx_atd_conversas_cliente ON atd_conversas(id_cliente);

-- Trigger para atualizar updated_at
DROP TRIGGER IF EXISTS trigger_atd_conversas_updated_at ON atd_conversas;
CREATE TRIGGER trigger_atd_conversas_updated_at
  BEFORE UPDATE ON atd_conversas
  FOR EACH ROW
  EXECUTE FUNCTION update_atd_config_updated_at();

-- ============================================
-- TABELA: atd_mensagens (Mensagens)
-- ============================================
CREATE TABLE IF NOT EXISTS atd_mensagens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_conversa UUID REFERENCES atd_conversas(id) ON DELETE CASCADE,
  direction VARCHAR(3) CHECK (direction IN ('in', 'out')),
  sender_type VARCHAR(10) CHECK (sender_type IN ('client', 'agent', 'system', 'bot')),
  sender_id UUID REFERENCES me_usuario(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  media_url TEXT,
  media_type VARCHAR(50),
  message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'audio', 'document', 'location', 'video')),
  external_id VARCHAR(100),
  read_at TIMESTAMPTZ,
  is_automated BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_atd_mensagens_conversa ON atd_mensagens(id_conversa);
CREATE INDEX IF NOT EXISTS idx_atd_mensagens_created_at ON atd_mensagens(created_at);
CREATE INDEX IF NOT EXISTS idx_atd_mensagens_external_id ON atd_mensagens(external_id);

-- ============================================
-- TABELA: atd_respostas_rapidas (Respostas Rápidas)
-- ============================================
CREATE TABLE IF NOT EXISTS atd_respostas_rapidas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_empresa UUID REFERENCES me_empresa(id) ON DELETE CASCADE,
  shortcut VARCHAR(50) NOT NULL,
  content TEXT NOT NULL,
  category VARCHAR(50),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT unique_shortcut_empresa UNIQUE (id_empresa, shortcut)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_atd_respostas_empresa ON atd_respostas_rapidas(id_empresa);
CREATE INDEX IF NOT EXISTS idx_atd_respostas_category ON atd_respostas_rapidas(category);

-- Trigger para atualizar updated_at
DROP TRIGGER IF EXISTS trigger_atd_respostas_updated_at ON atd_respostas_rapidas;
CREATE TRIGGER trigger_atd_respostas_updated_at
  BEFORE UPDATE ON atd_respostas_rapidas
  FOR EACH ROW
  EXECUTE FUNCTION update_atd_config_updated_at();

-- ============================================
-- RLS POLICIES (Desabilitadas para MVP)
-- ============================================
-- Desabilitando RLS para facilitar desenvolvimento no MVP
-- Serão habilitadas em produção

ALTER TABLE atd_config DISABLE ROW LEVEL SECURITY;
ALTER TABLE atd_conversas DISABLE ROW LEVEL SECURITY;
ALTER TABLE atd_mensagens DISABLE ROW LEVEL SECURITY;
ALTER TABLE atd_respostas_rapidas DISABLE ROW LEVEL SECURITY;

-- ============================================
-- FUNÇÕES AUXILIARES
-- ============================================

-- Função para atualizar last_message_at e unread_count na conversa
CREATE OR REPLACE FUNCTION update_conversation_on_new_message()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.direction = 'in' THEN
    UPDATE atd_conversas
    SET 
      last_message_at = NEW.created_at,
      last_message_preview = LEFT(NEW.content, 100),
      unread_count = unread_count + 1,
      updated_at = NOW()
    WHERE id = NEW.id_conversa;
  ELSE
    UPDATE atd_conversas
    SET 
      last_message_at = NEW.created_at,
      last_message_preview = LEFT(NEW.content, 100),
      updated_at = NOW()
    WHERE id = NEW.id_conversa;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar conversa quando nova mensagem é inserida
DROP TRIGGER IF EXISTS trigger_update_conversation_on_message ON atd_mensagens;
CREATE TRIGGER trigger_update_conversation_on_message
  AFTER INSERT ON atd_mensagens
  FOR EACH ROW
  EXECUTE FUNCTION update_conversation_on_new_message();

-- Função para marcar mensagens como lidas
CREATE OR REPLACE FUNCTION mark_messages_as_read(p_conversa_id UUID, p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE atd_mensagens
  SET read_at = NOW()
  WHERE id_conversa = p_conversa_id
    AND direction = 'in'
    AND read_at IS NULL;
    
  UPDATE atd_conversas
  SET unread_count = 0
  WHERE id = p_conversa_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMENTÁRIOS
-- ============================================
COMMENT ON TABLE atd_config IS 'Configuração do atendente virtual por empresa';
COMMENT ON TABLE atd_conversas IS 'Conversas de WhatsApp agrupadas por cliente';
COMMENT ON TABLE atd_mensagens IS 'Mensagens individuais das conversas';
COMMENT ON TABLE atd_respostas_rapidas IS 'Atalhos de respostas rápidas configuráveis';

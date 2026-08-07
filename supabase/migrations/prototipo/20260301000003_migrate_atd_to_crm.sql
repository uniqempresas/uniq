-- Migration: 20260301000003_migrate_atd_to_crm.sql
-- Sprint 10: Unificação CRM + Atendente
-- Migra dados do módulo Atendente (atd_*) para CRM (crm_chat_*)

-- Criar tabela de log de migração
CREATE TABLE IF NOT EXISTS public._migracao_atd_log (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tabela_origem varchar(50) NOT NULL,
  tabela_destino varchar(50) NOT NULL,
  registros_processados integer DEFAULT 0,
  registros_erro integer DEFAULT 0,
  started_at timestamptz DEFAULT now(),
  completed_at timestamptz,
  erro_detalhes jsonb DEFAULT '[]'::jsonb
);

-- Função de migração
CREATE OR REPLACE FUNCTION public.migrar_atd_para_crm(p_empresa_id uuid DEFAULT NULL)
RETURNS TABLE (
  tabela varchar,
  registros_migrados bigint,
  status varchar
) AS $$
DECLARE
  v_log_id uuid;
  v_count bigint;
BEGIN
  -- Iniciar log
  INSERT INTO public._migracao_atd_log (tabela_origem, tabela_destino)
  VALUES ('atd_conversas', 'crm_chat_conversas')
  RETURNING id INTO v_log_id;
  
  -- 1. Migrar conversas
  WITH migracao_conversas AS (
    INSERT INTO public.crm_chat_conversas (
      id, empresa_id, contato_id, status, 
      canal, canal_id, created_at, updated_at
    )
    SELECT 
      ac.id,
      ac.empresa_id,
      ac.cliente_id as contato_id,
      CASE 
        WHEN ac.status = 'aberta' THEN 'em_andamento'
        WHEN ac.status = 'fechada' THEN 'resolvido'
        ELSE ac.status
      END::crm_chat_status,
      'whatsapp' as canal,
      ac.whatsapp_numero as canal_id,
      ac.created_at,
      COALESCE(ac.ultima_mensagem_em, ac.updated_at)
    FROM public.atd_conversas ac
    WHERE (p_empresa_id IS NULL OR ac.empresa_id = p_empresa_id)
      AND NOT EXISTS (
        SELECT 1 FROM public.crm_chat_conversas cc 
        WHERE cc.id = ac.id
      )
    RETURNING id
  )
  SELECT count(*) INTO v_count FROM migracao_conversas;
  
  RETURN QUERY SELECT 'crm_chat_conversas'::varchar, v_count, 'SUCCESS'::varchar;
  
  -- 2. Migrar mensagens
  WITH migracao_mensagens AS (
    INSERT INTO public.crm_chat_mensagens (
      id, conversa_id, remetente, tipo, 
      conteudo, arquivo_url, created_at
    )
    SELECT 
      am.id,
      am.conversa_id,
      CASE 
        WHEN am.remetente = 'cliente' THEN 'contato'
        WHEN am.remetente = 'atendente' THEN 'usuario'
        ELSE am.remetente
      END::crm_chat_remetente,
      COALESCE(am.tipo, 'texto')::crm_chat_tipo_mensagem,
      am.conteudo,
      am.arquivo_url,
      am.created_at
    FROM public.atd_mensagens am
    INNER JOIN public.atd_conversas ac ON am.conversa_id = ac.id
    WHERE (p_empresa_id IS NULL OR ac.empresa_id = p_empresa_id)
      AND NOT EXISTS (
        SELECT 1 FROM public.crm_chat_mensagens cm 
        WHERE cm.id = am.id
      )
    RETURNING id
  )
  SELECT count(*) INTO v_count FROM migracao_mensagens;
  
  RETURN QUERY SELECT 'crm_chat_mensagens'::varchar, v_count, 'SUCCESS'::varchar;
  
  -- Atualizar log
  UPDATE public._migracao_atd_log 
  SET completed_at = now(),
      registros_processados = (SELECT count(*) FROM public.crm_chat_conversas WHERE canal = 'whatsapp')
  WHERE id = v_log_id;
  
EXCEPTION WHEN OTHERS THEN
  UPDATE public._migracao_atd_log 
  SET completed_at = now(),
      erro_detalhes = jsonb_build_array(jsonb_build_object('error', SQLERRM))
  WHERE id = v_log_id;
  
  RETURN QUERY SELECT 'ERROR'::varchar, 0::bigint, SQLERRM::varchar;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comentários
COMMENT ON TABLE public._migracao_atd_log IS 'Log de auditoria da migração do módulo Atendente para CRM';
COMMENT ON FUNCTION public.migrar_atd_para_crm(uuid) IS 'Migra dados das tabelas atd_* para crm_chat_*. Passar empresa_id para migrar uma empresa específica, ou NULL para todas.';

-- Instruções de uso:
-- Migrar todas as empresas: SELECT * FROM public.migrar_atd_para_crm();
-- Migrar empresa específica: SELECT * FROM public.migrar_atd_para_crm('uuid-da-empresa');

-- 🚨 DESATIVANDO SEGURANÇA (RLS) PARA O MVP
-- O objetivo é permitir que o frontend funcione sem bloqueios de permissão por enquanto.
-- Segurança será implementada em sprint futura.

-- Core Tables
ALTER TABLE IF EXISTS public.me_empresa DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.me_usuario DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.me_cargo DISABLE ROW LEVEL SECURITY;

-- Module Tables
ALTER TABLE IF EXISTS public.me_modulo_ativo DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.me_modulo_cargo DISABLE ROW LEVEL SECURITY;

-- Business Data Tables
ALTER TABLE IF EXISTS public.me_produto DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.me_servico DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.me_cliente DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.me_fornecedor DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.me_colaborador DISABLE ROW LEVEL SECURITY;

-- Product Related
ALTER TABLE IF EXISTS public.me_produto_variacao DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.me_produto_imagem DISABLE ROW LEVEL SECURITY;

-- Service Related
ALTER TABLE IF EXISTS public.me_servico_imagem DISABLE ROW LEVEL SECURITY;

-- Finance Related (if exists)
ALTER TABLE IF EXISTS public.me_contas_pagar DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.me_contas_receber DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.me_transacao DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.me_categoria_financeira DISABLE ROW LEVEL SECURITY;

-- CRM Related (if exists)
ALTER TABLE IF EXISTS public.crm_oportunidade DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.crm_funil DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.crm_etapa DISABLE ROW LEVEL SECURITY;

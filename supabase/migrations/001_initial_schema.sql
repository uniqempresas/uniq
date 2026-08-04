-- 001_initial_schema.sql
-- Schema inicial da Base UNIQ

-- ============================================================
-- Tabela: parceiros
-- ============================================================
CREATE TABLE IF NOT EXISTS public.parceiros (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  email TEXT,
  telefone TEXT,
  status TEXT NOT NULL DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo', 'suspenso')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.parceiros ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- Tabela: usuarios
-- ============================================================
CREATE TABLE IF NOT EXISTS public.usuarios (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  parceiro_id UUID REFERENCES public.parceiros(id) ON DELETE SET NULL,
  email TEXT UNIQUE NOT NULL,
  nome TEXT,
  papel TEXT NOT NULL DEFAULT 'parceiro' CHECK (papel IN ('parceiro', 'admin', 'master')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- Tabela: modulos
-- ============================================================
CREATE TABLE IF NOT EXISTS public.modulos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  descricao TEXT,
  icone TEXT,
  ordem INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.modulos ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- Tabela: parceiro_modulos
-- ============================================================
CREATE TABLE IF NOT EXISTS public.parceiro_modulos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parceiro_id UUID NOT NULL REFERENCES public.parceiros(id) ON DELETE CASCADE,
  modulo_id UUID NOT NULL REFERENCES public.modulos(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pendente' CHECK (status IN ('pendente', 'ativo', 'inativo', 'expirado')),
  ativado_em TIMESTAMPTZ,
  expira_em TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (parceiro_id, modulo_id)
);

ALTER TABLE public.parceiro_modulos ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- Políticas RLS
-- ============================================================

-- Usuários: cada usuário vê apenas seu próprio registro
CREATE POLICY "Usuários podem ver seu próprio registro"
  ON public.usuarios
  FOR SELECT
  USING (auth.uid() = id);

-- Usuários: admins do mesmo parceiro podem ver (futuro)
CREATE POLICY "Usuários do mesmo parceiro podem ver"
  ON public.usuarios
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.usuarios u
      WHERE u.id = auth.uid()
        AND u.parceiro_id = usuarios.parceiro_id
        AND u.papel IN ('admin', 'master')
    )
  );

-- Parceiro Módulos: acesso baseado no parceiro_id do usuário logado
CREATE POLICY "Parceiro módulos visíveis para usuários do mesmo parceiro"
  ON public.parceiro_modulos
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.usuarios u
      WHERE u.id = auth.uid()
        AND u.parceiro_id = parceiro_modulos.parceiro_id
    )
  );

CREATE POLICY "Parceiro módulos editáveis por admins do parceiro"
  ON public.parceiro_modulos
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.usuarios u
      WHERE u.id = auth.uid()
        AND u.parceiro_id = parceiro_modulos.parceiro_id
        AND u.papel IN ('admin', 'master')
    )
  );

-- Módulos: leitura pública para usuários autenticados
CREATE POLICY "Módulos visíveis para usuários autenticados"
  ON public.modulos
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Parceiros: acesso apenas por admins/masters do próprio parceiro
CREATE POLICY "Parceiros visíveis para usuários do mesmo parceiro"
  ON public.parceiros
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.usuarios u
      WHERE u.id = auth.uid()
        AND u.parceiro_id = parceiros.id
    )
  );

-- ============================================================
-- Seed: Módulos padrão
-- ============================================================
INSERT INTO public.modulos (nome, slug, descricao, icone, ordem) VALUES
  ('Atendente', 'atendente', 'Atendimento automatizado com Melissa para WhatsApp e Instagram', 'headset', 1),
  ('CRM Leve', 'crm-leve', 'Gestão simples de leads e clientes', 'users', 2),
  ('Mídias Sociais', 'midias-sociais', 'Gerenciamento de posts e interações em redes sociais', 'share2', 3),
  ('ERP Básico', 'erp-basico', 'Controle de produtos, serviços e finanças', 'database', 4),
  ('Agenda', 'agenda', 'Agendamento de compromissos e serviços', 'calendar', 5),
  ('Site/Landing Page', 'site-landing-page', 'Site institucional ou landing page do negócio', 'globe', 6),
  ('Trilhas', 'trilhas', 'Trilhas de desenvolvimento para o empreendedor', 'compass', 7)
ON CONFLICT (slug) DO NOTHING;

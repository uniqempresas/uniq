-- 🚨 VERSÃO 2: CORREÇÃO DA TABELA E POLÍTICAS (SEM DEPENDER DE DONO_ID)
-- O objetivo é corrigir a tabela me_modulo_ativo e ajustar as permissões baseadas APENAS no cargo.

-- 1. Remover a tabela incorreta/antiga (caso exista a versão errada ou a certa com política errada)
DROP TABLE IF EXISTS public.me_modulo_ativo CASCADE;

-- 2. Recriar a tabela correta
CREATE TABLE public.me_modulo_ativo (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    empresa_id uuid NOT NULL REFERENCES public.me_empresa(id) ON DELETE CASCADE,
    modulo_codigo text NOT NULL,
    ativo boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(empresa_id, modulo_codigo)
);

-- 3. Habilitar RLS
ALTER TABLE public.me_modulo_ativo ENABLE ROW LEVEL SECURITY;

-- 4. Criar Política de Leitura (Todos da empresa podem ver)
CREATE POLICY "Membros podem ver modulos ativos"
ON public.me_modulo_ativo
FOR SELECT
USING (
    empresa_id IN (
        SELECT empresa_id 
        FROM public.me_usuario 
        WHERE id = auth.uid()
    )
);

-- 5. Criar Política de Escrita (Apenas Cargos 'Dono' ou 'Admin' podem gerenciar)
CREATE POLICY "Dono e Admin podem gerenciar modulos"
ON public.me_modulo_ativo
FOR ALL
USING (
    EXISTS (
        SELECT 1 
        FROM public.me_usuario u
        JOIN public.me_cargo c ON c.id = u.cargo
        WHERE u.id = auth.uid()
        AND u.empresa_id = public.me_modulo_ativo.empresa_id
        AND (
            c.nome_cargo ILIKE 'dono' 
            OR 
            c.nome_cargo ILIKE 'admin'
        )
    )
);

-- 6. Índices
CREATE INDEX idx_me_modulo_ativo_empresa_id ON public.me_modulo_ativo(empresa_id);

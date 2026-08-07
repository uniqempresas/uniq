-- Create table me_modulo_ativo
CREATE TABLE IF NOT EXISTS public.me_modulo_ativo (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    empresa_id uuid NOT NULL REFERENCES public.me_empresa(id) ON DELETE CASCADE,
    modulo_codigo text NOT NULL,
    ativo boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(empresa_id, modulo_codigo)
);

-- RLS Policies
ALTER TABLE public.me_modulo_ativo ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone in the company can view active modules
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

-- Policy: Only owners (dono) can manage modules
-- Checking if user is the owner of the company in me_empresa
CREATE POLICY "Apenas Donos podem gerenciar modulos"
ON public.me_modulo_ativo
FOR ALL
USING (
    EXISTS (
        SELECT 1 
        FROM public.me_empresa e
        WHERE e.id = public.me_modulo_ativo.empresa_id
        AND e.dono_id = auth.uid()
    )
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_me_modulo_ativo_empresa_id ON public.me_modulo_ativo(empresa_id);

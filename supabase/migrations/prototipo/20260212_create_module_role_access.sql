-- Create table me_modulo_cargo
CREATE TABLE IF NOT EXISTS public.me_modulo_cargo (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    empresa_id uuid NOT NULL REFERENCES public.me_empresa(id) ON DELETE CASCADE,
    cargo_id integer NOT NULL REFERENCES public.me_cargo(id) ON DELETE CASCADE,
    modulo_codigo text NOT NULL,
    ativo boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    UNIQUE(empresa_id, cargo_id, modulo_codigo)
);

-- RLS Policies
ALTER TABLE public.me_modulo_cargo ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone in the company can view module permissions
CREATE POLICY "Membros podem ver permissoes de modulos"
ON public.me_modulo_cargo
FOR SELECT
USING (
    empresa_id IN (
        SELECT u.empresa_id 
        FROM public.me_usuario u
        WHERE u.id = auth.uid()
    )
);

-- Policy: Only owners (dono) can manage module permissions
CREATE POLICY "Apenas Donos podem gerenciar permissoes de modulos"
ON public.me_modulo_cargo
FOR ALL
USING (
    EXISTS (
        SELECT 1 
        FROM public.me_usuario u
        JOIN public.me_cargo c ON c.id = u.cargo
        WHERE u.id = auth.uid()
        AND u.empresa_id = public.me_modulo_cargo.empresa_id
        AND c.nome_cargo ILIKE 'dono'
    )
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_me_modulo_cargo_empresa_cargo ON public.me_modulo_cargo(empresa_id, cargo_id);

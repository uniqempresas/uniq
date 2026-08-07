-- POLICY FIX: Allow 'Dono' and 'Admin' roles to manage active modules
-- Currently only the company creator (dono_id) can manage them.

DROP POLICY IF EXISTS "Apenas Donos podem gerenciar modulos" ON public.me_modulo_ativo;

CREATE POLICY "Dono e Admin podem gerenciar modulos"
ON public.me_modulo_ativo
FOR ALL
USING (
    EXISTS (
        SELECT 1 
        FROM public.me_usuario u
        LEFT JOIN public.me_cargo c ON c.id = u.cargo
        WHERE u.id = auth.uid()
        AND u.empresa_id = public.me_modulo_ativo.empresa_id
        AND (
            -- Permitir se for o Dono da Empresa (criador)
            EXISTS (SELECT 1 FROM public.me_empresa e WHERE e.id = u.empresa_id AND e.dono_id = u.id)
            OR 
            -- Permitir se tiver cargo de Dono ou Admin
            c.nome_cargo ILIKE 'dono'
            OR
            c.nome_cargo ILIKE 'admin'
        )
    )
);

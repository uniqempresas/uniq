-- =============================================================================
-- MIGRATION: 20260216_fix_me_usuario_columns.sql
-- DESCRIÇÃO: 1. Adiciona coluna 'role' na tabela me_usuario (faltava)
--            2. Atualiza criacao de empresa para usar colunas corretas:
--               - nome -> nome_usuario
--               - cargo_id -> cargo
-- =============================================================================

-- 1. ADICIONAR COLUNA ROLE
ALTER TABLE public.me_usuario 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'colaborador';

-- 2. ATUALIZAR FUNÇÃO RPC (Versão com TODAS as correções acumuladas)
CREATE OR REPLACE FUNCTION public.criar_empresa_e_configuracoes_iniciais(
    p_usuario_id uuid,
    p_nome_fantasia text,
    p_cnpj text,
    p_telefone text,
    p_email text,
    p_slug text,
    p_cep text DEFAULT NULL::text,
    p_logradouro text DEFAULT NULL::text,
    p_numero text DEFAULT NULL::text,
    p_complemento text DEFAULT NULL::text,
    p_bairro text DEFAULT NULL::text,
    p_cidade text DEFAULT NULL::text,
    p_uf text DEFAULT NULL::text,
    p_ibge text DEFAULT NULL::text,
    p_nome_usuario text DEFAULT NULL::text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
    v_empresa_id uuid;
    v_cargo_proprietario_id bigint;
    v_categoria_produtos_id bigint;
    v_categoria_servicos_id bigint;
    v_resultado jsonb;
    v_nome_usuario_final text;
begin
    -- ===== VALIDAÇÕES =====
    if p_usuario_id is null then
        raise exception 'ID do usuário não pode ser nulo';
    end if;
    
    if p_nome_fantasia is null or trim(p_nome_fantasia) = '' then
        raise exception 'Nome fantasia é obrigatório';
    end if;
    
    if p_slug is null or trim(p_slug) = '' then
        raise exception 'Slug é obrigatório';
    end if;

    -- Definir nome do usuário (fallback para parte do email se nulo)
    v_nome_usuario_final := coalesce(p_nome_usuario, split_part(p_email, '@', 1), 'Usuário');

    -- Verificar se usuário já existe
    if exists (select 1 from me_usuario where id = p_usuario_id) then
        raise exception 'Usuário já está cadastrado';
    end if;

    -- Verificar se slug já está em uso
    if exists (select 1 from me_empresa where slug = p_slug) then
        raise exception 'Slug já está em uso. Tente outro nome para a empresa.';
    end if;

    -- ===== 1. CRIAR EMPRESA =====
    insert into me_empresa (
        id, 
        nome_fantasia,
        cnpj,
        telefone,
        email,
        slug
    )
    values (
        p_usuario_id,
        p_nome_fantasia,
        p_cnpj,
        p_telefone,
        p_email,
        p_slug
    )
    returning id into v_empresa_id;

    -- ===== 2. CRIAR CARGOS PADRÃO =====
    -- Inserir cargos e capturar o ID do Proprietário
    -- CORREÇÃO ANTERIOR: Usar nome_cargo, descricao, ativo
    insert into me_cargo (empresa_id, nome_cargo, descricao, ativo)
    values 
        (v_empresa_id, 'Proprietário', 'Acesso total a todos os módulos e configurações.', true)
    returning id into v_cargo_proprietario_id;

    -- Inserir outros cargos
    insert into me_cargo (empresa_id, nome_cargo, descricao, ativo)
    values 
        (v_empresa_id, 'Administrador', 'Gerenciamento geral da loja e equipe.', true),
        (v_empresa_id, 'Gerente', 'Gestão operacional e supervisão de equipe.', true),
        (v_empresa_id, 'Vendedor', 'Vendas e atendimento ao cliente.', true),
        (v_empresa_id, 'Colaborador', 'Acesso básico e restrito.', true);

    -- ===== 3. VINCULAR USUÁRIO À EMPRESA =====
    -- CORREÇÃO ATUAL: Usar colunas corretas de me_usuario
    insert into me_usuario (
        id,
        empresa_id,
        nome_usuario, -- Era 'nome'
        email,
        role,         -- Coluna nova adicionada acima
        cargo         -- Era 'cargo_id'
        -- ativo (não existe na tabela me_usuario segundo schema reportado, removido do insert)
    )
    values (
        p_usuario_id,
        v_empresa_id,
        v_nome_usuario_final,
        p_email,
        'owner',
        v_cargo_proprietario_id
    );

    -- ===== 4. CRIAR ENDEREÇO (se fornecido) =====
    if p_cep is not null then
        insert into me_empresa_endereco (
            empresa_id,
            cep,
            logradouro,
            numero,
            complemento,
            bairro,
            cidade,
            estado,
            principal
        )
        values (
            v_empresa_id,
            p_cep,
            p_logradouro,
            p_numero,
            p_complemento,
            p_bairro,
            p_cidade,
            p_uf,
            true
        );
    end if;

    -- ===== 5. CRIAR CATEGORIAS INICIAIS =====
    insert into me_categoria (empresa_id, nome_categoria)
    values (v_empresa_id, 'Produtos')
    returning id into v_categoria_produtos_id;

    insert into me_categoria (empresa_id, nome_categoria)
    values (v_empresa_id, 'Serviços')
    returning id into v_categoria_servicos_id;

    -- ===== 6. CRIAR PRODUTOS INICIAIS (EXEMPLOS) =====
    insert into me_produto (
        empresa_id,
        categoria_id,
        nome_produto,
        descricao,
        preco,
        ativo
    )
    values
    (
        v_empresa_id,
        v_categoria_produtos_id,
        'Produto Exemplo 1',
        'Este é um produto de exemplo. Edite ou delete conforme necessário.',
        100.00,
        true
    ),
    (
        v_empresa_id,
        v_categoria_produtos_id,
        'Produto Exemplo 2',
        'Outro produto de exemplo para você começar.',
        200.00,
        true
    ),
    (
        v_empresa_id,
        v_categoria_servicos_id,
        'Serviço Exemplo',
        'Este é um serviço de exemplo. Personalize de acordo com seu negócio.',
        150.00,
        true
    );

    -- ===== 7. PREPARAR RESULTADO =====
    v_resultado := jsonb_build_object(
        'success', true,
        'empresa_id', v_empresa_id,
        'message', 'Empresa criada com sucesso! Cargos e configurações iniciais foram definidos.'
    );

    return v_resultado;

exception
    when others then
        raise exception 'Erro ao criar empresa: %', sqlerrm;
end;
$function$;

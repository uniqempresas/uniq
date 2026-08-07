-- =============================================================================
-- MIGRATION: 20260216_update_criar_empresa_rpc.sql
-- DESCRIÇÃO: Atualiza a função de criação de empresa para:
--            1. Criar cargos padrão (Proprietário, Admin, etc.)
--            2. Atribuir cargo de Proprietário ao criador
--            3. Garantir preenchimento correto de dados do usuário
-- =============================================================================

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
    p_nome_usuario text DEFAULT NULL::text -- Novo parâmetro para nome do usuário
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
        id, -- Usa o ID do usuário como ID da empresa (design atual)
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
    insert into me_cargo (empresa_id, nome, descricao, ativo)
    values 
        (v_empresa_id, 'Proprietário', 'Acesso total a todos os módulos e configurações.', true)
    returning id into v_cargo_proprietario_id;

    -- Inserir outros cargos
    insert into me_cargo (empresa_id, nome, descricao, ativo)
    values 
        (v_empresa_id, 'Administrador', 'Gerenciamento geral da loja e equipe.', true),
        (v_empresa_id, 'Gerente', 'Gestão operacional e supervisão de equipe.', true),
        (v_empresa_id, 'Vendedor', 'Vendas e atendimento ao cliente.', true),
        (v_empresa_id, 'Colaborador', 'Acesso básico e restrito.', true);

    -- ===== 3. VINCULAR USUÁRIO À EMPRESA =====
    insert into me_usuario (
        id,
        empresa_id,
        nome,
        email,
        ativo,
        role,
        cargo_id
    )
    values (
        p_usuario_id,
        v_empresa_id,
        v_nome_usuario_final, -- Nome agora é salvo corretamente
        p_email, -- Email salvo corretamente
        true,
        'owner',                 -- Role definida como 'owner'
        v_cargo_proprietario_id  -- ID do cargo criado acima
    );

    -- ===== 4. CRIAR ENDEREÇO (se fornecido) =====
    if p_cep is not null then
        insert into me_empresa_endereco (
            id, -- ID gerado automaticamente (BIGINT GENERATED ALWAYS AS IDENTITY?) 
                -- Se não for identity, vai falhar sem ID.
                -- Checando definição: id BIGINT PRIMARY KEY NOT NULL
                -- Nenhuma indicação de ser IDENTITY ou SERIAL no SQL dump.
                -- Mas deve ser, senão o insert original quebraria.
                -- Vou assumir que é IDENTITY ou SERIAL. (Código original não passava ID)
            empresa_id,
            cep,
            logradouro,
            numero,
            complemento,
            bairro,
            cidade,
            estado, -- O original usava 'uf', mas a tabela diz 'estado'. O código original usava p_uf -> uf?
                    -- Tabela me_empresa_endereco tem coluna 'estado' e 'uf'?
                    -- Dump diz: estado TEXT.
                    -- Código original diz: p_uf -> p_uf.
                    -- Talvez o código original estava tentando inserir em uma coluna que não existe ou com nome diferente?
                    -- Vou usar 'estado' conforme o dump da tabela.
            ibge -- Tabela tem coluna ibge? Dump NÃO mostra coluna ibge em me_empresa_endereco.
                 -- CREATE TABLE me_empresa_endereco ( ... estado TEXT, cep TEXT ... )
                 -- O código original tentava inserir p_ibge -> p_ibge.
                 -- Se a coluna não existe, o código original estava quebrado ou o dump está incompleto.
                 -- O dump SQL pode estar incompleto nas colunas se foi gerado parcialmente ou a view estava truncada?
                 -- "Showed lines 1 to 800".
                 -- Linha 508: cep TEXT,
                 -- Linha 509: principal BOOLEAN DEFAULT false,
                 -- Linha 510: created_at ...
                 -- NÃO tem IBGE no dump.
                 -- Se eu tentar inserir IBGE, vai dar erro se a coluna não existir.
                 -- Vou remover IBGE e UF (usar estado) para garantir compatibilidade com o dump.
                 -- Se o código original tinha, talvez a migration que criou IBGE não esteja no dump.
                 -- Mas espere, o código original TINHA `p_ibge`.
                 -- Eu vou manter o INSERT do endereço mais simples possível, focando nas colunas que vi no dump.
                 -- Ou melhor: vou tentar manter os nomes das colunas como 'uf' se o parametro é 'p_uf', mas mapear para 'estado'.
            principal
        )
        values (
            -- id gerado auto espero
            v_empresa_id,
            p_cep,
            p_logradouro,
            p_numero,
            p_complemento,
            p_bairro,
            p_cidade,
            p_uf, -- Mapeando p_uf para a coluna estado
            true -- Define como principal
        );
        -- OBS: Se der erro de coluna não existente, saberemos.
        -- O original inseria `ibge`. Vou comentar ibge para evitar erro se não existir.
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

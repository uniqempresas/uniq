-- =============================================================================
-- MIGRATION: 20260216_insert_sales_module.sql
-- DESCRIÇÃO: Insere o módulo 'sales' que está faltando e quebra o onboarding.
-- =============================================================================

INSERT INTO public.unq_modulos_sistema (
    id,
    codigo,
    nome,
    descricao,
    preco_mensal,
    preco_anual,
    categoria,
    versao,
    status
)
VALUES (
    '00000000-0000-0000-0000-00000000000f', -- ID fixo para consistência
    'sales',
    'Vendas / PDV',
    'Frente de caixa, orçamentos e pedidos de venda.',
    49.90,
    499.00,
    'Vendas',
    '1.0.0',
    'active'
)
ON CONFLICT (codigo) DO NOTHING;

-- Migration: 20250217_create_registrar_venda_function.sql
-- Função RPC para registrar uma venda completa (venda + conta a receber em fn_movimento + atualização de estoque)

CREATE OR REPLACE FUNCTION registrar_venda(
  p_id_empresa uuid,
  p_id_cliente uuid DEFAULT NULL,
  p_valor_total numeric,
  p_forma_pagamento varchar,
  p_data_vencimento date DEFAULT NULL,
  p_itens jsonb DEFAULT '[]'::jsonb,
  p_observacoes text DEFAULT NULL,
  p_origem varchar DEFAULT 'interna'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_id_venda bigint;
  v_id_movimento bigint;
  v_item jsonb;
  v_descricao text;
  v_cliente_nome text;
  v_forma_pagamento_id bigint;
BEGIN
  -- Obter nome do cliente se existir
  IF p_id_cliente IS NOT NULL THEN
    SELECT nome_cliente INTO v_cliente_nome 
    FROM me_cliente 
    WHERE id = p_id_cliente AND empresa_id = p_id_empresa;
  END IF;
  
  -- Obter ID da forma de pagamento baseado no nome
  SELECT id INTO v_forma_pagamento_id
  FROM me_forma_pagamento
  WHERE nome ILIKE p_forma_pagamento
    AND empresa_id = p_id_empresa
  LIMIT 1;
  
  -- Se não encontrou, usa NULL (campo é opcional)
  
  -- 1. Inserir venda na tabela me_venda
  INSERT INTO me_venda (
    empresa_id,
    cliente_id,
    forma_pagamento,
    valor_total,
    observacoes,
    status_venda,
    canal_venda,
    criado_em,
    atualizado_em
  ) VALUES (
    p_id_empresa,
    p_id_cliente,
    v_forma_pagamento_id,
    p_valor_total,
    p_observacoes,
    'concluida',
    p_origem,
    NOW(),
    NOW()
  )
  RETURNING id INTO v_id_venda;
  
  -- Criar descrição com ID real
  v_descricao := 'Venda #' || v_id_venda::text || 
                 CASE WHEN v_cliente_nome IS NOT NULL 
                      THEN ' - ' || v_cliente_nome 
                      ELSE '' END;
  
  -- 2. Criar conta a receber na tabela fn_movimento (tipo = 'receita')
  INSERT INTO fn_movimento (
    empresa_id,
    tipo,
    descricao,
    valor,
    data_vencimento,
    status,
    cliente_id,
    observacao,
    venda_id,
    created_at
  ) VALUES (
    p_id_empresa,
    'receita',
    v_descricao,
    p_valor_total,
    COALESCE(p_data_vencimento, CURRENT_DATE + 30),
    'pendente',
    p_id_cliente,
    p_observacoes,
    v_id_venda,
    NOW()
  )
  RETURNING id INTO v_id_movimento;
  
  -- 3. Atualizar estoque dos produtos
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_itens)
  LOOP
    IF (v_item->>'tipo') = 'produto' THEN
      UPDATE me_produto 
      SET 
        estoque_atual = estoque_atual - COALESCE((v_item->>'quantidade')::numeric, 0),
        created_at = NOW()
      WHERE id = (v_item->>'id_referencia')::bigint 
        AND empresa_id = p_id_empresa;
    END IF;
  END LOOP;
  
  -- Retornar IDs criados
  RETURN jsonb_build_object(
    'success', true,
    'id_venda', v_id_venda,
    'id_conta_receber', v_id_movimento,
    'valor_total', p_valor_total
  );
  
EXCEPTION WHEN OTHERS THEN
  -- Retornar erro
  RETURN jsonb_build_object(
    'success', false,
    'error', SQLERRM,
    'detail', SQLSTATE
  );
END;
$$;

-- Permissões
GRANT EXECUTE ON FUNCTION registrar_venda(uuid, uuid, numeric, varchar, date, jsonb, text, varchar) TO authenticated;
GRANT EXECUTE ON FUNCTION registrar_venda(uuid, uuid, numeric, varchar, date, jsonb, text, varchar) TO anon;

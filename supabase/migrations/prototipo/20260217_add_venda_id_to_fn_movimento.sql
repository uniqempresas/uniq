-- Migration: 20250217_add_venda_id_to_fn_movimento.sql
-- Adiciona coluna para vincular movimento financeiro à venda

ALTER TABLE fn_movimento 
ADD COLUMN IF NOT EXISTS venda_id bigint REFERENCES me_venda(id);

-- Índice para performance
CREATE INDEX IF NOT EXISTS idx_fn_movimento_venda_id 
ON fn_movimento(venda_id);

-- Comentário explicativo
COMMENT ON COLUMN fn_movimento.venda_id IS 'ID da venda relacionada (quando o movimento for gerado por uma venda)';

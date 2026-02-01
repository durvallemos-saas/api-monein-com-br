-- =============================================================================
-- VERIFICAR CONSTRAINT E ESTRUTURA DA TABELA
-- =============================================================================

-- 1. Ver todos os constraints da tabela
SELECT 
  con.conname AS constraint_name,
  con.contype AS constraint_type,
  pg_get_constraintdef(con.oid) AS constraint_definition
FROM pg_constraint con
INNER JOIN pg_class rel ON rel.oid = con.conrelid
WHERE rel.relname = 'monein_gestor_integracoes';

-- 2. Ver estrutura completa da tabela
SELECT 
  column_name, 
  data_type,
  character_maximum_length,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'monein_gestor_integracoes'
ORDER BY ordinal_position;

-- 3. Ver dados existentes
SELECT * FROM monein_gestor_integracoes;

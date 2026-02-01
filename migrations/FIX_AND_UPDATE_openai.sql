-- =============================================================================
-- ADICIONAR COLUNAS E ATUALIZAR CREDENCIAIS DA OPENAI
-- =============================================================================
-- Execute este script no Supabase SQL Editor
-- =============================================================================

-- Primeiro, vamos verificar e adicionar as colunas que faltam
DO $$ 
BEGIN
  -- Adicionar coluna configuracao se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='monein_gestor_integracoes' 
    AND column_name='configuracao'
  ) THEN
    ALTER TABLE monein_gestor_integracoes 
    ADD COLUMN configuracao JSONB NOT NULL DEFAULT '{}';
  END IF;
  
  -- Adicionar coluna metadata se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='monein_gestor_integracoes' 
    AND column_name='metadata'
  ) THEN
    ALTER TABLE monein_gestor_integracoes 
    ADD COLUMN metadata JSONB DEFAULT '{}';
  END IF;
  
  -- Adicionar coluna updated_at se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='monein_gestor_integracoes' 
    AND column_name='updated_at'
  ) THEN
    ALTER TABLE monein_gestor_integracoes 
    ADD COLUMN updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
  END IF;
END $$;

-- Adicionar constraint UNIQUE na coluna 'nome' se não existir
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'monein_gestor_integracoes_nome_key'
  ) THEN
    ALTER TABLE monein_gestor_integracoes 
    ADD CONSTRAINT monein_gestor_integracoes_nome_key UNIQUE (nome);
  END IF;
END $$;

-- Criar ou atualizar função de trigger para updated_at
CREATE OR REPLACE FUNCTION update_monein_gestor_integracoes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Remover trigger se existir e criar novamente
DROP TRIGGER IF EXISTS trigger_update_monein_gestor_integracoes_updated_at ON monein_gestor_integracoes;
CREATE TRIGGER trigger_update_monein_gestor_integracoes_updated_at
  BEFORE UPDATE ON monein_gestor_integracoes
  FOR EACH ROW
  EXECUTE FUNCTION update_monein_gestor_integracoes_updated_at();

-- Remover registro antigo da OpenAI se existir (para evitar conflitos)
DELETE FROM monein_gestor_integracoes WHERE nome = 'openai';

-- Inserir as credenciais da OpenAI
INSERT INTO monein_gestor_integracoes (nome, tipo, ativo, configuracao, metadata)
VALUES (
  'openai',
  'api',
  true,
  '{
    "api_key": "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",
    "webhook_secret": "whsec_gBPzO2K6/X8CKpRbAkrb3pKd4TOR+Fy646/i2jEiko0=",
    "webhook_url": "https://api.monein.com.br/api/webhooks/openai",
    "model": "gpt-4",
    "organization": ""
  }'::jsonb,
  '{"description": "Integração com OpenAI API", "webhook_configured": true}'::jsonb
);

-- Verificar estrutura da tabela
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'monein_gestor_integracoes'
ORDER BY ordinal_position;

-- Verificar credenciais da OpenAI
SELECT 
  nome,
  tipo,
  ativo,
  configuracao->>'api_key' as api_key_preview,
  configuracao->>'webhook_url' as webhook_url,
  metadata->>'description' as description,
  updated_at
FROM monein_gestor_integracoes
WHERE nome = 'openai';

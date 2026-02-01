-- =============================================================================
-- ATUALIZAR CREDENCIAIS DA OPENAI
-- =============================================================================
-- Execute este script no Supabase SQL Editor para atualizar as credenciais
-- =============================================================================

-- Inserir ou atualizar credenciais da OpenAI
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
)
ON CONFLICT (nome) DO UPDATE SET
  configuracao = EXCLUDED.configuracao,
  metadata = EXCLUDED.metadata,
  ativo = EXCLUDED.ativo,
  updated_at = NOW();

-- Verificar se foi atualizado
SELECT 
  nome,
  tipo,
  ativo,
  configuracao->>'webhook_url' as webhook_url,
  metadata->>'description' as description,
  updated_at
FROM monein_gestor_integracoes
WHERE nome = 'openai';

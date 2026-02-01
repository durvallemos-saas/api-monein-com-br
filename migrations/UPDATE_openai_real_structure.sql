-- =============================================================================
-- ATUALIZAR CREDENCIAIS DA OPENAI (Estrutura Real)
-- =============================================================================
-- Execute este script no Supabase SQL Editor
-- =============================================================================

-- Atualizar o registro existente da OpenAI com as novas credenciais
UPDATE monein_gestor_integracoes
SET 
  api_key = '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',
  webhook_url = 'https://api.monein.com.br/api/webhooks/openai',
  configuracoes = jsonb_set(
    jsonb_set(
      COALESCE(configuracoes, '{}'::jsonb),
      '{webhook_secret}',
      '"whsec_gBPzO2K6/X8CKpRbAkrb3pKd4TOR+Fy646/i2jEiko0="'::jsonb
    ),
    '{model}',
    '"gpt-4"'::jsonb
  ),
  ativo = true,
  updated_at = NOW()
WHERE tipo = 'openai';

-- Verificar se foi atualizado corretamente
SELECT 
  id,
  tipo,
  nome,
  LEFT(api_key, 20) || '...' as api_key_preview,
  webhook_url,
  configuracoes->>'webhook_secret' as webhook_secret_preview,
  configuracoes->>'model' as model,
  ativo,
  updated_at
FROM monein_gestor_integracoes
WHERE tipo = 'openai';

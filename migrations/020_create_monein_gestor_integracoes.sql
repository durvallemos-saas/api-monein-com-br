-- Migration: Tabela de Integrações do Sistema (monein_gestor_integracoes)
-- Armazena configurações de integrações (OpenAI, WhatsApp, etc)

CREATE TABLE IF NOT EXISTS monein_gestor_integracoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL UNIQUE, -- 'openai', 'whatsapp', etc
  tipo TEXT NOT NULL, -- 'api', 'webhook', 'oauth', etc
  ativo BOOLEAN DEFAULT TRUE,
  configuracao JSONB NOT NULL DEFAULT '{}', -- credenciais e configurações específicas
  metadata JSONB DEFAULT '{}', -- informações adicionais
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Adicionar coluna se não existir (para bancos já existentes)
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='monein_gestor_integracoes' AND column_name='configuracao') THEN
    ALTER TABLE monein_gestor_integracoes ADD COLUMN configuracao JSONB NOT NULL DEFAULT '{}';
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='monein_gestor_integracoes' AND column_name='metadata') THEN
    ALTER TABLE monein_gestor_integracoes ADD COLUMN metadata JSONB DEFAULT '{}';
  END IF;
END $$;

-- Índices
CREATE INDEX IF NOT EXISTS idx_integracoes_nome ON monein_gestor_integracoes(nome);
CREATE INDEX IF NOT EXISTS idx_integracoes_ativo ON monein_gestor_integracoes(ativo);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_monein_gestor_integracoes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_monein_gestor_integracoes_updated_at
  BEFORE UPDATE ON monein_gestor_integracoes
  FOR EACH ROW
  EXECUTE FUNCTION update_monein_gestor_integracoes_updated_at();

-- Inserir integrações de exemplo (ajustar com suas credenciais reais)
INSERT INTO monein_gestor_integracoes (nome, tipo, ativo, configuracao, metadata)
VALUES
  (
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
  ),
  (
    'whatsapp',
    'api',
    true,
    '{
      "phone_number_id": "...",
      "business_account_id": "...",
      "access_token": "...",
      "verify_token": "...",
      "webhook_url": "https://api.monein.com.br/api/webhooks/whatsapp"
    }'::jsonb,
    '{"description": "Integração com WhatsApp Business API"}'::jsonb
  )
ON CONFLICT (nome) DO UPDATE SET
  configuracao = EXCLUDED.configuracao,
  metadata = EXCLUDED.metadata,
  updated_at = NOW();

-- Comentário
COMMENT ON TABLE monein_gestor_integracoes IS 'Configurações de integrações externas (OpenAI, WhatsApp, etc)';

-- Nota de segurança:
-- Em produção, considere criptografar os campos sensíveis em 'configuracao'
-- ou usar um serviço de gerenciamento de secrets (AWS Secrets Manager, Vault, etc)

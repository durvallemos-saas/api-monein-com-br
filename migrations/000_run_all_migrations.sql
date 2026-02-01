-- =============================================================================
-- MIGRATION CONSOLIDADA - MONEIN API
-- =============================================================================
-- Execute este arquivo no Supabase SQL Editor ou via psql
-- Este script é idempotente (pode ser executado múltiplas vezes sem problemas)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. MIGRATION 016: OpenAI Webhooks e Tarefas Assíncronas
-- -----------------------------------------------------------------------------

-- Tabela para armazenar eventos de webhook da OpenAI
CREATE TABLE IF NOT EXISTS openai_webhook_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id TEXT NOT NULL UNIQUE,
  event_type TEXT NOT NULL,
  event_data JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  processed BOOLEAN DEFAULT FALSE,
  processed_at TIMESTAMPTZ,
  error_message TEXT,
  retry_count INTEGER DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_openai_events_event_id ON openai_webhook_events(event_id);
CREATE INDEX IF NOT EXISTS idx_openai_events_type ON openai_webhook_events(event_type);
CREATE INDEX IF NOT EXISTS idx_openai_events_processed ON openai_webhook_events(processed);
CREATE INDEX IF NOT EXISTS idx_openai_events_created_at ON openai_webhook_events(created_at DESC);

-- Tabela para tarefas assíncronas
CREATE TABLE IF NOT EXISTS async_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_type TEXT NOT NULL,
  task_data JSONB NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  priority INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  result JSONB
);

CREATE INDEX IF NOT EXISTS idx_async_tasks_type ON async_tasks(task_type);
CREATE INDEX IF NOT EXISTS idx_async_tasks_status ON async_tasks(status);
CREATE INDEX IF NOT EXISTS idx_async_tasks_priority ON async_tasks(priority DESC);
CREATE INDEX IF NOT EXISTS idx_async_tasks_created_at ON async_tasks(created_at DESC);

COMMENT ON TABLE openai_webhook_events IS 'Armazena eventos recebidos dos webhooks da OpenAI';
COMMENT ON TABLE async_tasks IS 'Fila de tarefas assíncronas para processamento em background';

-- -----------------------------------------------------------------------------
-- 2. MIGRATION 017: Tabela de Planos
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS monein_gestor_planos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL,
  descricao TEXT,
  valor_mensal DECIMAL(10, 2) NOT NULL,
  valor_anual DECIMAL(10, 2),
  limite_usuarios INTEGER,
  limite_empresas INTEGER,
  recursos JSONB DEFAULT '{}',
  ativo BOOLEAN DEFAULT TRUE,
  destaque BOOLEAN DEFAULT FALSE,
  ordem INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Adicionar colunas se não existirem
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='monein_gestor_planos' AND column_name='ordem') THEN
    ALTER TABLE monein_gestor_planos ADD COLUMN ordem INTEGER DEFAULT 0;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='monein_gestor_planos' AND column_name='destaque') THEN
    ALTER TABLE monein_gestor_planos ADD COLUMN destaque BOOLEAN DEFAULT FALSE;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_planos_ativo ON monein_gestor_planos(ativo);
CREATE INDEX IF NOT EXISTS idx_planos_ordem ON monein_gestor_planos(ordem);

-- Trigger updated_at
CREATE OR REPLACE FUNCTION update_monein_gestor_planos_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_monein_gestor_planos_updated_at ON monein_gestor_planos;
CREATE TRIGGER trigger_update_monein_gestor_planos_updated_at
  BEFORE UPDATE ON monein_gestor_planos
  FOR EACH ROW
  EXECUTE FUNCTION update_monein_gestor_planos_updated_at();

-- Inserir planos de exemplo
INSERT INTO monein_gestor_planos (nome, descricao, valor_mensal, valor_anual, limite_usuarios, limite_empresas, recursos, ativo, destaque, ordem)
VALUES
  ('Plano Básico', 'Ideal para pequenos negócios', 49.90, 499.00, 5, 1, '{"whatsapp": true, "relatorios_basicos": true, "suporte_email": true}'::jsonb, true, false, 1),
  ('Plano Profissional', 'Para empresas em crescimento', 99.90, 999.00, 15, 3, '{"whatsapp": true, "relatorios_avancados": true, "suporte_prioritario": true, "integracao_api": true}'::jsonb, true, true, 2),
  ('Plano Empresarial', 'Solução completa para grandes empresas', 199.90, 1999.00, -1, -1, '{"whatsapp": true, "relatorios_avancados": true, "suporte_dedicado": true, "integracao_api": true, "customizacao": true, "treinamento": true}'::jsonb, true, false, 3)
ON CONFLICT DO NOTHING;

COMMENT ON TABLE monein_gestor_planos IS 'Planos de assinatura disponíveis no sistema MONEIN';

-- -----------------------------------------------------------------------------
-- 3. MIGRATION 018: Tabela de Informações Base
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS monein_gestor_info_base (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome_sistema TEXT DEFAULT 'MONEIN',
  descricao TEXT,
  favicon TEXT,
  foto_logo_principal_fundo_branco TEXT,
  foto_logo_principal_fundo_escuro TEXT,
  background_login TEXT,
  cor_primaria TEXT DEFAULT '#1976d2',
  cor_secundaria TEXT DEFAULT '#424242',
  email_contato TEXT,
  telefone_contato TEXT,
  endereco TEXT,
  config_geral JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Adicionar colunas se não existirem
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='monein_gestor_info_base' AND column_name='nome_sistema') THEN
    ALTER TABLE monein_gestor_info_base ADD COLUMN nome_sistema TEXT DEFAULT 'MONEIN';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='monein_gestor_info_base' AND column_name='favicon') THEN
    ALTER TABLE monein_gestor_info_base ADD COLUMN favicon TEXT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='monein_gestor_info_base' AND column_name='foto_logo_principal_fundo_branco') THEN
    ALTER TABLE monein_gestor_info_base ADD COLUMN foto_logo_principal_fundo_branco TEXT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='monein_gestor_info_base' AND column_name='foto_logo_principal_fundo_escuro') THEN
    ALTER TABLE monein_gestor_info_base ADD COLUMN foto_logo_principal_fundo_escuro TEXT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='monein_gestor_info_base' AND column_name='background_login') THEN
    ALTER TABLE monein_gestor_info_base ADD COLUMN background_login TEXT;
  END IF;
END $$;

-- Trigger updated_at
CREATE OR REPLACE FUNCTION update_monein_gestor_info_base_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_monein_gestor_info_base_updated_at ON monein_gestor_info_base;
CREATE TRIGGER trigger_update_monein_gestor_info_base_updated_at
  BEFORE UPDATE ON monein_gestor_info_base
  FOR EACH ROW
  EXECUTE FUNCTION update_monein_gestor_info_base_updated_at();

-- Inserir registro inicial
INSERT INTO monein_gestor_info_base (nome_sistema, descricao, email_contato)
VALUES ('MONEIN', 'Sistema de Gestão Empresarial', 'contato@monein.com.br')
ON CONFLICT DO NOTHING;

COMMENT ON TABLE monein_gestor_info_base IS 'Informações base e assets do sistema MONEIN';

-- -----------------------------------------------------------------------------
-- 4. MIGRATION 019: Tabela de Mensagens WhatsApp
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS whatsapp_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id TEXT NOT NULL UNIQUE,
  from_number TEXT NOT NULL,
  to_number TEXT,
  phone_number_id TEXT NOT NULL,
  message_type TEXT NOT NULL,
  message_content TEXT,
  media_url TEXT,
  raw_data JSONB,
  direction TEXT NOT NULL DEFAULT 'inbound',
  delivery_status TEXT,
  timestamp TIMESTAMPTZ NOT NULL,
  status_updated_at TIMESTAMPTZ,
  processed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_message_id ON whatsapp_messages(message_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_from ON whatsapp_messages(from_number);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_to ON whatsapp_messages(to_number);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_timestamp ON whatsapp_messages(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_processed ON whatsapp_messages(processed);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_direction ON whatsapp_messages(direction);

COMMENT ON TABLE whatsapp_messages IS 'Armazena mensagens do WhatsApp Business API';

-- -----------------------------------------------------------------------------
-- 5. MIGRATION 020: Tabela de Integrações (OpenAI, WhatsApp, etc)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS monein_gestor_integracoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL UNIQUE,
  tipo TEXT NOT NULL,
  ativo BOOLEAN DEFAULT TRUE,
  configuracao JSONB NOT NULL DEFAULT '{}',
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Adicionar colunas se não existirem
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='monein_gestor_integracoes' AND column_name='configuracao') THEN
    ALTER TABLE monein_gestor_integracoes ADD COLUMN configuracao JSONB NOT NULL DEFAULT '{}';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='monein_gestor_integracoes' AND column_name='metadata') THEN
    ALTER TABLE monein_gestor_integracoes ADD COLUMN metadata JSONB DEFAULT '{}';
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_integracoes_nome ON monein_gestor_integracoes(nome);
CREATE INDEX IF NOT EXISTS idx_integracoes_ativo ON monein_gestor_integracoes(ativo);

-- Trigger updated_at
CREATE OR REPLACE FUNCTION update_monein_gestor_integracoes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_monein_gestor_integracoes_updated_at ON monein_gestor_integracoes;
CREATE TRIGGER trigger_update_monein_gestor_integracoes_updated_at
  BEFORE UPDATE ON monein_gestor_integracoes
  FOR EACH ROW
  EXECUTE FUNCTION update_monein_gestor_integracoes_updated_at();

-- Inserir/Atualizar integrações com credenciais reais
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
      "phone_number_id": "CONFIGURE_AQUI",
      "business_account_id": "CONFIGURE_AQUI",
      "access_token": "CONFIGURE_AQUI",
      "verify_token": "CONFIGURE_AQUI",
      "webhook_url": "https://api.monein.com.br/api/webhooks/whatsapp"
    }'::jsonb,
    '{"description": "Integração com WhatsApp Business API"}'::jsonb
  )
ON CONFLICT (nome) DO UPDATE SET
  configuracao = EXCLUDED.configuracao,
  metadata = EXCLUDED.metadata,
  updated_at = NOW();

COMMENT ON TABLE monein_gestor_integracoes IS 'Configurações de integrações externas (OpenAI, WhatsApp, etc)';

-- =============================================================================
-- FIM DAS MIGRATIONS
-- =============================================================================

-- Verificar tabelas criadas
SELECT 
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'public' AND table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
  AND table_name IN (
    'openai_webhook_events',
    'async_tasks',
    'monein_gestor_planos',
    'monein_gestor_info_base',
    'whatsapp_messages',
    'monein_gestor_integracoes'
  )
ORDER BY table_name;

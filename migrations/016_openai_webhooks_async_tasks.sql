-- Migration 016: OpenAI Webhooks e Tarefas Assíncronas
-- Este arquivo cria as tabelas necessárias para gerenciar webhooks da OpenAI e tarefas assíncronas

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

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_openai_events_event_id ON openai_webhook_events(event_id);
CREATE INDEX IF NOT EXISTS idx_openai_events_type ON openai_webhook_events(event_type);
CREATE INDEX IF NOT EXISTS idx_openai_events_processed ON openai_webhook_events(processed);
CREATE INDEX IF NOT EXISTS idx_openai_events_created_at ON openai_webhook_events(created_at DESC);

-- Tabela para tarefas assíncronas
CREATE TABLE IF NOT EXISTS async_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_type TEXT NOT NULL,
  task_data JSONB NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending', -- pending, processing, completed, failed
  priority INTEGER DEFAULT 0, -- maior número = maior prioridade
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  result JSONB
);

-- Índices para tarefas assíncronas
CREATE INDEX IF NOT EXISTS idx_async_tasks_type ON async_tasks(task_type);
CREATE INDEX IF NOT EXISTS idx_async_tasks_status ON async_tasks(status);
CREATE INDEX IF NOT EXISTS idx_async_tasks_priority ON async_tasks(priority DESC);
CREATE INDEX IF NOT EXISTS idx_async_tasks_created_at ON async_tasks(created_at DESC);

-- Comentários nas tabelas
COMMENT ON TABLE openai_webhook_events IS 'Armazena eventos recebidos dos webhooks da OpenAI';
COMMENT ON TABLE async_tasks IS 'Fila de tarefas assíncronas para processamento em background';

-- Grants (ajuste conforme suas permissões)
-- ALTER TABLE openai_webhook_events ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE async_tasks ENABLE ROW LEVEL SECURITY;

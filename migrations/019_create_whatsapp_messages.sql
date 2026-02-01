-- Migration: Tabelas de Mensagens WhatsApp
-- Armazena mensagens recebidas e enviadas via WhatsApp

CREATE TABLE IF NOT EXISTS whatsapp_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id TEXT NOT NULL UNIQUE,
  from_number TEXT NOT NULL,
  to_number TEXT,
  phone_number_id TEXT NOT NULL,
  message_type TEXT NOT NULL, -- text, image, audio, video, document, location, etc.
  message_content TEXT,
  media_url TEXT,
  raw_data JSONB,
  direction TEXT NOT NULL DEFAULT 'inbound', -- inbound ou outbound
  delivery_status TEXT, -- sent, delivered, read, failed
  timestamp TIMESTAMPTZ NOT NULL,
  status_updated_at TIMESTAMPTZ,
  processed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_message_id ON whatsapp_messages(message_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_from ON whatsapp_messages(from_number);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_to ON whatsapp_messages(to_number);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_timestamp ON whatsapp_messages(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_processed ON whatsapp_messages(processed);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_direction ON whatsapp_messages(direction);

-- Comentário
COMMENT ON TABLE whatsapp_messages IS 'Armazena mensagens do WhatsApp Business API';

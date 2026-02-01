-- Migration: Tabela de Informações Base do Sistema (monein_gestor_info_base)
-- Armazena informações gerais do sistema como logos, backgrounds, favicons, etc.

CREATE TABLE IF NOT EXISTS monein_gestor_info_base (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome_sistema TEXT DEFAULT 'MONEIN',
  descricao TEXT,
  favicon TEXT, -- URL do favicon
  foto_logo_principal_fundo_branco TEXT, -- URL do logo para fundo branco
  foto_logo_principal_fundo_escuro TEXT, -- URL do logo para fundo escuro
  background_login TEXT, -- URL da imagem de background do login
  cor_primaria TEXT DEFAULT '#1976d2',
  cor_secundaria TEXT DEFAULT '#424242',
  email_contato TEXT,
  telefone_contato TEXT,
  endereco TEXT,
  config_geral JSONB DEFAULT '{}', -- outras configurações gerais
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Adicionar colunas se não existirem (para bancos já existentes)
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

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_monein_gestor_info_base_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_monein_gestor_info_base_updated_at
  BEFORE UPDATE ON monein_gestor_info_base
  FOR EACH ROW
  EXECUTE FUNCTION update_monein_gestor_info_base_updated_at();

-- Inserir registro inicial (ajustar URLs conforme seu bucket)
INSERT INTO monein_gestor_info_base (
  nome_sistema,
  descricao,
  favicon,
  foto_logo_principal_fundo_branco,
  foto_logo_principal_fundo_escuro,
  background_login,
  email_contato
)
VALUES (
  'MONEIN',
  'Sistema de Gestão Empresarial',
  'https://seu-bucket.supabase.co/storage/v1/object/public/site-assets/favicon.ico',
  'https://seu-bucket.supabase.co/storage/v1/object/public/site-assets/logo-light.png',
  'https://seu-bucket.supabase.co/storage/v1/object/public/site-assets/logo-dark.png',
  'https://seu-bucket.supabase.co/storage/v1/object/public/site-assets/background-login.jpg',
  'contato@monein.com.br'
)
ON CONFLICT DO NOTHING;

-- Comentário na tabela
COMMENT ON TABLE monein_gestor_info_base IS 'Informações base e assets do sistema MONEIN';

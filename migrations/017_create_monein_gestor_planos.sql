-- Migration 017: Tabela de Planos do Sistema (monein_gestor_planos)
-- Esta tabela é usada pelo SystemPlansPage e gerencia os planos disponíveis no sistema

-- Criar tabela se não existir
CREATE TABLE IF NOT EXISTS monein_gestor_planos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL,
  descricao TEXT,
  valor_mensal DECIMAL(10, 2) NOT NULL,
  valor_anual DECIMAL(10, 2),
  limite_usuarios INTEGER,
  limite_empresas INTEGER,
  recursos JSONB DEFAULT '{}', -- features/recursos do plano
  ativo BOOLEAN DEFAULT TRUE,
  destaque BOOLEAN DEFAULT FALSE, -- plano em destaque
  ordem INTEGER DEFAULT 0, -- ordem de exibição
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Adicionar colunas se não existirem (para bancos já existentes)
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='monein_gestor_planos' AND column_name='ordem') THEN
    ALTER TABLE monein_gestor_planos ADD COLUMN ordem INTEGER DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='monein_gestor_planos' AND column_name='destaque') THEN
    ALTER TABLE monein_gestor_planos ADD COLUMN destaque BOOLEAN DEFAULT FALSE;
  END IF;
END $$;

-- Índices
CREATE INDEX IF NOT EXISTS idx_planos_ativo ON monein_gestor_planos(ativo);
CREATE INDEX IF NOT EXISTS idx_planos_ordem ON monein_gestor_planos(ordem);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_monein_gestor_planos_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_monein_gestor_planos_updated_at
  BEFORE UPDATE ON monein_gestor_planos
  FOR EACH ROW
  EXECUTE FUNCTION update_monein_gestor_planos_updated_at();

-- Inserir planos de exemplo
INSERT INTO monein_gestor_planos (nome, descricao, valor_mensal, valor_anual, limite_usuarios, limite_empresas, recursos, ativo, destaque, ordem)
VALUES
  (
    'Plano Básico',
    'Ideal para pequenos negócios',
    49.90,
    499.00,
    5,
    1,
    '{"whatsapp": true, "relatorios_basicos": true, "suporte_email": true}'::jsonb,
    true,
    false,
    1
  ),
  (
    'Plano Profissional',
    'Para empresas em crescimento',
    99.90,
    999.00,
    15,
    3,
    '{"whatsapp": true, "relatorios_avancados": true, "suporte_prioritario": true, "integracao_api": true}'::jsonb,
    true,
    true,
    2
  ),
  (
    'Plano Empresarial',
    'Solução completa para grandes empresas',
    199.90,
    1999.00,
    -1,
    -1,
    '{"whatsapp": true, "relatorios_avancados": true, "suporte_dedicado": true, "integracao_api": true, "customizacao": true, "treinamento": true}'::jsonb,
    true,
    false,
    3
  )
ON CONFLICT DO NOTHING;

-- Comentário na tabela
COMMENT ON TABLE monein_gestor_planos IS 'Planos de assinatura disponíveis no sistema MONEIN';

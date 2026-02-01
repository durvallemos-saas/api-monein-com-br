import { getSupabaseClient } from '../clients/supabase';
import logger from '../utils/logger';
import config from '../config';

interface IntegrationConfig {
  [key: string]: any;
}

interface Integration {
  id: string;
  nome: string;
  tipo: string;
  ativo: boolean;
  configuracao: IntegrationConfig;
  metadata: any;
}

const integrationCache: Map<string, Integration> = new Map();

/**
 * Carrega configuração de uma integração do banco de dados
 * Usa cache em memória para evitar múltiplas queries
 */
export async function getIntegrationConfig(integrationName: string): Promise<IntegrationConfig | null> {
  try {
    // Verifica cache primeiro
    if (integrationCache.has(integrationName)) {
      const cached = integrationCache.get(integrationName);
      if (cached?.ativo) {
        return cached.configuracao;
      }
    }

    // Busca no banco
    const supabase = getSupabaseClient();
    const { data, error } = await supabase
      .from('monein_gestor_integracoes')
      .select('*')
      .eq('nome', integrationName)
      .eq('ativo', true)
      .single();

    if (error || !data) {
      logger.warn(`Integration '${integrationName}' not found in database`);
      return null;
    }

    // Atualiza cache
    integrationCache.set(integrationName, data as Integration);
    
    return data.configuracao;
  } catch (error) {
    logger.error(`Error loading integration '${integrationName}'`, error);
    return null;
  }
}

/**
 * Obtém credenciais da OpenAI
 * Prioriza variáveis de ambiente, depois busca no banco
 */
export async function getOpenAICredentials(): Promise<{
  apiKey: string;
  webhookSecret: string;
  model?: string;
} | null> {
  // Prioriza variáveis de ambiente
  if (config.openai.apiKey && config.openai.webhookSecret) {
    return {
      apiKey: config.openai.apiKey,
      webhookSecret: config.openai.webhookSecret,
    };
  }

  // Busca no banco (estrutura real da tabela)
  try {
    const supabase = getSupabaseClient();
    const { data, error } = await supabase
      .from('monein_gestor_integracoes')
      .select('*')
      .eq('tipo', 'openai')
      .eq('ativo', true)
      .single();

    if (error || !data) {
      logger.warn('OpenAI integration not found in database');
      return null;
    }

    // Estrutura real: api_key, webhook_url, configuracoes
    return {
      apiKey: data.api_key || '',
      webhookSecret: data.configuracoes?.webhook_secret || '',
      model: data.configuracoes?.model || 'gpt-4',
    };
  } catch (error) {
    logger.error('Error loading OpenAI credentials from database', error);
    return null;
  }
}

/**
 * Obtém credenciais do WhatsApp
 * Prioriza variáveis de ambiente, depois busca no banco
 */
export async function getWhatsAppCredentials(): Promise<{
  phoneNumberId: string;
  businessAccountId: string;
  accessToken: string;
  verifyToken: string;
} | null> {
  // Prioriza variáveis de ambiente
  if (
    config.whatsapp.phoneNumberId &&
    config.whatsapp.accessToken &&
    config.whatsapp.verifyToken
  ) {
    return {
      phoneNumberId: config.whatsapp.phoneNumberId,
      businessAccountId: config.whatsapp.businessAccountId,
      accessToken: config.whatsapp.accessToken,
      verifyToken: config.whatsapp.verifyToken,
    };
  }

  // Busca no banco (estrutura real da tabela)
  try {
    const supabase = getSupabaseClient();
    const { data, error } = await supabase
      .from('monein_gestor_integracoes')
      .select('*')
      .eq('tipo', 'whatsapp')
      .eq('ativo', true)
      .single();

    if (error || !data) {
      logger.warn('WhatsApp integration not found in database');
      return null;
    }

    // Estrutura real: api_key (usado como access_token), configuracoes
    return {
      phoneNumberId: data.configuracoes?.phone_number_id || '',
      businessAccountId: data.configuracoes?.business_account_id || '',
      accessToken: data.api_key || data.configuracoes?.access_token || '',
      verifyToken: data.configuracoes?.verify_token || '',
    };
  } catch (error) {
    logger.error('Error loading WhatsApp credentials from database', error);
    return null;
  }
}

/**
 * Limpa o cache de integrações
 * Útil após atualizar configurações no banco
 */
export function clearIntegrationCache(integrationName?: string): void {
  if (integrationName) {
    integrationCache.delete(integrationName);
    logger.info(`Integration cache cleared for: ${integrationName}`);
  } else {
    integrationCache.clear();
    logger.info('All integration cache cleared');
  }
}

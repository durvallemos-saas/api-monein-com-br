import { Request, Response } from 'express';
import crypto from 'crypto';
import logger from '../../utils/logger';
import { getSupabaseClient } from '../../clients/supabase';
import { getRedisClient } from '../../clients/redis';
import { getOpenAICredentials } from '../../services/integrations';

interface OpenAIWebhookEvent {
  id: string;
  object: string;
  created_at: number;
  type: string;
  data: any;
}

/**
 * Verifica a assinatura do webhook OpenAI
 */
function verifyOpenAISignature(
  body: string,
  signature: string,
  secret: string
): boolean {
  try {
    const hmac = crypto.createHmac('sha256', secret);
    const digest = hmac.update(body).digest('hex');
    return signature === digest;
  } catch (error) {
    logger.error('Error verifying OpenAI signature', error);
    return false;
  }
}

/**
 * Processa evento do webhook OpenAI
 */
async function processOpenAIEvent(event: OpenAIWebhookEvent): Promise<void> {
  const supabase = getSupabaseClient();
  const redis = getRedisClient();

  // Salva o evento no banco
  const { error: dbError } = await supabase
    .from('openai_webhook_events')
    .insert({
      event_id: event.id,
      event_type: event.type,
      event_data: event.data,
      created_at: new Date(event.created_at * 1000).toISOString(),
      processed: false,
    });

  if (dbError) {
    logger.error('Error saving OpenAI webhook event to database', dbError);
    throw new Error('Failed to save event');
  }

  // Adiciona na fila Redis para processamento assíncrono (se Redis estiver habilitado)
  if (redis) {
    await redis.lpush(
      'openai_webhook_queue',
      JSON.stringify({ event_id: event.id, event_type: event.type })
    );
    logger.info(`OpenAI webhook event queued: ${event.type} (${event.id})`);
  } else {
    logger.info(`OpenAI webhook event saved (Redis disabled): ${event.type} (${event.id})`);
  }
}

/**
 * Handler do webhook OpenAI
 * POST /api/webhooks/openai
 */
export const handleOpenAIWebhook = async (req: Request, res: Response) => {
  try {
    const signature = req.headers['x-openai-signature'] as string;
    const body = (req as any).rawBody || JSON.stringify(req.body);

    // Carrega credenciais (do .env ou banco)
    const credentials = await getOpenAICredentials();
    if (!credentials || !credentials.webhookSecret) {
      logger.error('OpenAI webhook secret not configured');
      return res.status(500).json({ error: 'Webhook not configured' });
    }

    // Verifica assinatura
    if (!signature || !verifyOpenAISignature(body, signature, credentials.webhookSecret)) {
      logger.warn('Invalid OpenAI webhook signature');
      return res.status(401).json({ error: 'Invalid signature' });
    }

    const event: OpenAIWebhookEvent = typeof body === 'string' ? JSON.parse(body) : req.body;

    logger.info(`Received OpenAI webhook: ${event.type}`, { event_id: event.id });

    // Processa o evento
    await processOpenAIEvent(event);

    // Responde imediatamente (processamento assíncrono)
    return res.status(200).json({ received: true });
  } catch (error) {
    logger.error('Error handling OpenAI webhook', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

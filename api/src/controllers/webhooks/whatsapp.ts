import { Request, Response } from 'express';
import logger from '../../utils/logger';
import { getSupabaseClient } from '../../clients/supabase';
import { getWhatsAppCredentials } from '../../services/integrations';

interface WhatsAppMessage {
  messaging_product: string;
  metadata: {
    display_phone_number: string;
    phone_number_id: string;
  };
  contacts?: Array<{
    profile: { name: string };
    wa_id: string;
  }>;
  messages?: Array<{
    from: string;
    id: string;
    timestamp: string;
    type: 'text' | 'image' | 'audio' | 'video' | 'document' | 'location';
    text?: { body: string };
    image?: { id: string; mime_type: string; sha256: string };
    // ... outros tipos
  }>;
  statuses?: Array<{
    id: string;
    status: 'sent' | 'delivered' | 'read' | 'failed';
    timestamp: string;
    recipient_id: string;
  }>;
}

/**
 * Verifica o webhook do WhatsApp (GET)
 * GET /api/webhooks/whatsapp?hub.mode=subscribe&hub.verify_token=...&hub.challenge=...
 */
export const verifyWhatsAppWebhook = async (req: Request, res: Response) => {
  const mode = req.query['hub.mode'];
  const token = req.query['hub.verify_token'];
  const challenge = req.query['hub.challenge'];

  // Carrega credenciais (do .env ou banco)
  const credentials = await getWhatsAppCredentials();
  if (!credentials || !credentials.verifyToken) {
    logger.error('WhatsApp verify token not configured');
    return res.status(500).json({ error: 'Webhook not configured' });
  }

  if (mode === 'subscribe' && token === credentials.verifyToken) {
    logger.info('WhatsApp webhook verified successfully');
    return res.status(200).send(challenge);
  } else {
    logger.warn('WhatsApp webhook verification failed');
    return res.status(403).json({ error: 'Verification failed' });
  }
};

/**
 * Processa mensagem recebida do WhatsApp
 */
async function processWhatsAppMessage(message: WhatsAppMessage): Promise<void> {
  const supabase = getSupabaseClient();

  // Extrai mensagens
  if (message.messages && message.messages.length > 0) {
    for (const msg of message.messages) {
      logger.info(`WhatsApp message received from ${msg.from}`, {
        type: msg.type,
        id: msg.id,
      });

      // Salva no banco
      const { error } = await supabase.from('whatsapp_messages').insert({
        message_id: msg.id,
        from_number: msg.from,
        phone_number_id: message.metadata.phone_number_id,
        message_type: msg.type,
        message_content: msg.text?.body || null,
        raw_data: msg,
        timestamp: new Date(parseInt(msg.timestamp) * 1000).toISOString(),
        processed: false,
      });

      if (error) {
        logger.error('Error saving WhatsApp message', error);
      }
    }
  }

  // Processa status updates
  if (message.statuses && message.statuses.length > 0) {
    for (const status of message.statuses) {
      logger.info(`WhatsApp status update: ${status.status}`, {
        message_id: status.id,
        recipient: status.recipient_id,
      });

      // Atualiza status no banco
      const { error } = await supabase
        .from('whatsapp_messages')
        .update({
          delivery_status: status.status,
          status_updated_at: new Date(parseInt(status.timestamp) * 1000).toISOString(),
        })
        .eq('message_id', status.id);

      if (error) {
        logger.error('Error updating WhatsApp message status', error);
      }
    }
  }
}

/**
 * Handler do webhook WhatsApp (POST)
 * POST /api/webhooks/whatsapp
 */
export const handleWhatsAppWebhook = async (req: Request, res: Response) => {
  try {
    const body = req.body;

    if (!body.entry || !Array.isArray(body.entry)) {
      return res.status(400).json({ error: 'Invalid payload' });
    }

    logger.info('WhatsApp webhook received', {
      entries: body.entry.length,
    });

    // Processa cada entrada
    for (const entry of body.entry) {
      if (entry.changes && Array.isArray(entry.changes)) {
        for (const change of entry.changes) {
          if (change.value) {
            await processWhatsAppMessage(change.value);
          }
        }
      }
    }

    // Responde imediatamente
    return res.status(200).json({ received: true });
  } catch (error) {
    logger.error('Error handling WhatsApp webhook', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

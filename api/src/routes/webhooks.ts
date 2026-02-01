import { Router, Request, Response, NextFunction } from 'express';
import { handleOpenAIWebhook } from '../controllers/webhooks/openai';
import { verifyWhatsAppWebhook, handleWhatsAppWebhook } from '../controllers/webhooks/whatsapp';
import logger from '../utils/logger';

const router = Router();

/**
 * Middleware para capturar raw body (necessário para OpenAI)
 */
const captureRawBody = (req: Request, res: Response, next: NextFunction) => {
  let data = '';
  req.setEncoding('utf8');
  
  req.on('data', (chunk) => {
    data += chunk;
  });

  req.on('end', () => {
    (req as any).rawBody = data;
    try {
      req.body = JSON.parse(data);
      next();
    } catch (err) {
      logger.error('Error parsing JSON body', err);
      res.status(400).json({ error: 'Invalid JSON' });
    }
  });
};

/**
 * OpenAI Webhook
 * POST /api/webhooks/openai
 */
router.post('/openai', captureRawBody, handleOpenAIWebhook);

/**
 * WhatsApp Webhook - Verification
 * GET /api/webhooks/whatsapp
 */
router.get('/whatsapp', verifyWhatsAppWebhook);

/**
 * WhatsApp Webhook - Receive messages
 * POST /api/webhooks/whatsapp
 */
router.post('/whatsapp', handleWhatsAppWebhook);

export default router;

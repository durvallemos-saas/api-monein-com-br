import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import bodyParser from 'body-parser';
import https from 'https';
import http from 'http';
import fs from 'fs';
import config from './config';
import logger from './utils/logger';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';
import { requestLogger } from './middleware/requestLogger';
import healthRoutes from './routes/health';
import webhookRoutes from './routes/webhooks';

const app: Application = express();

// Security middleware
app.use(helmet());

// CORS configuration
app.use(cors({
  origin: config.corsOrigin,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-openai-signature'],
}));

// Request logging
app.use(requestLogger);

// Body parser - JSON (exceto rotas que precisam de raw body)
app.use((_req, _res, next) => {
  // OpenAI webhook precisa de raw body para verificação de assinatura
  if (_req.path === '/api/webhooks/openai') {
    return next();
  }
  bodyParser.json({ limit: '10mb' })(_req, _res, next);
});

app.use(bodyParser.urlencoded({ extended: true, limit: '10mb' }));

// Root endpoint
app.get('/', (_req: Request, res: Response) => {
  res.json({
    message: 'MONEIN API',
    version: '1.0.0',
    status: 'running',
  });
});

// Routes
app.use('/api', healthRoutes);
app.use('/api/webhooks', webhookRoutes);

// 404 handler
app.use(notFoundHandler);

// Error handler (deve ser o último middleware)
app.use(errorHandler);

// Start server
const startServer = () => {
  if (config.ssl.enabled && config.nodeEnv === 'production') {
    try {
      // Verificar se os certificados SSL existem
      if (!fs.existsSync(config.ssl.keyPath) || !fs.existsSync(config.ssl.certPath)) {
        logger.error('Certificados SSL não encontrados!');
        logger.error(`Key: ${config.ssl.keyPath}`);
        logger.error(`Cert: ${config.ssl.certPath}`);
        logger.warn('Iniciando servidor HTTP na porta 3000 como fallback');
        
        app.listen(3000, () => {
          logger.info('Server running on HTTP port 3000 (fallback)');
          logger.info(`Environment: ${config.nodeEnv}`);
        });
        return;
      }

      const httpsOptions = {
        key: fs.readFileSync(config.ssl.keyPath),
        cert: fs.readFileSync(config.ssl.certPath),
      };

      // Servidor HTTPS na porta 443
      const httpsServer = https.createServer(httpsOptions, app);
      httpsServer.listen(config.port, () => {
        logger.info(`🔒 HTTPS Server running on port ${config.port}`);
        logger.info(`Environment: ${config.nodeEnv}`);
        logger.info(`API Base: ${config.publicApiBase}`);
      });

      // Servidor HTTP na porta 80 para redirecionar para HTTPS
      const httpServer = http.createServer((req, res) => {
        const host = req.headers.host?.split(':')[0] || 'localhost';
        const redirectUrl = `https://${host}${req.url}`;
        res.writeHead(301, { Location: redirectUrl });
        res.end();
      });

      httpServer.listen(config.httpPort, () => {
        logger.info(`🔓 HTTP Server running on port ${config.httpPort} (redirect to HTTPS)`);
      });

      // Graceful shutdown para ambos os servidores
      const shutdown = (signal: string) => {
        logger.info(`${signal} signal received: closing servers`);
        httpsServer.close(() => {
          logger.info('HTTPS server closed');
          httpServer.close(() => {
            logger.info('HTTP server closed');
            process.exit(0);
          });
        });
      };

      process.on('SIGTERM', () => shutdown('SIGTERM'));
      process.on('SIGINT', () => shutdown('SIGINT'));

    } catch (error) {
      logger.error('Erro ao iniciar servidor HTTPS:', error);
      logger.warn('Iniciando servidor HTTP na porta 3000 como fallback');
      
      app.listen(3000, () => {
        logger.info('Server running on HTTP port 3000 (fallback)');
        logger.info(`Environment: ${config.nodeEnv}`);
      });
    }
  } else {
    // Modo de desenvolvimento - HTTP simples
    const PORT = config.nodeEnv === 'production' ? 3000 : config.port;
    app.listen(PORT, () => {
      logger.info(`Server running on HTTP port ${PORT}`);
      logger.info(`Environment: ${config.nodeEnv}`);
      logger.info(`API Base: ${config.publicApiBase}`);
    });

    // Graceful shutdown
    process.on('SIGTERM', () => {
      logger.info('SIGTERM signal received: closing HTTP server');
      process.exit(0);
    });

    process.on('SIGINT', () => {
      logger.info('SIGINT signal received: closing HTTP server');
      process.exit(0);
    });
  }
};

startServer();

export default app;

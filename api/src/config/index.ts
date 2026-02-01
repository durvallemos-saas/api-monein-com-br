import dotenv from 'dotenv';

dotenv.config();

interface Config {
  port: number;
  httpPort: number;
  nodeEnv: string;
  publicApiBase: string;
  corsOrigin: string[];
  ssl: {
    enabled: boolean;
    keyPath: string;
    certPath: string;
  };
  supabase: {
    url: string;
    serviceRoleKey: string;
    anonKey: string;
  };
  redis: {
    url: string | null;
    enabled: boolean;
  };
  openai: {
    apiKey: string;
    webhookSecret: string;
  };
  whatsapp: {
    phoneNumberId: string;
    businessAccountId: string;
    accessToken: string;
    verifyToken: string;
  };
}

const config: Config = {
  port: parseInt(process.env.PORT || '443', 10),
  httpPort: parseInt(process.env.HTTP_PORT || '80', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  publicApiBase: process.env.PUBLIC_API_BASE || 'http://localhost:3000',
  corsOrigin: process.env.CORS_ORIGIN?.split(',').map(o => o.trim()) || ['http://localhost:5173'],
  ssl: {
    enabled: process.env.SSL_ENABLED === 'true',
    keyPath: process.env.SSL_KEY_PATH || '/home/u991291448/.ssl/api.monein.com.br/privkey.pem',
    certPath: process.env.SSL_CERT_PATH || '/home/u991291448/.ssl/api.monein.com.br/fullchain.pem',
  },
  supabase: {
    url: process.env.SUPABASE_URL || '',
    serviceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY || '',
    anonKey: process.env.SUPABASE_ANON_KEY || '',
  },
  redis: {
    url: process.env.REDIS_URL || null,
    enabled: !!process.env.REDIS_URL,
  },
  openai: {
    apiKey: process.env.OPENAI_API_KEY || '',
    webhookSecret: process.env.OPENAI_WEBHOOK_SECRET || '',
  },
  whatsapp: {
    phoneNumberId: process.env.WHATSAPP_PHONE_NUMBER_ID || '',
    businessAccountId: process.env.WHATSAPP_BUSINESS_ACCOUNT_ID || '',
    accessToken: process.env.WHATSAPP_ACCESS_TOKEN || '',
    verifyToken: process.env.WHATSAPP_VERIFY_TOKEN || '',
  },
};

export default config;

# API MONEIN

API Backend para o sistema de gestão MONEIN, desenvolvida em Node.js/Express com TypeScript.

## 🚀 Visão Geral

- **Subdomínio dedicado**: `api.seu-dominio.com` (ex.: `api.monein.com.br`)
- **Backend**: Node.js/Express com TypeScript
- **Porta interna**: 3000
- **Proxy reverso**: Nginx com HTTPS
- **Banco de dados**: Supabase/PostgreSQL
- **Cache**: Redis
- **Integrações**: OpenAI, WhatsApp Business API

## 📋 Estrutura do Projeto

```
api-monein-com-br/
├── api/                      # Backend Node.js/Express
│   ├── src/
│   │   ├── clients/         # Clientes (Supabase, Redis)
│   │   ├── config/          # Configurações
│   │   ├── controllers/     # Controllers (webhooks, etc)
│   │   ├── middleware/      # Middlewares
│   │   ├── routes/          # Rotas da API
│   │   ├── utils/           # Utilitários (logger, etc)
│   │   └── server.ts        # Servidor principal
│   ├── package.json
│   ├── tsconfig.json
│   └── .env.example
├── migrations/              # Migrations SQL
│   ├── 016_openai_webhooks_async_tasks.sql
│   ├── 017_create_monein_gestor_planos.sql
│   ├── 018_create_monein_gestor_info_base.sql
│   └── 019_create_whatsapp_messages.sql
├── deploy/                  # Configurações de deploy
│   ├── nginx.conf          # Configuração Nginx
│   ├── deploy.sh           # Script de deploy
│   └── README.md           # Guia completo de deploy
└── README.md               # Este arquivo
```

## 🔧 Instalação e Desenvolvimento

### Pré-requisitos

- Node.js 18+
- Redis
- Banco de dados PostgreSQL/Supabase

### 1. Instalar dependências

```bash
cd api
npm install
```

### 2. Configurar variáveis de ambiente

```bash
cp .env.example .env
# Edite o arquivo .env com suas credenciais
```

### 3. Aplicar migrations

Acesse o Supabase Dashboard > SQL Editor e execute os arquivos SQL da pasta `migrations/` na ordem.

### 4. Rodar em desenvolvimento

```bash
npm run dev
```

A API estará disponível em `http://localhost:3000`

## 🌐 Variáveis de Ambiente

Todas as variáveis necessárias estão no arquivo `.env.example`:

```env
PORT=3000
NODE_ENV=production
PUBLIC_API_BASE=https://api.seu-dominio.com

SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=...
SUPABASE_ANON_KEY=...

REDIS_URL=redis://user:pass@host:6379

OPENAI_API_KEY=sk-...
OPENAI_WEBHOOK_SECRET=whsec-...

WHATSAPP_PHONE_NUMBER_ID=...
WHATSAPP_BUSINESS_ACCOUNT_ID=...
WHATSAPP_ACCESS_TOKEN=...
WHATSAPP_VERIFY_TOKEN=...
```

## 🚢 Deploy em Produção

### Build

```bash
cd api
npm ci
npm run build
```

### Executar com PM2

```bash
PORT=3000 NODE_ENV=production pm2 start dist/server.js --name monein-api
pm2 save
```

### Script de Deploy Automatizado

```bash
chmod +x deploy/deploy.sh
sudo ./deploy/deploy.sh
```

📖 **Guia completo de deploy**: [deploy/README.md](deploy/README.md)

## 🔌 Endpoints Principais

### Health Check
```
GET /api/health
```

### Webhooks

#### OpenAI
```
POST /api/webhooks/openai
Headers:
  - x-openai-signature: <assinatura>
```

#### WhatsApp
```
GET  /api/webhooks/whatsapp   # Verificação
POST /api/webhooks/whatsapp   # Receber mensagens
```

## 🗄️ Migrations

Todas as migrations SQL estão na pasta `migrations/`:

1. **016_openai_webhooks_async_tasks.sql** - Webhooks OpenAI + tarefas assíncronas
2. **017_create_monein_gestor_planos.sql** - Tabela de planos do sistema
3. **018_create_monein_gestor_info_base.sql** - Informações base e assets
4. **019_create_whatsapp_messages.sql** - Mensagens WhatsApp

Ver [migrations/README.md](migrations/README.md) para instruções detalhadas.

## 🖼️ Assets e Configuração de Imagens

Para evitar erros 422 ao carregar imagens:

1. Crie o bucket `site-assets` no Supabase Storage (público)
2. Faça upload dos seguintes arquivos:
   - `favicon.ico`
   - `logo-light.png` (logo para fundo branco)
   - `logo-dark.png` (logo para fundo escuro)
   - `background-login.jpg`
3. Atualize as URLs na tabela `monein_gestor_info_base`

```sql
UPDATE monein_gestor_info_base
SET 
  favicon = 'https://seu-bucket.supabase.co/storage/v1/object/public/site-assets/favicon.ico',
  foto_logo_principal_fundo_branco = 'https://seu-bucket.supabase.co/storage/v1/object/public/site-assets/logo-light.png',
  foto_logo_principal_fundo_escuro = 'https://seu-bucket.supabase.co/storage/v1/object/public/site-assets/logo-dark.png',
  background_login = 'https://seu-bucket.supabase.co/storage/v1/object/public/site-assets/background-login.jpg'
WHERE id = (SELECT id FROM monein_gestor_info_base LIMIT 1);
```

## 🔐 Configuração do Nginx

Arquivo de configuração completo em [deploy/nginx.conf](deploy/nginx.conf)

```nginx
server {
  server_name api.seu-dominio.com;
  listen 443 ssl http2;
  
  # Certificados SSL
  ssl_certificate /etc/letsencrypt/live/api.seu-dominio.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/api.seu-dominio.com/privkey.pem;
  
  client_max_body_size 25m;
  
  location / {
    proxy_pass http://127.0.0.1:3000;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
```

### Obter certificado SSL:
```bash
sudo certbot --nginx -d api.seu-dominio.com
```

## 📝 Scripts Disponíveis

| Script | Descrição |
|--------|-----------|
| `npm run dev` | Inicia servidor de desenvolvimento com hot reload |
| `npm run build` | Compila TypeScript para JavaScript |
| `npm start` | Inicia servidor de produção |
| `npm run typecheck` | Verifica tipos TypeScript |
| `npm run lint` | Executa ESLint |

## 🔍 Comandos Úteis

### PM2
```bash
pm2 status                    # Ver status
pm2 logs monein-api          # Ver logs
pm2 logs monein-api --lines 200  # Ver últimas 200 linhas
pm2 restart monein-api       # Reiniciar
pm2 stop monein-api          # Parar
pm2 monit                    # Monitorar em tempo real
```

### Logs
```bash
# Logs da aplicação
pm2 logs monein-api

# Logs do Nginx
sudo tail -f /var/log/nginx/api.seu-dominio.com.access.log
sudo tail -f /var/log/nginx/api.seu-dominio.com.error.log
```

## ✅ Checklist de Deploy

- [ ] DNS do subdomínio configurado
- [ ] Certificado TLS/SSL aplicado (Certbot)
- [ ] Variáveis de ambiente definidas (`.env`)
- [ ] Build do backend executado (`npm run build`)
- [ ] Processo ativo (PM2 ou similar)
- [ ] Proxy reverso configurado (Nginx)
- [ ] Migrations aplicadas (016, 017, 018, 019)
- [ ] Assets enviados ao bucket `site-assets`
- [ ] URLs dos assets salvas em `monein_gestor_info_base`
- [ ] Frontend publicado e apontando para API
- [ ] Webhooks configurados (OpenAI, WhatsApp)
- [ ] Testes de health check passando

## 🐛 Troubleshooting

### API não responde
1. Verificar se processo está rodando: `pm2 status`
2. Ver logs de erro: `pm2 logs monein-api --err`
3. Verificar portas: `sudo netstat -tulpn | grep 3000`

### Erro 502 Bad Gateway
1. Verificar se Node.js está rodando na porta 3000
2. Verificar configuração do Nginx: `sudo nginx -t`
3. Ver logs: `sudo tail -f /var/log/nginx/error.log`

### Erro 422 ao carregar imagens
1. Verificar se bucket `site-assets` existe e é público
2. Verificar URLs na tabela `monein_gestor_info_base`
3. Testar URLs diretamente no navegador

### Webhooks não funcionam
1. Verificar se URLs estão acessíveis publicamente
2. Verificar secrets/tokens de verificação
3. Ver logs: `pm2 logs monein-api`

## 📚 Documentação Adicional

- [Guia Completo de Deploy](deploy/README.md)
- [Guia de Migrations](migrations/README.md)

## 🛠️ Tecnologias

- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Linguagem**: TypeScript
- **Banco de dados**: PostgreSQL (Supabase)
- **Cache**: Redis
- **Process Manager**: PM2
- **Proxy reverso**: Nginx
- **Integrações**: OpenAI API, WhatsApp Business API

## 📄 Licença

MIT

## 🤝 Suporte

Para dúvidas ou problemas:
1. Verifique os logs: `pm2 logs monein-api`
2. Consulte o guia de troubleshooting acima
3. Revise a documentação em `deploy/README.md`
4. Verifique as migrations em `migrations/README.md`

---

**MONEIN** - Sistema de Gestão Empresarial

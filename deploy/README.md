# Guia de Deploy - API MONEIN

Este guia descreve o processo completo para fazer deploy do backend da API MONEIN em um servidor Linux.

## Pré-requisitos

- Servidor Linux (Ubuntu 20.04+ recomendado)
- Node.js 18+ instalado
- Nginx instalado
- Acesso root ou sudo
- Domínio configurado (ex: `api.monein.com.br`)
- Banco de dados Supabase/PostgreSQL configurado
- Redis instalado e rodando

## 1. Preparação do Servidor

### 1.1 Instalar Node.js
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version
npm --version
```

### 1.2 Instalar PM2
```bash
sudo npm install -g pm2
```

### 1.3 Instalar Nginx
```bash
sudo apt update
sudo apt install nginx
sudo systemctl status nginx
```

### 1.4 Instalar Certbot (para SSL)
```bash
sudo apt install certbot python3-certbot-nginx
```

## 2. Configuração do DNS

Aponte seu domínio (ou subdomínio) para o IP do servidor:

```
Tipo: A
Host: api
Valor: <IP-DO-SERVIDOR>
TTL: 3600
```

Aguarde a propagação do DNS (pode levar alguns minutos).

## 3. Upload do Código

### Opção A: Via Git
```bash
# No servidor
cd /var/www
sudo git clone https://github.com/seu-usuario/api-monein-com-br.git
sudo chown -R $USER:$USER api-monein-com-br
```

### Opção B: Via SCP
```bash
# Na sua máquina local
scp -r ./api usuario@servidor:/var/www/api-monein-com-br/
```

## 4. Configurar Variáveis de Ambiente

```bash
cd /var/www/api-monein-com-br/api
cp .env.example .env
nano .env
```

Configure todas as variáveis de ambiente:

```env
PORT=3000
NODE_ENV=production
PUBLIC_API_BASE=https://api.seu-dominio.com

SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=...
SUPABASE_ANON_KEY=...

REDIS_URL=redis://localhost:6379

OPENAI_API_KEY=sk-...
OPENAI_WEBHOOK_SECRET=whsec-...

WHATSAPP_PHONE_NUMBER_ID=...
WHATSAPP_BUSINESS_ACCOUNT_ID=...
WHATSAPP_ACCESS_TOKEN=...
WHATSAPP_VERIFY_TOKEN=...
```

## 5. Build e Deploy

### Opção A: Usando o script de deploy
```bash
cd /var/www/api-monein-com-br
chmod +x deploy/deploy.sh
sudo ./deploy/deploy.sh
```

### Opção B: Manualmente
```bash
cd /var/www/api-monein-com-br/api
npm ci
npm run build
PORT=3000 NODE_ENV=production pm2 start dist/server.js --name monein-api
pm2 save
pm2 startup
```

## 6. Configurar Nginx

```bash
# Copiar configuração
sudo cp /var/www/api-monein-com-br/deploy/nginx.conf /etc/nginx/sites-available/api.seu-dominio.com

# Editar com seu domínio real
sudo nano /etc/nginx/sites-available/api.seu-dominio.com

# Criar symlink
sudo ln -s /etc/nginx/sites-available/api.seu-dominio.com /etc/nginx/sites-enabled/

# Testar configuração
sudo nginx -t

# Recarregar Nginx
sudo systemctl reload nginx
```

## 7. Configurar SSL com Certbot

```bash
sudo certbot --nginx -d api.seu-dominio.com
```

Siga as instruções do Certbot. Ele irá:
- Obter certificado SSL gratuito
- Configurar renovação automática
- Atualizar a configuração do Nginx

## 8. Aplicar Migrations do Banco

```bash
# Via Supabase Dashboard
# Acesse o SQL Editor e execute as migrations na pasta /migrations/

# Ou via psql
export DATABASE_URL="postgresql://user:pass@host:5432/dbname"
cd /var/www/api-monein-com-br/migrations
psql $DATABASE_URL < 016_openai_webhooks_async_tasks.sql
psql $DATABASE_URL < 017_create_monein_gestor_planos.sql
psql $DATABASE_URL < 018_create_monein_gestor_info_base.sql
psql $DATABASE_URL < 019_create_whatsapp_messages.sql
```

## 9. Configurar Assets

1. Crie o bucket `site-assets` no Supabase Storage
2. Torne-o público
3. Faça upload dos arquivos:
   - favicon.ico
   - logo-light.png
   - logo-dark.png
   - background-login.jpg
4. Atualize as URLs na tabela `monein_gestor_info_base`

## 10. Configurar Webhooks

### OpenAI
- URL: `https://api.seu-dominio.com/api/webhooks/openai`
- Método: POST
- Secret: valor de `OPENAI_WEBHOOK_SECRET`

### WhatsApp
- URL: `https://api.seu-dominio.com/api/webhooks/whatsapp`
- Verify Token: valor de `WHATSAPP_VERIFY_TOKEN`

## 11. Verificação

### Testar a API
```bash
curl https://api.seu-dominio.com
curl https://api.seu-dominio.com/api/health
```

### Ver logs
```bash
pm2 logs monein-api
pm2 logs monein-api --lines 200
```

### Monitorar
```bash
pm2 monit
pm2 status
```

## 12. Comandos Úteis

### PM2
```bash
pm2 restart monein-api     # Reiniciar
pm2 stop monein-api        # Parar
pm2 delete monein-api      # Remover
pm2 save                   # Salvar configuração
pm2 resurrect              # Restaurar processos salvos
```

### Nginx
```bash
sudo nginx -t                    # Testar configuração
sudo systemctl reload nginx      # Recarregar
sudo systemctl restart nginx     # Reiniciar
sudo systemctl status nginx      # Status
```

### Logs
```bash
# Logs do PM2
pm2 logs monein-api

# Logs do Nginx
sudo tail -f /var/log/nginx/api.seu-dominio.com.access.log
sudo tail -f /var/log/nginx/api.seu-dominio.com.error.log
```

## 13. Atualização

Para fazer deploy de uma nova versão:

```bash
cd /var/www/api-monein-com-br
git pull origin main  # ou copie novos arquivos
cd api
npm ci
npm run build
pm2 reload monein-api
```

Ou use o script de deploy:

```bash
./deploy/deploy.sh
```

## 14. Troubleshooting

### API não responde
1. Verificar se o processo está rodando: `pm2 status`
2. Ver logs de erro: `pm2 logs monein-api --err`
3. Verificar portas: `sudo netstat -tulpn | grep 3000`

### Erro 502 Bad Gateway
1. Verificar se Node.js está rodando na porta 3000
2. Verificar configuração do Nginx: `sudo nginx -t`
3. Ver logs do Nginx: `sudo tail -f /var/log/nginx/error.log`

### Webhooks não funcionam
1. Verificar se as URLs estão acessíveis publicamente
2. Verificar secrets/tokens de verificação
3. Ver logs da aplicação: `pm2 logs monein-api`

### Erro ao conectar no banco
1. Verificar variáveis de ambiente: `cat /var/www/api-monein-com-br/api/.env`
2. Testar conexão com Supabase
3. Verificar regras de firewall

## 15. Segurança

- Mantenha Node.js e dependências atualizadas
- Use variáveis de ambiente para dados sensíveis (nunca commite .env)
- Configure firewall (ufw) para permitir apenas portas necessárias (80, 443, 22)
- Monitore logs regularmente
- Configure backup automático do banco de dados
- Use rate limiting no Nginx se necessário

## 16. Backup

### Backup do código
```bash
tar -czf backup-api-$(date +%Y%m%d).tar.gz /var/www/api-monein-com-br/api
```

### Backup do banco
Configure backups automáticos no Supabase Dashboard ou use pg_dump:
```bash
pg_dump $DATABASE_URL > backup-$(date +%Y%m%d).sql
```

## Suporte

Para mais informações, consulte:
- README principal do projeto
- Documentação das migrations em `/migrations/README.md`
- Logs da aplicação

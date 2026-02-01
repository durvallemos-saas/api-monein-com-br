# Deploy com HTTPS Direto (Sem Nginx)

Esta configuração permite que o Node.js sirva HTTPS diretamente, eliminando a necessidade do Nginx como proxy reverso.

## ✅ Vantagens

- **Mais simples**: Uma camada a menos
- **Menos overhead**: Sem proxy reverso
- **Fácil debug**: Logs diretos do Node.js
- **Menos configuração**: Apenas PM2 e certificados SSL

## 📋 Pré-requisitos

1. **Certificados SSL** instalados via Certbot
2. **Node.js** instalado no servidor
3. **PM2** instalado globalmente
4. **Portas 80 e 443** disponíveis

## 🚀 Instalação

### 1. Instalar Certificados SSL

```bash
# Parar Nginx se estiver rodando
sudo systemctl stop nginx
sudo systemctl disable nginx

# Instalar Certbot
sudo apt update
sudo apt install certbot -y

# Gerar certificados SSL (modo standalone)
sudo certbot certonly --standalone -d api.monein.com.br

# Certificados ficam em:
# /etc/letsencrypt/live/api.monein.com.br/privkey.pem
# /etc/letsencrypt/live/api.monein.com.br/fullchain.pem
```

### 2. Dar Permissão ao Node.js para Portas Privilegiadas

```bash
# Permitir que Node.js use portas 80 e 443 sem root
sudo setcap 'cap_net_bind_service=+ep' $(which node)

# Verificar permissão
getcap $(which node)
# Deve retornar: /usr/bin/node = cap_net_bind_service+ep
```

### 3. Configurar Variáveis de Ambiente

Adicione ao arquivo `.env` na pasta `api/`:

```bash
# SSL Configuration
SSL_ENABLED=true
SSL_KEY_PATH=/etc/letsencrypt/live/api.monein.com.br/privkey.pem
SSL_CERT_PATH=/etc/letsencrypt/live/api.monein.com.br/fullchain.pem

# Ports
PORT=443
HTTP_PORT=80

# API Base
PUBLIC_API_BASE=https://api.monein.com.br
```

### 4. Deploy

```bash
# Baixar e executar script de deploy
cd /home/u991291448/domains/monein.com.br/public_html/api
chmod +x deploy/deploy-https-direct.sh
./deploy/deploy-https-direct.sh
```

## 🔄 Renovação Automática de Certificados SSL

### Configurar Certbot para Renovação

```bash
# Criar script de renovação
sudo nano /etc/letsencrypt/renewal-hooks/deploy/reload-app.sh
```

Adicione:

```bash
#!/bin/bash
# Recarregar aplicação após renovação do certificado
pm2 reload monein-api
```

Torne executável:

```bash
sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-app.sh
```

### Testar Renovação

```bash
# Testar renovação (modo dry-run)
sudo certbot renew --dry-run

# Renovação real
sudo certbot renew
```

### Automatizar Renovação

```bash
# Adicionar cron job para renovação automática
sudo crontab -e

# Adicionar linha (verifica diariamente às 3h):
0 3 * * * certbot renew --quiet --deploy-hook "pm2 reload monein-api"
```

## 🔍 Verificação

### 1. Verificar Portas

```bash
# Ver se Node.js está ouvindo nas portas 443 e 80
sudo netstat -tulpn | grep node

# Ou com ss
sudo ss -tulpn | grep node
```

### 2. Testar API

```bash
# Testar HTTP (deve redirecionar para HTTPS)
curl -I http://api.monein.com.br

# Testar HTTPS
curl https://api.monein.com.br

# Testar endpoint de health
curl https://api.monein.com.br/api/health
```

### 3. Verificar Certificado SSL

```bash
# Ver informações do certificado
openssl s_client -connect api.monein.com.br:443 -servername api.monein.com.br
```

## 🐛 Troubleshooting

### Problema: "Permission denied" ao iniciar na porta 443

**Solução**: Dar permissão ao Node.js

```bash
sudo setcap 'cap_net_bind_service=+ep' $(which node)
```

### Problema: "Certificados SSL não encontrados"

**Solução**: Verificar caminho dos certificados

```bash
# Listar certificados
sudo certbot certificates

# Verificar se existem
ls -la /etc/letsencrypt/live/api.monein.com.br/
```

### Problema: Porta 443 já está em uso

**Solução**: Verificar e parar outros serviços

```bash
# Ver o que está usando a porta 443
sudo lsof -i :443

# Se for Nginx, pare-o
sudo systemctl stop nginx
sudo systemctl disable nginx
```

### Problema: Node.js perde permissão após atualização

**Solução**: Reconfigurar permissão após atualizar Node.js

```bash
sudo setcap 'cap_net_bind_service=+ep' $(which node)
pm2 restart all
```

## 📊 Monitoramento

```bash
# Ver logs em tempo real
pm2 logs monein-api

# Status da aplicação
pm2 status

# Monitor interativo
pm2 monit

# Ver logs de erro
pm2 logs monein-api --err

# Ver informações detalhadas
pm2 describe monein-api
```

## 🔐 Segurança

### Firewall (ufw)

```bash
# Permitir portas 80 e 443
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Bloquear porta 3000 (não é mais necessária)
sudo ufw deny 3000/tcp

# Verificar status
sudo ufw status
```

### Permissões de Certificados

```bash
# Dar permissão ao usuário da aplicação para ler certificados
sudo chmod 755 /etc/letsencrypt/live/
sudo chmod 755 /etc/letsencrypt/archive/
```

## 🔄 Rollback para Nginx

Se precisar voltar a usar Nginx:

1. Remover permissão do Node.js:
```bash
sudo setcap -r $(which node)
```

2. Alterar `.env`:
```bash
SSL_ENABLED=false
PORT=3000
```

3. Reinicar com PM2:
```bash
pm2 reload ecosystem.config.js --update-env
```

4. Iniciar Nginx:
```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

## 📝 Comandos Úteis

```bash
# Deploy completo
./deploy/deploy-https-direct.sh

# Reiniciar aplicação
pm2 restart monein-api

# Ver logs
pm2 logs monein-api --lines 100

# Recarregar (sem downtime)
pm2 reload monein-api

# Parar aplicação
pm2 stop monein-api

# Iniciar aplicação
pm2 start ecosystem.config.js

# Salvar configuração do PM2
pm2 save

# Startup automático
pm2 startup
```

## ⚙️ Configurações Avançadas

### HTTP/2

A configuração atual já suporta HTTP/2 via Node.js HTTPS.

### Rate Limiting

Adicione ao `server.ts`:

```typescript
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // 100 requisições
});

app.use('/api/', limiter);
```

### Compression

```bash
npm install compression
```

```typescript
import compression from 'compression';
app.use(compression());
```

## 📚 Referências

- [Node.js HTTPS Documentation](https://nodejs.org/api/https.html)
- [PM2 Documentation](https://pm2.keymetrics.io/docs/)
- [Certbot Documentation](https://certbot.eff.org/docs/)
- [Linux Capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html)

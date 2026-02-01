# 🚀 Deploy Rápido - Hostinger

## 📋 Lista de Comandos (Copiar e Colar)

Execute estes comandos **linha por linha** no SSH da Hostinger:

### 1. Conectar via SSH
```bash
ssh -p 65002 u991291448@77.37.127.18
```

### 2. Navegar para o diretório
```bash
cd /home/u991291448/domains/monein.com.br/public_html/api
```

### 3. Atualizar código do GitHub
```bash
git fetch origin
git reset --hard origin/main
```

### 4. Backup do .env (se existir)
```bash
cp .env .env.backup
```

### 5. Encontrar certificados SSL
```bash
chmod +x deploy/find-ssl-certs.sh
./deploy/find-ssl-certs.sh
```

### 6. Configurar SSL automaticamente
```bash
chmod +x deploy/setup-hostinger-ssl.sh
./deploy/setup-hostinger-ssl.sh
```

### 7. Instalar dependências
```bash
npm install
```

### 8. Compilar TypeScript
```bash
npm run build
```

### 9. Dar permissão ao Node.js (tentar primeiro)
```bash
sudo setcap 'cap_net_bind_service=+ep' $(which node)
```

**Se não tiver sudo**, edite o `.env`:
```bash
nano .env
```

E configure para usar porta 3000:
```
SSL_ENABLED=false
PORT=3000
```

### 10. Iniciar/Reiniciar com PM2
```bash
pm2 reload ecosystem.config.js --update-env
```

**OU**, se for a primeira vez:
```bash
pm2 start ecosystem.config.js
pm2 save
```

### 11. Verificar status
```bash
pm2 status
pm2 logs monein-api --lines 50
```

### 12. Testar API
```bash
curl -I http://api.monein.com.br
curl https://api.monein.com.br
curl https://api.monein.com.br/api/health
```

## ⚡ Script Completo (Deploy Automático)

Se preferir executar tudo de uma vez:

```bash
cd /home/u991291448/domains/monein.com.br/public_html/api
chmod +x deploy/deploy-https-direct.sh
./deploy/deploy-https-direct.sh
```

## 🔍 Comandos Úteis

```bash
# Ver status
pm2 status

# Ver logs em tempo real
pm2 logs monein-api

# Ver apenas erros
pm2 logs monein-api --err

# Reiniciar
pm2 restart monein-api

# Parar
pm2 stop monein-api

# Ver informações detalhadas
pm2 describe monein-api

# Monitor interativo
pm2 monit
```

## 🌐 URLs para Testar

- **API Base**: https://api.monein.com.br
- **Health Check**: https://api.monein.com.br/api/health
- **Webhook OpenAI**: https://api.monein.com.br/api/webhooks/openai
- **Webhook WhatsApp**: https://api.monein.com.br/api/webhooks/whatsapp

## ⚠️ Troubleshooting

### Erro: "Permission denied" na porta 443

**Solução**: Use porta 3000 e configure proxy no painel da Hostinger

### Erro: "Address already in use"

```bash
pm2 stop all
pm2 start ecosystem.config.js
```

### Erro: "Certificate not found"

```bash
./deploy/find-ssl-certs.sh
# Anote o caminho correto e edite .env manualmente
```

### Ver logs de erro
```bash
pm2 logs monein-api --err
cat logs/pm2-error.log
```

## 📚 Documentação Completa

- [HOSTINGER_SETUP.md](deploy/HOSTINGER_SETUP.md) - Guia completo para Hostinger
- [DEPLOY_HTTPS_DIRECT.md](deploy/DEPLOY_HTTPS_DIRECT.md) - Documentação HTTPS direto

## 🎉 Pronto!

Sua API deve estar rodando em: **https://api.monein.com.br**

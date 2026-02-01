# 🚀 INÍCIO RÁPIDO - Deploy Automático

## ⚡ Deploy em Produção (5 minutos)

### 1️⃣ Configurar Secrets no GitHub

Acesse: `https://github.com/durvallemos-saas/api-monein-com-br/settings/secrets/actions`

Clique em **"New repository secret"** e adicione cada um:

| Nome do Secret | Valor |
|------|-------|
| `SSH_HOST` | `77.37.127.18` |
| `SSH_PORT` | `65002` |
| `SSH_USERNAME` | `u991291448` |
| `SSH_PASSWORD` | `AAnmlg2060##` |
| `SUPABASE_URL` | `https://gsmswwlabefrvouarwkk.supabase.co` |
| `SUPABASE_SERVICE_ROLE_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzbXN3d2xhYmVmcnZvdWFyd2trIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTgxMDQ5NiwiZXhwIjoyMDg1Mzg2NDk2fQ.cGZpJf95zIV2YNuCH53ZiTOGKfiVS3kXSS3yAl59ut4` |
| `SUPABASE_ANON_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzbXN3d2xhYmVmcnZvdWFyd2trIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4MTA0OTYsImV4cCI6MjA4NTM4NjQ5Nn0.VVP3w8x5J6Y0MnR9m9vGO-sR2HN5JCNgXPQBZ6LxZkI` |
| `OPENAI_API_KEY` | `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` |
| `OPENAI_WEBHOOK_SECRET` | `whsec_gBPzO2K6/X8CKpRbAkrb3pKd4TOR+Fy646/i2jEiko0=` |

**Total: 9 secrets** ✅

### 2️⃣ Preparar Servidor (primeira vez)

**Importante:** Seu servidor pode estar bloqueando conexões SSH vindas do GitHub Actions. Se o deploy falhar com "timeout", você terá duas opções:

**Opção A - Liberar IPs do GitHub Actions** (recomendado para produção):
- Adicione os IPs do GitHub Actions no firewall do servidor
- IPs: https://api.github.com/meta (procure por "actions")

**Opção B - Deploy manual via FTP** (alternativa simples):
- Use o script de deploy manual (veja abaixo)

```bash
# Conectar via SSH
ssh -p 65002 u991291448@77.37.127.18

# Baixar e executar script de setup
curl -o server-setup.sh https://raw.githubusercontent.com/durvallemos-saas/api-monein-com-br/main/deploy/server-setup.sh
chmod +x server-setup.sh
bash server-setup.sh
```

### 3️⃣ Fazer Deploy

```bash
# No seu computador local
git add .
git commit -m "Setup automatic deployment"
git push origin main
```

✅ **Pronto!** O GitHub Actions fará o deploy automaticamente.

---

## 📊 Monitorar Deploy

### Via GitHub
1. Acesse: `https://github.com/durvallemos-saas/api-monein-com-br/actions`
2. Clique no workflow em execução para ver os logs

### Via Servidor
```bash
# Conectar via SSH
ssh -p 65002 u991291448@77.37.127.18

# Ver status do PM2
pm2 status

# Ver logs em tempo real
pm2 logs monein-api

# Testar API
curl http://localhost:3000/api/health
```

---

## 🔧 Comandos Úteis

```bash
# No servidor (após conectar via SSH)
pm2 restart monein-api    # Reiniciar aplicação
pm2 stop monein-api       # Parar aplicação
pm2 logs monein-api       # Ver logs
pm2 status                # Ver status de todos os processos

# Health check completo
bash /home/u991291448/domains/monein.com.br/health-check.sh
```

---

## 🌐 Acessar API

- **Local (no servidor)**: `http://localhost:3000`
- **Produção**: `https://api.monein.com.br` (após configurar Nginx + SSL)

### Endpoints disponíveis:
- `GET /` - Informações da API
- `GET /api/health` - Health check
- `POST /api/webhooks/openai` - Webhook OpenAI
- `GET /api/webhooks/whatsapp` - Verificação WhatsApp
- `POST /api/webhooks/whatsapp` - Receber mensagens WhatsApp

---

## 📚 Documentação Completa

- **Deploy detalhado**: [deploy/DEPLOY_GITHUB_ACTIONS.md](deploy/DEPLOY_GITHUB_ACTIONS.md)
- **Setup do servidor**: [deploy/server-setup.sh](deploy/server-setup.sh)
- **Nginx + SSL**: [deploy/README.md](deploy/README.md)
- **API completa**: [README.md](README.md)

---

## 🆘 Troubleshooting

### Deploy falha com "timeout" ou "i/o timeout"

**Causa:** O servidor está bloqueando conexões SSH do GitHub Actions.

**Solução A - Liberar GitHub Actions no firewall:**
1. Obtenha os IPs do GitHub: https://api.github.com/meta
2. No painel da Hostinger, adicione os IPs na whitelist SSH
3. Ou desabilite temporariamente o firewall para testar

**Solução B - Deploy manual via script:**
```bash
# No seu computador local
cd api
npm ci
npm run build

# Fazer upload via FTP para: /home/u991291448/domains/monein.com.br/public_html/api
# Ferramentas: FileZilla, WinSCP, ou linha de comando

# Conectar ao servidor via SSH
ssh -p 65002 u991291448@77.37.127.18

# Navegar para o diretório
cd /home/u991291448/domains/monein.com.br/public_html/api

# Instalar dependências e iniciar
npm ci --production
pm2 delete monein-api || true
pm2 start dist/server.js --name monein-api
pm2 save
```

### Deploy não inicia no GitHub Actions
- ✅ Verifique se todos os 9 secrets estão configurados
- ✅ Veja os logs em "Actions" no GitHub
- ✅ Certifique-se que o workflow foi commitado

### API não responde após deploy
```bash
# Conectar ao servidor
ssh -p 65002 u991291448@77.37.127.18

# Ver últimas 50 linhas de log
pm2 logs monein-api --lines 50

# Reiniciar aplicação
pm2 restart monein-api

# Verificar se a porta está em uso
lsof -i :3000
```

### Porta 3000 já está em uso
```bash
# Ver o que está usando a porta
lsof -i :3000

# Parar todos os processos PM2
pm2 delete all

# Limpar processos zombies
pm2 kill
```

### Erro de permissões no servidor
```bash
# Verificar proprietário dos arquivos
ls -la /home/u991291448/domains/monein.com.br/api

# Ajustar permissões se necessário
chmod -R 755 /home/u991291448/domains/monein.com.br/api
```

---

## 🚀 Desenvolvimento Local (opcional)

Se quiser rodar localmente antes de fazer deploy:

### 1. Instalar dependências
```bash
cd api
npm install
```

### 2. Configurar ambiente
```bash
cp .env.example .env
# Edite o .env com suas credenciais
```

### 3. Rodar em desenvolvimento
```bash
npm run dev
```

A API estará disponível em `http://localhost:3000`

---

**🎉 Tudo pronto! Seu deploy automático está configurado!**

A cada push na branch `main`, o GitHub Actions irá:
1. ✅ Compilar o código TypeScript
2. ✅ Criar o arquivo `.env` com os secrets
3. ✅ Fazer upload para o servidor via SSH
4. ✅ Instalar dependências de produção
5. ✅ Reiniciar a aplicação com PM2

**Próximos passos:**
- Configure o Nginx para expor `api.monein.com.br`
- Configure SSL com Let's Encrypt
- Configure os webhooks da OpenAI e WhatsApp

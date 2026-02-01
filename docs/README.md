# 📚 Índice de Documentação - MONEIN API

## 🚀 Deploy e Configuração

### Deploy
- **[DEPLOY_FTP.md](../DEPLOY_FTP.md)** - Deploy via FTP (FileZilla, WinSCP)
- **[DEPLOY_MANUAL.md](../DEPLOY_MANUAL.md)** - Deploy manual via SSH
- **[deploy-ftp.sh](../deploy-ftp.sh)** - Script automatizado FTP
- **[deploy-manual.sh](../deploy-manual.sh)** - Script automatizado SSH

### Configuração Passo a Passo
1. **[01-CONFIGURAR-DOMINIO.md](01-CONFIGURAR-DOMINIO.md)** - Configurar api.monein.com.br
2. **[02-CONFIGURAR-SSL.md](02-CONFIGURAR-SSL.md)** - HTTPS com Let's Encrypt
3. **[03-CONFIGURAR-WEBHOOKS.md](03-CONFIGURAR-WEBHOOKS.md)** - OpenAI e WhatsApp

## 📖 Documentação Técnica

### Servidor e Deploy
- **[deploy/README.md](../deploy/README.md)** - Deploy em produção
- **[deploy/DEPLOY_GITHUB_ACTIONS.md](../deploy/DEPLOY_GITHUB_ACTIONS.md)** - GitHub Actions (bloqueado por firewall)
- **[deploy/server-setup.sh](../deploy/server-setup.sh)** - Setup inicial do servidor

### Banco de Dados
- **[migrations/README.md](../migrations/README.md)** - Guia de migrations
- **[migrations/000_run_all_migrations.sql](../migrations/000_run_all_migrations.sql)** - Executar todas
- Migrations individuais em [migrations/](../migrations/)

## 🎯 Início Rápido

### Para Desenvolvimento Local
```bash
cd api
npm install
cp .env.example .env
# Edite o .env com suas credenciais
npm run dev
```

### Para Deploy em Produção
```bash
# Via FTP (recomendado)
bash deploy-ftp.sh

# Via SSH
bash deploy-manual.sh
```

## 🔧 Comandos Úteis

### No Servidor
```bash
# Conectar
ssh -p 65002 u991291448@77.37.127.18

# Ver status
npx pm2 status

# Ver logs
npx pm2 logs monein-api

# Reiniciar
npx pm2 restart monein-api
```

### Local
```bash
# Desenvolvimento
npm run dev

# Build
npm run build

# Type check
npm run typecheck
```

## 📊 Endpoints da API

- `GET  /` - Info da API
- `GET  /api/health` - Health check
- `POST /api/webhooks/openai` - Webhook OpenAI
- `GET  /api/webhooks/whatsapp` - Verificação WhatsApp
- `POST /api/webhooks/whatsapp` - Receber mensagens WhatsApp

## 🔐 Credenciais

### Servidor
- **SSH Host:** 77.37.127.18
- **SSH Port:** 65002
- **SSH User:** u991291448
- **SSH Pass:** AAnmlg2060##

### FTP
- **Host:** 77.37.127.18
- **Port:** 21
- **User:** u991291448.monein.com.br
- **Pass:** AAnmlg2060##
- **Path:** /domains/monein.com.br/public_html/api

### Supabase
- **URL:** https://gsmswwlabefrvouarwkk.supabase.co
- **Keys:** Ver `.env.example`

## 🆘 Troubleshooting

### API não responde
```bash
ssh -p 65002 u991291448@77.37.127.18
npx pm2 logs monein-api --lines 50
npx pm2 restart monein-api
```

### Erro de dependências
```bash
cd /home/u991291448/domains/monein.com.br/public_html/api
npm ci --production
npx pm2 restart monein-api
```

### Ver o que está usando a porta
```bash
lsof -i :3000
```

## 🌐 Links Úteis

- **hPanel:** https://hpanel.hostinger.com/
- **Supabase:** https://supabase.com/dashboard
- **OpenAI:** https://platform.openai.com/
- **Meta Developers:** https://developers.facebook.com/
- **Repositório:** https://github.com/durvallemos-saas/api-monein-com-br

## 📝 Estrutura do Projeto

```
api-monein-com-br/
├── api/                    # Backend Node.js
│   ├── src/
│   │   ├── clients/       # Supabase, Redis
│   │   ├── config/        # Configurações
│   │   ├── controllers/   # Webhooks
│   │   ├── middleware/    # Error handler, logger
│   │   ├── routes/        # Rotas
│   │   ├── services/      # Integrações
│   │   └── utils/         # Utilitários
│   ├── package.json
│   └── tsconfig.json
├── deploy/                # Scripts de deploy
├── docs/                  # Documentação
├── migrations/            # SQL migrations
├── deploy-ftp.sh         # Deploy FTP
└── deploy-manual.sh      # Deploy SSH
```

## ✅ Checklist de Deploy

- [ ] API compilada localmente
- [ ] Arquivos enviados via FTP
- [ ] Dependências instaladas no servidor
- [ ] PM2 rodando a aplicação
- [ ] Domínio api.monein.com.br configurado
- [ ] SSL/HTTPS ativo
- [ ] Webhook OpenAI configurado
- [ ] Webhook WhatsApp configurado
- [ ] Health check funcionando
- [ ] Logs sendo salvos no banco

## 🎉 Pronto para Produção!

Sua API está configurada e pronta para uso!

#!/bin/bash
# ==============================================================================
# Script de Deploy Manual - MONEIN API
# ==============================================================================
# Execute este script do seu computador local para fazer deploy
# 
# Uso: bash deploy-manual.sh
# ==============================================================================

set -e

echo "🚀 Deploy Manual - MONEIN API"
echo "=============================="
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Variáveis do servidor
SSH_HOST="77.37.127.18"
SSH_PORT="65002"
SSH_USER="u991291448"
REMOTE_DIR="/home/u991291448/domains/monein.com.br/public_html/api"
LOG_DIR="/home/u991291448/logs"

echo -e "${YELLOW}[1/5]${NC} Compilando projeto..."
cd api
npm ci
npm run build
echo -e "${GREEN}✓${NC} Build concluído"
echo ""

echo -e "${YELLOW}[2/5]${NC} Criando arquivo .env de produção..."
cat > .env << 'EOF'
NODE_ENV=production
PORT=3000
PUBLIC_API_BASE=https://api.monein.com.br
CORS_ORIGIN=https://monein.com.br,https://www.monein.com.br

# Supabase
SUPABASE_URL=https://gsmswwlabefrvouarwkk.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzbXN3d2xhYmVmcnZvdWFyd2trIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTgxMDQ5NiwiZXhwIjoyMDg1Mzg2NDk2fQ.cGZpJf95zIV2YNuCH53ZiTOGKfiVS3kXSS3yAl59ut4
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzbXN3d2xhYmVmcnZvdWFyd2trIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4MTA0OTYsImV4cCI6MjA4NTM4NjQ5Nn0.VVP3w8x5J6Y0MnR9m9vGO-sR2HN5JCNgXPQBZ6LxZkI

# OpenAI
OPENAI_API_KEY=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
OPENAI_WEBHOOK_SECRET=whsec_gBPzO2K6/X8CKpRbAkrb3pKd4TOR+Fy646/i2jEiko0=
EOF
echo -e "${GREEN}✓${NC} Arquivo .env criado"
echo ""

echo -e "${YELLOW}[3/5]${NC} Fazendo backup no servidor..."
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST << 'ENDSSH'
cd /home/u991291448/domains/monein.com.br/public_html/api
if [ -d "dist" ]; then
  mv dist dist.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
fi
ls -t dist.backup.* 2>/dev/null | tail -n +4 | xargs rm -rf 2>/dev/null || true
ENDSSH
echo -e "${GREEN}✓${NC} Backup realizado"
echo ""

echo -e "${YELLOW}[4/5]${NC} Fazendo upload dos arquivos..."
scp -P $SSH_PORT -r dist package.json package-lock.json .env $SSH_USER@$SSH_HOST:$REMOTE_DIR/
echo -e "${GREEN}✓${NC} Arquivos enviados"
echo ""

echo -e "${YELLOW}[5/5]${NC} Instalando dependências e reiniciando aplicação..."
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST << 'ENDSSH'
# Carregar ambiente Node.js
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="/opt/alt/alt-nodejs18/root/usr/bin:$PATH"
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

cd /home/u991291448/domains/monein.com.br/public_html/api

echo "Node version: $(node --version)"
echo "NPM version: $(npm --version)"

# Instalar dependências
npm ci --production --no-audit

# Instalar PM2 se necessário
if ! command -v pm2 &> /dev/null; then
  npm install pm2
fi

# Reiniciar aplicação
npx pm2 delete monein-api 2>/dev/null || true
npx pm2 start dist/server.js --name monein-api --log /home/u991291448/logs/monein-api.log
npx pm2 save

echo ""
echo "Status da aplicação:"
npx pm2 status
ENDSSH

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Deploy concluído com sucesso!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "📊 Comandos úteis:"
echo "  Ver logs:    ssh -p $SSH_PORT $SSH_USER@$SSH_HOST 'npx pm2 logs monein-api'"
echo "  Ver status:  ssh -p $SSH_PORT $SSH_USER@$SSH_HOST 'npx pm2 status'"
echo "  Reiniciar:   ssh -p $SSH_PORT $SSH_USER@$SSH_HOST 'npx pm2 restart monein-api'"
echo ""
echo "🌐 API: https://api.monein.com.br"
echo ""

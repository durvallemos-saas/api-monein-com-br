#!/bin/bash
# ==============================================================================
# Script de Deploy via FTP - MONEIN API
# ==============================================================================
# Execute este script do seu computador local para fazer deploy via FTP
# 
# Uso: bash deploy-ftp.sh
# ==============================================================================

set -e

echo "🚀 Deploy via FTP - MONEIN API"
echo "==============================="
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Variáveis FTP
FTP_HOST="77.37.127.18"
FTP_PORT="21"
FTP_USER="u991291448.monein.com.br"
FTP_REMOTE_DIR="/domains/monein.com.br/public_html/api"

# Variáveis SSH (para comandos finais)
SSH_HOST="77.37.127.18"
SSH_PORT="65002"
SSH_USER="u991291448"
REMOTE_DIR="/home/u991291448/domains/monein.com.br/public_html/api"

# Solicitar senha FTP
echo -e "${YELLOW}Digite a senha FTP:${NC}"
read -s FTP_PASS
echo ""

echo -e "${YELLOW}[1/4]${NC} Compilando projeto..."
cd api
npm ci
npm run build
echo -e "${GREEN}✓${NC} Build concluído"
echo ""

echo -e "${YELLOW}[2/4]${NC} Criando arquivo .env de produção..."
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

echo -e "${YELLOW}[3/4]${NC} Enviando arquivos via FTP..."

# Criar arquivo de comandos lftp
cat > /tmp/ftp-deploy.txt << ENDLFTP
set ftp:ssl-allow no
set net:timeout 30
set net:max-retries 3
open -u $FTP_USER,$FTP_PASS ftp://$FTP_HOST:$FTP_PORT
lcd $(pwd)
cd $FTP_REMOTE_DIR

# Fazer backup do dist anterior (se existir)
!echo "Fazendo backup..."
mrm dist.backup.* -f 2>/dev/null || true
mrm dist -f 2>/dev/null || true

# Criar diretórios se não existirem
mkdir -f dist
mkdir -f node_modules

# Enviar arquivos
mirror -R dist dist
put package.json
put package-lock.json
put .env

bye
ENDLFTP

# Executar lftp
if command -v lftp &> /dev/null; then
    lftp -f /tmp/ftp-deploy.txt
    rm /tmp/ftp-deploy.txt
    echo -e "${GREEN}✓${NC} Arquivos enviados via lftp"
else
    echo -e "${YELLOW}lftp não encontrado. Usando curl...${NC}"
    
    # Fallback: usar curl para FTP
    # Enviar package.json
    curl -T package.json ftp://$FTP_USER:$FTP_PASS@$FTP_HOST:$FTP_PORT$FTP_REMOTE_DIR/
    curl -T package-lock.json ftp://$FTP_USER:$FTP_PASS@$FTP_HOST:$FTP_PORT$FTP_REMOTE_DIR/
    curl -T .env ftp://$FTP_USER:$FTP_PASS@$FTP_HOST:$FTP_PORT$FTP_REMOTE_DIR/
    
    # Para o dist, precisamos enviar recursivamente
    echo "Enviando arquivos do dist..."
    cd dist
    find . -type f | while read file; do
        dir=$(dirname "$file")
        if [ "$dir" != "." ]; then
            curl --ftp-create-dirs -T "$file" ftp://$FTP_USER:$FTP_PASS@$FTP_HOST:$FTP_PORT$FTP_REMOTE_DIR/dist/"$file"
        else
            curl -T "$file" ftp://$FTP_USER:$FTP_PASS@$FTP_HOST:$FTP_PORT$FTP_REMOTE_DIR/dist/
        fi
    done
    cd ..
    
    echo -e "${GREEN}✓${NC} Arquivos enviados via curl"
fi

echo ""

echo -e "${YELLOW}[4/4]${NC} Instalando dependências e reiniciando aplicação..."
echo -e "${YELLOW}Digite a senha SSH:${NC}"
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
echo "Instalando dependências..."
npm ci --production --no-audit

# Instalar PM2 se necessário
if ! command -v pm2 &> /dev/null; then
  echo "Instalando PM2..."
  npm install pm2
fi

# Reiniciar aplicação
echo "Reiniciando aplicação..."
npx pm2 delete monein-api 2>/dev/null || true
npx pm2 start dist/server.js --name monein-api --log /home/u991291448/logs/monein-api.log
npx pm2 save

echo ""
echo "Status da aplicação:"
npx pm2 status
ENDSSH

cd ..

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Deploy concluído com sucesso!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "📊 Comandos úteis:"
echo "  Ver logs:    ssh -p $SSH_PORT $SSH_USER@$SSH_HOST 'npx pm2 logs monein-api'"
echo "  Ver status:  ssh -p $SSH_PORT $SSH_USER@$SSH_HOST 'npx pm2 status'"
echo "  Reiniciar:   ssh -p $SSH_PORT $SSH_USER@$SSH_HOST 'cd $REMOTE_DIR && npx pm2 restart monein-api'"
echo ""
echo "🌐 API: https://api.monein.com.br"
echo ""

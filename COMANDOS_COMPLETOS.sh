#!/bin/bash
# ==============================================================================
# COMANDOS COMPLETOS - COPIAR E COLAR NO SSH
# ==============================================================================
# Execute este arquivo linha por linha no servidor SSH da Hostinger
# ==============================================================================

# PASSO 1: Conectar via SSH
# ssh -p 65002 u991291448@77.37.127.18

# PASSO 2: Limpar e clonar repositório
cd /home/u991291448/domains/monein.com.br/public_html
rm -rf api
git clone https://github.com/durvallemos-saas/api-monein-com-br.git api

# PASSO 3: Entrar na pasta da API Node.js
cd api/api

# PASSO 4: Instalar dependências
npm install

# PASSO 5: Criar arquivo .env (copie e cole todo o bloco)
cat > .env << 'EOF'
NODE_ENV=production
PORT=3000
PUBLIC_API_BASE=https://api.monein.com.br
CORS_ORIGIN=https://gestor.monein.com.br,https://monein.com.br

SUPABASE_URL=https://gsmswwlabefrvouarwkk.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzbXN3d2xhYmVmcnZvdWFyd2trIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTgxMDQ5NiwiZXhwIjoyMDg1Mzg2NDk2fQ.cGZpJf95zIV2YNuCH53ZiTOGKfiVS3kXSS3yAl59ut4
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzbXN3d2xhYmVmcnZvdWFyd2trIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4MTA0OTYsImV4cCI6MjA4NTM4NjQ5Nn0.VVP3w8x5J6Y0MnR9m9vGO-sR2HN5JCNgXPQBZ6LxZkI

OPENAI_API_KEY=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
OPENAI_WEBHOOK_SECRET=whsec_gBPzO2K6/X8CKpRbAkrb3pKd4TOR+Fy646/i2jEiko0=
EOF

# PASSO 6: Verificar se .env foi criado
cat .env

# PASSO 7: Compilar TypeScript
npm run build

# PASSO 8: Verificar se compilou
ls -la dist/

# PASSO 9: Parar aplicação anterior (se existir)
pm2 stop monein-api 2>/dev/null || true
pm2 delete monein-api 2>/dev/null || true

# PASSO 10: Iniciar com PM2
pm2 start ecosystem.config.js

# PASSO 11: Salvar configuração do PM2
pm2 save

# PASSO 12: Configurar PM2 para iniciar no boot
pm2 startup

# PASSO 13: Verificar status
pm2 status

# PASSO 14: Ver logs
pm2 logs monein-api --lines 50

# PASSO 15: Testar API localmente
echo ""
echo "🧪 Testando API..."
curl -s http://localhost:3000/api/health | head -20

echo ""
echo "✅ SETUP CONCLUÍDO!"
echo ""
echo "🌐 URLs para testar:"
echo "   - http://api.monein.com.br:3000/api/health"
echo "   - https://api.monein.com.br/api/health"
echo ""
echo "📋 Comandos úteis:"
echo "   pm2 status              - Ver status"
echo "   pm2 logs monein-api     - Ver logs"
echo "   pm2 restart monein-api  - Reiniciar"
echo "   pm2 stop monein-api     - Parar"
echo ""

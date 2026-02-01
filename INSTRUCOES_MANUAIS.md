# 🚨 ATENÇÃO: Execute Manualmente no SSH

O repositório é **privado** e precisa de autenticação. Execute estes comandos **manualmente** no SSH:

## 📋 Comandos para Copiar e Colar

```bash
# 1. Conectar via SSH
ssh -p 65002 u991291448@77.37.127.18

# 2. Ir para o diretório
cd /home/u991291448/domains/monein.com.br/public_html

# 3. Fazer backup se existir algo
[ -d "api" ] && mv api api.backup.$(date +%s)

# 4. Criar nova pasta
mkdir -p api
cd api

# 5. Tornar repositório público OU usar deploy key
# Vá em GitHub > Settings > General > Change visibility > Public
# OU configure uma deploy key

# 6. Clonar repositório (depois de tornar público)
git clone https://github.com/durvallemos-saas/api-monein-com-br.git .

# 7. Entrar na pasta api
cd api

# 8. Criar arquivo .env (COPIE TODO O BLOCO)
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

# 9. Verificar se .env foi criado
cat .env

# 10. Adicionar Node.js ao PATH (se necessário)
export PATH=$PATH:/usr/local/bin:/opt/alt/alt-nodejs18/root/usr/bin
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 11. Verificar Node.js
node --version
npm --version

# 12. Instalar dependências
npm install

# 13. Compilar TypeScript
npm run build

# 14. Ver se compilou
ls -la dist/

# 15. Iniciar com PM2
pm2 stop monein-api 2>/dev/null || true
pm2 delete monein-api 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save

# 16. Ver status
pm2 status
pm2 logs monein-api --lines 50

# 17. Testar localmente
curl http://localhost:3000/api/health
```

## ⚠️ Problemas Comuns

### 1. "npm: command not found"

Node.js não está no PATH. Tente:

```bash
# Opção 1: NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 18

# Opção 2: Path alternativo
export PATH=$PATH:/opt/alt/alt-nodejs18/root/usr/bin

# Opção 3: Verificar onde está instalado
find ~ -name "npm" 2>/dev/null
```

### 2. "pm2: command not found"

PM2 não está instalado ou não está no PATH:

```bash
# Instalar PM2
npm install -g pm2

# OU adicionar ao PATH
export PATH=$PATH:~/.npm-global/bin
export PATH=$PATH:~/node_modules/.bin
```

### 3. "fatal: could not read Username"

Repositório é privado. **Soluções:**

**Opção A - Tornar Público (Recomendado para este caso):**
1. Ir em: https://github.com/durvallemos-saas/api-monein-com-br/settings
2. Scroll até o final > "Danger Zone"
3. "Change visibility" > "Make public"

**Opção B - Usar Token:**
```bash
git clone https://SEU_TOKEN@github.com/durvallemos-saas/api-monein-com-br.git .
```

**Opção C - Usar Deploy Key:**
```bash
# Gerar chave SSH no servidor
ssh-keygen -t ed25519 -C "deploy@monein"

# Copiar chave pública
cat ~/.ssh/id_ed25519.pub

# Adicionar em GitHub > Settings > Deploy keys
```

## 🎯 Método Alternativo: Via Painel Hostinger

Se o SSH estiver complicado, use o **File Manager** do painel Hostinger:

1. Baixe o ZIP do repositório no GitHub
2. Faça upload para `/home/u991291448/domains/monein.com.br/public_html/`
3. Extraia o ZIP
4. Renomeie a pasta para `api`
5. Use o Terminal do painel Hostinger para executar os comandos

## 📞 Última Opção

Se nada funcionar, me informe e eu:
1. Torno o repositório público temporariamente
2. Ou crio um release com ZIP direto
3. Ou configuro via CI/CD automático

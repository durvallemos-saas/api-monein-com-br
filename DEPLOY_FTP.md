# 🚀 Deploy via FTP - Guia Rápido

Deploy mais simples usando FTP para upload de arquivos.

## ⚡ Como Usar

```bash
bash deploy-ftp.sh
```

### O que o script faz:

1. ✅ Compila o projeto localmente
2. ✅ Cria o arquivo `.env` de produção
3. ✅ Envia arquivos via FTP
4. ✅ Conecta via SSH para instalar dependências e reiniciar PM2

### Senhas solicitadas:

1. **Senha FTP:** `AAnmlg2060##`
2. **Senha SSH:** `AAnmlg2060##` (apenas no final)

## 📦 Credenciais FTP

- **Host:** `77.37.127.18`
- **Porta:** `21`
- **Usuário:** `u991291448.monein.com.br`
- **Senha:** `AAnmlg2060##`
- **Pasta:** `/domains/monein.com.br/public_html/api`

## 🔧 Ferramentas Necessárias

O script funciona com:
- **lftp** (recomendado) - Instale com: `brew install lftp` (Mac) ou `sudo apt install lftp` (Linux)
- **curl** (fallback automático) - Já vem instalado na maioria dos sistemas

## 🎯 Deploy Manual via FileZilla

Se preferir usar interface gráfica:

### 1. Baixe o FileZilla
https://filezilla-project.org/

### 2. Configure a conexão

- **Host:** `77.37.127.18`
- **Usuário:** `u991291448.monein.com.br`
- **Senha:** `AAnmlg2060##`
- **Porta:** `21`
- **Protocolo:** FTP (não SFTP)

### 3. Build local

```bash
cd api
npm ci
npm run build
```

### 4. Criar .env

Crie o arquivo `api/.env` com:

```env
NODE_ENV=production
PORT=3000
PUBLIC_API_BASE=https://api.monein.com.br
CORS_ORIGIN=https://monein.com.br,https://www.monein.com.br

SUPABASE_URL=https://gsmswwlabefrvouarwkk.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzbXN3d2xhYmVmcnZvdWFyd2trIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTgxMDQ5NiwiZXhwIjoyMDg1Mzg2NDk2fQ.cGZpJf95zIV2YNuCH53ZiTOGKfiVS3kXSS3yAl59ut4
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzbXN3d2xhYmVmcnZvdWFyd2trIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4MTA0OTYsImV4cCI6MjA4NTM4NjQ5Nn0.VVP3w8x5J6Y0MnR9m9vGO-sR2HN5JCNgXPQBZ6LxZkI

OPENAI_API_KEY=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
OPENAI_WEBHOOK_SECRET=whsec_gBPzO2K6/X8CKpRbAkrb3pKd4TOR+Fy646/i2jEiko0=
```

### 5. Upload via FileZilla

Envie estes arquivos/pastas para `/domains/monein.com.br/public_html/api`:
- `dist/` (pasta completa)
- `package.json`
- `package-lock.json`
- `.env`

### 6. Conectar via SSH e reiniciar

```bash
ssh -p 65002 u991291448@77.37.127.18

# No servidor
cd /home/u991291448/domains/monein.com.br/public_html/api
npm ci --production
npm install pm2
npx pm2 restart monein-api || npx pm2 start dist/server.js --name monein-api
npx pm2 status
```

## 🪟 Windows (WinSCP)

### 1. Baixe o WinSCP
https://winscp.net/

### 2. Configure
- **Protocolo:** FTP
- **Host:** `77.37.127.18`
- **Porta:** `21`
- **Usuário:** `u991291448.monein.com.br`
- **Senha:** `AAnmlg2060##`

### 3. Arraste e solte os arquivos

Mesmo processo do FileZilla.

## 📊 Comandos Úteis

```bash
# Ver status
ssh -p 65002 u991291448@77.37.127.18 'npx pm2 status'

# Ver logs
ssh -p 65002 u991291448@77.37.127.18 'npx pm2 logs monein-api'

# Reiniciar
ssh -p 65002 u991291448@77.37.127.18 'cd /home/u991291448/domains/monein.com.br/public_html/api && npx pm2 restart monein-api'
```

## 🎉 Pronto!

Agora você tem 3 opções de deploy:
1. ✅ Script automatizado: `bash deploy-ftp.sh`
2. ✅ FileZilla (GUI)
3. ✅ WinSCP (Windows)

Escolha a que preferir! 🚀

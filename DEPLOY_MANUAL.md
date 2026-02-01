# 🚀 Deploy Manual - Guia Completo

Como o servidor Hostinger está bloqueando conexões SSH do GitHub Actions, use este método manual para fazer deploy.

## ⚡ Deploy em 1 Comando

```bash
bash deploy-manual.sh
```

O script irá automaticamente:
1. ✅ Compilar o projeto TypeScript
2. ✅ Criar o arquivo `.env` de produção
3. ✅ Fazer backup da versão anterior no servidor
4. ✅ Enviar os arquivos via SCP
5. ✅ Instalar dependências no servidor
6. ✅ Reiniciar a aplicação com PM2

## 📋 Pré-requisitos

- SSH instalado no seu computador
- Acesso SSH ao servidor (senha será solicitada 3 vezes)
- Node.js 18+ instalado localmente

## 🔧 Como Usar

### Passo 1: Executar o Deploy

```bash
# No diretório raiz do projeto
bash deploy-manual.sh
```

Você será solicitado a digitar a senha SSH **3 vezes**:
1. Para fazer backup
2. Para enviar arquivos
3. Para instalar e reiniciar

**Senha SSH:** `AAnmlg2060##`

### Passo 2: Acompanhar Deploy

O script mostrará o progresso em tempo real:

```
🚀 Deploy Manual - MONEIN API
==============================

[1/5] Compilando projeto...
✓ Build concluído

[2/5] Criando arquivo .env de produção...
✓ Arquivo .env criado

[3/5] Fazendo backup no servidor...
✓ Backup realizado

[4/5] Fazendo upload dos arquivos...
✓ Arquivos enviados

[5/5] Instalando dependências e reiniciando aplicação...
Node version: v18.20.8
NPM version: 10.8.2

✓ Deploy concluído com sucesso!
```

## 🎯 Deploy Rápido (alternativa)

Se preferir fazer manualmente passo a passo:

```bash
# 1. Build local
cd api
npm ci
npm run build

# 2. Enviar arquivos
scp -P 65002 -r dist package.json package-lock.json .env u991291448@77.37.127.18:/home/u991291448/domains/monein.com.br/public_html/api/

# 3. Conectar e reiniciar
ssh -p 65002 u991291448@77.37.127.18

# 4. No servidor
cd /home/u991291448/domains/monein.com.br/public_html/api
npm ci --production
npm install pm2
npx pm2 restart monein-api || npx pm2 start dist/server.js --name monein-api
```

## 📊 Comandos Úteis

### Ver logs em tempo real
```bash
ssh -p 65002 u991291448@77.37.127.18 'npx pm2 logs monein-api'
```

### Ver status da aplicação
```bash
ssh -p 65002 u991291448@77.37.127.18 'npx pm2 status'
```

### Reiniciar aplicação
```bash
ssh -p 65002 u991291448@77.37.127.18 'cd /home/u991291448/domains/monein.com.br/public_html/api && npx pm2 restart monein-api'
```

### Parar aplicação
```bash
ssh -p 65002 u991291448@77.37.127.18 'npx pm2 stop monein-api'
```

### Deletar aplicação
```bash
ssh -p 65002 u991291448@77.37.127.18 'npx pm2 delete monein-api'
```

## 🔍 Verificar Deploy

Após o deploy, teste os endpoints:

```bash
# Health check
curl http://localhost:3000/api/health

# Ou via domínio (se Nginx configurado)
curl https://api.monein.com.br/api/health
```

## 🐛 Troubleshooting

### Erro: "Permission denied (publickey,password)"

**Solução:** Verifique se a senha está correta: `AAnmlg2060##`

### Erro: "npm: command not found"

**Solução:** Node.js não está no PATH. Conecte manualmente e rode:
```bash
ssh -p 65002 u991291448@77.37.127.18
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
node --version
```

### Erro: "pm2: command not found"

**Solução:** Use `npx pm2` em vez de apenas `pm2`:
```bash
npx pm2 status
npx pm2 restart monein-api
```

### Aplicação não inicia

**Solução:** Verifique os logs:
```bash
ssh -p 65002 u991291448@77.37.127.18
cd /home/u991291448/domains/monein.com.br/public_html/api
npx pm2 logs monein-api --lines 50
```

### Porta 3000 já em uso

**Solução:** 
```bash
ssh -p 65002 u991291448@77.37.127.18
npx pm2 delete monein-api
lsof -i :3000  # Ver o que está usando
npx pm2 start dist/server.js --name monein-api
```

## 🔒 Sobre Chaves SSH

O script usa **autenticação por senha**, não chaves SSH. Isso é mais simples e funciona bem para deploy manual.

Se quiser usar chaves SSH no futuro:

1. Gerar chave local:
```bash
ssh-keygen -t ed25519 -C "deploy@monein"
```

2. Copiar para servidor:
```bash
ssh-copy-id -p 65002 u991291448@77.37.127.18
```

3. Depois não precisará mais digitar senha!

## 🎉 Pronto!

Agora você tem um script de deploy manual confiável que funciona mesmo com o firewall da Hostinger bloqueando GitHub Actions.

**Próximos passos:**
- Configure Nginx para expor `api.monein.com.br`
- Configure SSL com Let's Encrypt
- Configure webhooks da OpenAI e WhatsApp

# 🚀 Solução Final - Hostinger Compartilhada

## ✅ Situação Atual
- API **funcionando** em `localhost:3000` no servidor
- Porta 3000 **bloqueada** externamente (normal em hospedagem compartilhada)
- SSL já instalado para `api.monein.com.br`

## 🎯 Solução: Configurar no Painel Hostinger

### Opção 1: Aplicação Node.js (Recomendado)

1. **Acessar hPanel**
   - Vá em: https://hpanel.hostinger.com/
   - Websites → selecione `monein.com.br`

2. **Procurar "Aplicações"**
   - Menu lateral: **"Avançado"** ou **"Advanced"**
   - Procure por **"Select PHP Version"** ou **"Setup Node.js App"**
   - Ou procure por **"Application"** / **"Aplicações"**

3. **Configurar Aplicação Node.js**
   ```
   Application root: /domains/monein.com.br/public_html/api/api
   Application URL: https://api.monein.com.br
   Application startup file: dist/server.js
   Node.js version: 20.x
   ```

4. **Variáveis de Ambiente** (adicionar no painel)
   ```
   NODE_ENV=production
   PORT=3000
   ```

5. **Restart** a aplicação no painel

### Opção 2: Proxy com .htaccess (Alternativa)

Se não encontrar opção Node.js, configure proxy Apache:

```bash
ssh -p 65002 u991291448@77.37.127.18
cd /home/u991291448/domains/api.monein.com.br/public_html
nano .htaccess
```

Cole este conteúdo:
```apache
RewriteEngine On

# Forçar HTTPS
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Proxy para Node.js na porta 3000
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ http://127.0.0.1:3000/$1 [P,L]

# Configurações de Proxy
ProxyRequests Off
ProxyPreserveHost On
ProxyPass / http://127.0.0.1:3000/
ProxyPassReverse / http://127.0.0.1:3000/

# Headers
RequestHeader set X-Forwarded-Proto "https"
RequestHeader set X-Forwarded-Port "443"
```

**Importante**: Se Apache não tiver módulo `mod_proxy`, entre em contato com suporte Hostinger.

### Opção 3: Usar Porta 80 Diretamente (Requer Permissão)

Se conseguir permissão root/sudo:

```bash
# Dar permissão ao Node.js
sudo setcap 'cap_net_bind_service=+ep' /opt/alt/alt-nodejs20/root/usr/bin/node

# Alterar .env
PORT=80

# Reiniciar API
```

**Problema**: Na hospedagem compartilhada, Apache/LiteSpeed já usa porta 80.

## 🎫 Script de Suporte

Envie este ticket ao suporte da Hostinger:

---

**Assunto**: Configurar Proxy Reverso para Aplicação Node.js

**Mensagem**:

Olá,

Preciso configurar um proxy reverso para minha aplicação Node.js no domínio **api.monein.com.br**.

**Detalhes:**
- Domínio: `api.monein.com.br`
- Aplicação Node.js rodando em: `localhost:3000`
- Caminho: `/home/u991291448/domains/monein.com.br/public_html/api/api`
- Arquivo principal: `dist/server.js`
- Node.js versão: 20.x
- SSL: Já está instalado (Let's Encrypt)

**Preciso que:**
1. Requisições para `https://api.monein.com.br` sejam redirecionadas para `http://localhost:3000`
2. SSL seja mantido ativo
3. Headers corretos sejam passados (X-Forwarded-For, X-Real-IP)

**Ou:**
Se houver opção de "Node.js Application" no painel, me informem como configurar.

Agradeço!

---

## 🔧 Manter Aplicação Rodando

### Script de Auto-Start

Crie um script para manter a aplicação sempre rodando:

```bash
ssh -p 65002 u991291448@77.37.127.18
nano ~/start-api.sh
```

Cole:
```bash
#!/bin/bash
export PATH=$PATH:/opt/alt/alt-nodejs20/root/usr/bin
cd /home/u991291448/domains/monein.com.br/public_html/api/api

# Matar processo anterior
pkill -f "node dist/server.js"

# Iniciar novo
nohup node dist/server.js >> logs/app.log 2>&1 &
echo "API iniciada - PID: $!"
```

Tornar executável:
```bash
chmod +x ~/start-api.sh
```

### Adicionar ao Cron (Auto-restart se cair)

```bash
crontab -e
```

Adicione:
```cron
# Verificar a cada 5 minutos se API está rodando
*/5 * * * * pgrep -f "node dist/server.js" || /home/u991291448/start-api.sh
```

## 📊 Verificar Status

```bash
# Ver se está rodando
ps aux | grep "node dist/server.js"

# Ver logs
tail -f /home/u991291448/domains/monein.com.br/public_html/api/api/logs/app.log

# Testar internamente
curl http://localhost:3000/api/health
```

## 🎯 Próximos Passos

1. **Escolher uma opção**:
   - ✅ Configurar no painel Hostinger (mais fácil)
   - ✅ Criar .htaccess com proxy (manual)
   - ✅ Contatar suporte Hostinger (mais rápido)

2. **Depois que o proxy estiver configurado**:
   ```bash
   curl https://api.monein.com.br/api/health
   ```

3. **Configurar auto-start** (script + cron)

## ⚠️ Limitações da Hospedagem Compartilhada

Se continuar com problemas:

### Alternativas Recomendadas:

1. **VPS Hostinger** (€3.99/mês)
   - Controle total
   - Qualquer porta
   - PM2, nginx, etc.

2. **Plataformas Serverless** (Gratuito)
   - Vercel (recomendado)
   - Railway
   - Render
   - Fly.io

3. **Cloud Providers**
   - DigitalOcean App Platform ($5/mês)
   - AWS Lightsail ($3.50/mês)
   - Google Cloud Run (pay-as-you-go)

### Deploy Rápido no Vercel (5 minutos):

```bash
# Instalar Vercel CLI
npm i -g vercel

# Deploy
cd /workspaces/api-monein-com-br/api
vercel

# Configurar domínio customizado
vercel domains add api.monein.com.br
```

---

**Resumo**: A API está rodando! Só precisa do proxy reverso. Configure no painel ou contate o suporte. 🚀

# 🔧 Troubleshooting - API MONEIN

## ⚠️ Problema: API não responde (Connection Timeout)

### Sintomas
- `curl` fica travado/processando
- Timeout após alguns segundos
- Não consegue acessar a API externamente

### Possíveis Causas

#### 1. **Aplicação não está rodando**

**Verificar:**
```bash
pm2 status
pm2 logs monein-api --lines 50
```

**Solução:**
```bash
pm2 restart monein-api
# ou
pm2 start ecosystem.config.js
```

#### 2. **Porta bloqueada no firewall da Hostinger**

A Hostinger compartilhada pode bloquear portas customizadas (3000, 443, 80).

**Solução A** - Usar proxy do painel Hostinger:
1. Acessar painel da Hostinger
2. Ir em "Aplicações Node.js" ou "Proxy"
3. Configurar:
   - Domínio: api.monein.com.br
   - Porta da aplicação: 3000
   - SSL: Ativado

**Solução B** - Usar porta padrão gerenciada:
Configure no `.env`:
```bash
PORT=3000
SSL_ENABLED=false
```

E deixe a Hostinger gerenciar o proxy/SSL automaticamente.

#### 3. **Node.js sem permissão para portas 80/443**

**Verificar:**
```bash
getcap $(which node)
```

**Solução:**
```bash
sudo setcap 'cap_net_bind_service=+ep' $(which node)
pm2 restart monein-api
```

**Se não tiver sudo:**
Use porta alta (3000) no `.env`:
```bash
PORT=3000
SSL_ENABLED=false
```

#### 4. **Erro no código/certificados**

**Verificar logs:**
```bash
pm2 logs monein-api --err
cat logs/pm2-error.log
```

**Solução:**
```bash
# Recompilar
npm run build

# Reiniciar
pm2 delete monein-api
pm2 start ecosystem.config.js
```

## 🧪 Script de Teste

Execute no servidor SSH:

```bash
cd /home/u991291448/domains/monein.com.br/public_html/api
chmod +x deploy/test-api.sh
./deploy/test-api.sh
```

Este script verifica:
- Status do PM2
- Portas em uso
- Logs recentes
- Conectividade local
- Configuração .env
- Permissões do Node.js

## 📋 Checklist de Debug

### No Servidor (SSH)

```bash
# 1. Verificar se está rodando
pm2 status

# 2. Ver logs
pm2 logs monein-api --lines 100

# 3. Testar localmente
curl http://localhost:3000/api/health

# 4. Ver portas em uso
netstat -tulpn | grep node
# ou
ss -tulpn | grep node

# 5. Ver processos Node
ps aux | grep node

# 6. Verificar .env
cat .env | grep -E "PORT|SSL_ENABLED|NODE_ENV"

# 7. Verificar permissões
getcap $(which node)

# 8. Ver configuração PM2
pm2 describe monein-api
```

### Da Sua Máquina Local

```bash
# 1. Testar DNS
nslookup api.monein.com.br

# 2. Testar porta específica (com timeout)
curl -m 5 http://api.monein.com.br:3000/api/health

# 3. Testar HTTPS
curl -m 5 https://api.monein.com.br/api/health

# 4. Ver headers
curl -I https://api.monein.com.br
```

## 🔄 Soluções Rápidas

### Solução 1: Reiniciar Tudo

```bash
pm2 delete monein-api
pm2 start ecosystem.config.js
pm2 save
pm2 logs monein-api
```

### Solução 2: Modo Simples (Porta 3000, sem SSL)

Editar `.env`:
```bash
NODE_ENV=production
PORT=3000
SSL_ENABLED=false
PUBLIC_API_BASE=https://api.monein.com.br
```

Reiniciar:
```bash
pm2 reload ecosystem.config.js --update-env
```

Configurar proxy no painel da Hostinger.

### Solução 3: Rebuild Completo

```bash
# Backup
cp .env .env.backup

# Limpar
rm -rf dist/ node_modules/

# Reinstalar
npm install

# Build
npm run build

# Verificar se compilou
ls -la dist/

# Reiniciar
pm2 delete monein-api
pm2 start ecosystem.config.js
pm2 save
```

## 🆘 Limitações da Hostinger Compartilhada

### Restrições Comuns

1. **Portas bloqueadas**: Apenas portas gerenciadas pela Hostinger funcionam
2. **Sem acesso root/sudo**: Não pode dar permissões ao Node.js
3. **Firewall gerenciado**: Portas customizadas podem ser bloqueadas
4. **Proxy automático**: Hostinger pode ter proxy interno

### Recomendação

**Para Hostinger Compartilhada:**
- Use **porta 3000** (padrão Node.js)
- Desabilite SSL direto: `SSL_ENABLED=false`
- Configure proxy no **painel da Hostinger**
- Deixe a Hostinger gerenciar SSL

**Para produção séria:**
- Considere migrar para **VPS** (Hostinger VPS, DigitalOcean, AWS, etc.)
- Ou use plataformas serverless (Vercel, Netlify, Railway)

## 📞 Suporte Hostinger

Se nada funcionar, contate o suporte:

1. **Chat**: Painel Hostinger → Ajuda
2. **Ticket**: Abrir ticket de suporte
3. **Perguntar**:
   - "Como configurar Node.js na porta 3000?"
   - "Como ativar proxy reverso para api.monein.com.br?"
   - "Quais portas estão disponíveis para Node.js?"

## ✅ Configuração Recomendada

### Para Hostinger Compartilhada

**1. Arquivo `.env`:**
```bash
NODE_ENV=production
PORT=3000
SSL_ENABLED=false
PUBLIC_API_BASE=https://api.monein.com.br
CORS_ORIGIN=https://gestor.monein.com.br,https://monein.com.br

SUPABASE_URL=sua_url
SUPABASE_SERVICE_ROLE_KEY=sua_key
SUPABASE_ANON_KEY=sua_key
```

**2. Iniciar aplicação:**
```bash
npm run build
pm2 start ecosystem.config.js
pm2 save
```

**3. Configurar no painel Hostinger:**
- Domínio: `api.monein.com.br`
- Tipo: Aplicação Node.js
- Porta: 3000
- SSL: Ativado (Let's Encrypt)

**4. Testar:**
```bash
# No servidor
curl http://localhost:3000/api/health

# Da sua máquina
curl https://api.monein.com.br/api/health
```

---

**Precisa de mais ajuda?** Execute o script de teste:
```bash
./deploy/test-api.sh
```

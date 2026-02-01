# 🌐 Configurar Subdomínio api.monein.com.br

## Passo 1: Criar Subdomínio na Hostinger

### Via hPanel (Interface Web)

1. **Acesse o hPanel**
   - URL: https://hpanel.hostinger.com/
   - Login: u991291448

2. **Vá para Domínios**
   - Menu lateral: **Websites**
   - Selecione: **monein.com.br**

3. **Criar Subdomínio**
   - Clique em: **Subdomains**
   - Clique em: **Create Subdomain**
   - Preencha:
     - **Subdomain:** `api`
     - **Document Root:** `/domains/monein.com.br/public_html/api`
   - Clique em: **Create**

4. **Aguardar Propagação DNS**
   - Pode levar de 5 minutos a 24 horas
   - Geralmente é rápido (5-15 minutos)

## Passo 2: Configurar DNS (se necessário)

Se o domínio não estiver usando os nameservers da Hostinger:

### Adicionar Registro DNS

1. **Acesse o painel DNS** (onde seu domínio está registrado)

2. **Adicionar registro A:**
   ```
   Tipo: A
   Nome: api
   Valor: 77.37.127.18
   TTL: 3600 (ou 1 hora)
   ```

3. **Aguardar propagação**

## Passo 3: Verificar Configuração

### Testar DNS

```bash
# Ver se o DNS está resolvendo
nslookup api.monein.com.br

# Ou com dig
dig api.monein.com.br

# Ping
ping api.monein.com.br
```

Deve retornar o IP: `77.37.127.18`

### Testar HTTP

```bash
# Teste básico
curl http://api.monein.com.br

# Ou teste a porta 3000 diretamente
curl http://api.monein.com.br:3000/api/health
```

## Passo 4: Configurar .htaccess (Opcional)

Se a Hostinger estiver usando Apache, crie um arquivo `.htaccess`:

```bash
ssh -p 65002 u991291448@77.37.127.18

cd /home/u991291448/domains/monein.com.br/public_html/api

cat > .htaccess << 'EOF'
# Proxy para Node.js na porta 3000
RewriteEngine On
RewriteRule ^$ http://127.0.0.1:3000/ [P,L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ http://127.0.0.1:3000/$1 [P,L]
EOF
```

## 🔍 Troubleshooting

### Erro: "DNS não resolve"

**Solução:**
- Aguarde mais tempo (até 24h)
- Limpe cache DNS local: `sudo killall -HUP mDNSResponder` (Mac) ou `ipconfig /flushdns` (Windows)
- Use DNS público: `8.8.8.8` (Google)

### Erro: "Conexão recusada"

**Solução:**
- Verifique se a API está rodando: `ssh -p 65002 u991291448@77.37.127.18 'npx pm2 status'`
- Verifique os logs: `npx pm2 logs monein-api`
- Reinicie: `npx pm2 restart monein-api`

### Erro: "502 Bad Gateway"

**Solução:**
- A API não está rodando ou travou
- Conecte via SSH e verifique: `npx pm2 status`
- Veja os logs: `npx pm2 logs monein-api --lines 50`

## ✅ Verificação Final

Depois de configurado, teste:

```bash
# Deve retornar status da API
curl http://api.monein.com.br:3000/api/health

# Ou (se proxy configurado)
curl http://api.monein.com.br/api/health
```

**Próximo passo:** Configurar SSL (HTTPS) →

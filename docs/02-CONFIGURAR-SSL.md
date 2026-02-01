# 🔐 Configurar SSL/HTTPS

## Método 1: Via hPanel (Mais Fácil) ⭐

### Passo 1: Ativar SSL Gratuito

1. **Acesse o hPanel**
   - https://hpanel.hostinger.com/

2. **Vá para SSL**
   - Menu: **Websites**
   - Selecione: **monein.com.br**
   - Clique em: **SSL**

3. **Instalar Let's Encrypt**
   - Encontre: **api.monein.com.br**
   - Clique em: **Install SSL**
   - Selecione: **Free Let's Encrypt SSL**
   - Confirme

4. **Aguardar Instalação**
   - Leva de 5 a 15 minutos
   - Você receberá um email quando estiver pronto

### Passo 2: Forçar HTTPS

No hPanel:
- Ative a opção: **Force HTTPS**
- Isso redireciona automaticamente HTTP → HTTPS

## Método 2: Via SSH (Avançado)

Se preferir configurar manualmente:

### Instalar Certbot

```bash
ssh -p 65002 u991291448@77.37.127.18

# Verificar se certbot está instalado
which certbot

# Se não estiver, não é possível instalar sem sudo
# Use o método via hPanel
```

## Método 3: Nginx com SSL (Se tiver acesso)

Se tiver acesso ao Nginx, crie a configuração:

```bash
ssh -p 65002 u991291448@77.37.127.18

# Verificar se nginx está disponível
which nginx
```

Se disponível, crie o arquivo de configuração:

```nginx
# /etc/nginx/sites-available/api.monein.com.br
# (requer sudo - pode não ter acesso)

server {
    listen 80;
    server_name api.monein.com.br;
    
    # Redirecionar para HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.monein.com.br;

    # Certificados SSL (gerados pelo certbot)
    ssl_certificate /etc/letsencrypt/live/api.monein.com.br/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.monein.com.br/privkey.pem;
    
    # Configurações SSL recomendadas
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # Headers de segurança
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Tamanho máximo do corpo da requisição
    client_max_body_size 25m;
    
    # Proxy para Node.js
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

## 🔍 Verificar SSL

### Via Navegador

Acesse: `https://api.monein.com.br`

Deve mostrar:
- ✅ Cadeado verde
- ✅ Certificado válido
- ✅ Let's Encrypt como emissor

### Via Linha de Comando

```bash
# Testar SSL
curl -I https://api.monein.com.br

# Verificar certificado
openssl s_client -connect api.monein.com.br:443 -servername api.monein.com.br

# Testar endpoint
curl https://api.monein.com.br/api/health
```

### Via Ferramentas Online

1. **SSL Labs**
   - https://www.ssllabs.com/ssltest/
   - Digite: `api.monein.com.br`
   - Deve ter nota A ou A+

2. **Why No Padlock**
   - https://www.whynopadlock.com/
   - Verifica conteúdo misto (HTTP em página HTTPS)

## 📝 Atualizar Configuração da API

Após SSL configurado, atualize o `.env`:

```bash
ssh -p 65002 u991291448@77.37.127.18
cd /home/u991291448/domains/monein.com.br/public_html/api

# Editar .env
nano .env
```

Altere:
```env
PUBLIC_API_BASE=https://api.monein.com.br
CORS_ORIGIN=https://monein.com.br,https://www.monein.com.br
```

Reinicie a API:
```bash
npx pm2 restart monein-api
```

## 🔄 Renovação Automática

O Let's Encrypt via hPanel **renova automaticamente** a cada 90 dias.

Você receberá emails de lembrete antes da expiração.

### Manual (se necessário)

```bash
# Via certbot (se tiver acesso sudo)
sudo certbot renew

# Testar renovação (dry-run)
sudo certbot renew --dry-run
```

## 🐛 Troubleshooting

### Erro: "Certificado não confiável"

**Causa:** SSL ainda não foi instalado ou está propagando

**Solução:**
- Aguarde 15 minutos
- Limpe cache do navegador
- Use modo anônimo

### Erro: "Mixed Content"

**Causa:** Página HTTPS carregando recursos HTTP

**Solução:**
- Todos os URLs devem ser HTTPS
- Verifique: imagens, scripts, APIs externas

### Erro: "ERR_SSL_VERSION_OR_CIPHER_MISMATCH"

**Causa:** Configuração SSL incompatível

**Solução:**
- Use protocolos modernos: TLSv1.2, TLSv1.3
- Atualize configuração do Nginx

## ✅ Checklist Final

- [ ] SSL instalado via hPanel
- [ ] HTTPS forçado (Force HTTPS)
- [ ] Teste: `curl https://api.monein.com.br/api/health`
- [ ] Certificado válido (cadeado verde)
- [ ] `.env` atualizado com URLs HTTPS
- [ ] API reiniciada
- [ ] Nota A no SSL Labs

**Próximo passo:** Configurar Webhooks →

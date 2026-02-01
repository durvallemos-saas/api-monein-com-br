# 🎯 Passos Práticos - Configurar api.monein.com.br

## ✅ O Que Já Está Pronto
- ✅ API rodando em `localhost:3000` no servidor
- ✅ Código em `/home/u991291448/domains/monein.com.br/public_html/api/api`
- ✅ SSL instalado para `api.monein.com.br`

## 📋 Falta Apenas 1 Coisa: Criar o Subdomínio

### Passo 1: Adicionar Subdomínio no hPanel

1. **Acesse**: https://hpanel.hostinger.com/
2. **Vá em**: Websites → monein.com.br
3. **Procure por**: "Subdomains" ou "Subdomínios" (geralmente no menu lateral)
4. **Clique em**: "Create Subdomain" ou "Criar Subdomínio"
5. **Configure**:
   ```
   Subdomínio: api
   Domínio principal: monein.com.br
   Document Root: /public_html/api-public
   ```
6. **Salvar**

### Passo 2: Criar .htaccess (Execute no SSH)

Depois que o subdomínio estiver criado, execute:

```bash
ssh -p 65002 u991291448@77.37.127.18

# Ir para a pasta do subdomínio (criada automaticamente)
cd /home/u991291448/domains/api.monein.com.br/public_html

# Criar .htaccess
cat > .htaccess << 'EOF'
RewriteEngine On

# Forçar HTTPS
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Proxy para Node.js
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ http://127.0.0.1:3000/$1 [P,L]

ProxyRequests Off
ProxyPreserveHost On
ProxyPass / http://127.0.0.1:3000/
ProxyPassReverse / http://127.0.0.1:3000/
EOF

# Ver se criou
cat .htaccess
```

### Passo 3: Testar

Aguarde 1-2 minutos e teste:

```bash
curl https://api.monein.com.br/api/health
```

## ⚠️ Se der Erro 500

Significa que `mod_proxy` não está habilitado. Nesse caso:

### Solução A: Versão Simples do .htaccess

```bash
ssh -p 65002 u991291448@77.37.127.18
cd /home/u991291448/domains/api.monein.com.br/public_html

cat > .htaccess << 'EOF'
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ http://127.0.0.1:3000/$1 [P,L]
EOF
```

### Solução B: Contatar Suporte Hostinger

Envie este ticket:

---

**Assunto**: Habilitar mod_proxy para api.monein.com.br

**Mensagem**:

Olá,

Preciso habilitar o módulo `mod_proxy` do Apache para o subdomínio **api.monein.com.br**.

Tenho uma aplicação Node.js rodando em `localhost:3000` e preciso que as requisições para `https://api.monein.com.br` sejam redirecionadas para ela.

**Configuração necessária**:
- Subdomínio: `api.monein.com.br`
- Proxy para: `http://127.0.0.1:3000`
- Manter SSL ativo

Podem habilitar o mod_proxy ou configurar o proxy reverso para mim?

Obrigado!

---

## 🚀 Alternativa Mais Simples: Vercel

Se quiser evitar toda essa complexidade:

```bash
# 1. Instalar Vercel CLI
npm i -g vercel

# 2. Login
vercel login

# 3. Deploy
cd /workspaces/api-monein-com-br/api
vercel

# 4. Adicionar domínio customizado
vercel domains add api.monein.com.br

# 5. Configurar DNS
# Vercel vai te dar os registros DNS para adicionar no painel da Hostinger
```

**Vantagens do Vercel**:
- ✅ Gratuito
- ✅ Deploy em 2 minutos
- ✅ HTTPS automático
- ✅ Sem configuração de servidor
- ✅ Auto-scaling
- ✅ Logs e monitoring inclusos

## 📊 Resumo: Qual Escolher?

| Opção | Tempo | Dificuldade | Custo |
|-------|-------|-------------|-------|
| **Adicionar subdomínio + .htaccess** | 5 min | Fácil | Grátis |
| **Suporte Hostinger** | 1-24h | Muito Fácil | Grátis |
| **Vercel** | 2 min | Muito Fácil | Grátis |
| **VPS** | 30 min | Média | €3.99/mês |

**Recomendação**: 
1. Tente criar subdomínio + .htaccess (5 minutos)
2. Se não funcionar, use **Vercel** (mais profissional e confiável)

Quer que eu te ajude com qual opção? 🚀

# Deploy HTTPS Direto na Hostinger

## 🎯 Configuração para Hostinger Compartilhada

A Hostinger já gerencia os certificados SSL automaticamente. Este guia mostra como configurar HTTPS direto no Node.js na Hostinger.

## ✅ Pré-requisitos

- Certificado SSL já instalado no painel da Hostinger (✓ Você já tem!)
- Acesso SSH habilitado
- Node.js instalado
- PM2 instalado

## 🚀 Passo a Passo

### 1. Conectar via SSH

```bash
ssh -p 65002 u991291448@77.37.127.18
```

### 2. Navegar para o diretório da API

```bash
cd /home/u991291448/domains/monein.com.br/public_html/api
```

### 3. Encontrar os Certificados SSL

Execute o script para localizar os certificados da Hostinger:

```bash
chmod +x deploy/find-ssl-certs.sh
./deploy/find-ssl-certs.sh
```

Possíveis localizações:
- `/home/u991291448/.ssl/api.monein.com.br/`
- `/home/u991291448/ssl/api.monein.com.br/`
- `/home/u991291448/domains/api.monein.com.br/ssl/`

### 4. Configurar SSL

Execute o script de configuração que vai:
- Encontrar os certificados automaticamente
- Configurar o arquivo `.env`
- Dar permissões ao Node.js

```bash
chmod +x deploy/setup-hostinger-ssl.sh
./deploy/setup-hostinger-ssl.sh
```

### 5. Deploy da Aplicação

```bash
chmod +x deploy/deploy-https-direct.sh
./deploy/deploy-https-direct.sh
```

## 🔧 Configuração Manual (se necessário)

Se os scripts não encontrarem os certificados automaticamente:

### 1. Localizar Certificados Manualmente

```bash
# Procurar arquivos de certificado
find /home/u991291448 -name "*.pem" -o -name "*.crt" -o -name "*.key" 2>/dev/null | grep -i monein
```

### 2. Editar o .env

```bash
cd /home/u991291448/domains/monein.com.br/public_html/api
nano .env
```

Adicionar/atualizar:

```bash
# SSL Configuration
SSL_ENABLED=true
SSL_KEY_PATH=/caminho/correto/para/privkey.pem
SSL_CERT_PATH=/caminho/correto/para/fullchain.pem

# Ports
PORT=443
HTTP_PORT=80

# API Base
PUBLIC_API_BASE=https://api.monein.com.br
```

### 3. Dar Permissão ao Node.js

```bash
# Verificar caminho do Node.js
which node

# Dar permissão (precisa ser root ou sudo)
sudo setcap 'cap_net_bind_service=+ep' $(which node)

# Verificar se funcionou
getcap $(which node)
# Deve retornar: cap_net_bind_service+ep
```

### 4. Build e Deploy

```bash
# Instalar dependências
npm install

# Build
npm run build

# Reiniciar com PM2
pm2 reload ecosystem.config.js --update-env
```

## 📋 Verificação

### 1. Status da Aplicação

```bash
pm2 status monein-api
pm2 logs monein-api --lines 50
```

### 2. Verificar Portas

```bash
# Ver se Node.js está ouvindo nas portas
netstat -tulpn | grep node
# ou
ss -tulpn | grep node
```

Deve mostrar:
- Porta 443 (HTTPS)
- Porta 80 (HTTP redirecionamento)

### 3. Testar API

```bash
# Testar HTTP (deve redirecionar para HTTPS)
curl -I http://api.monein.com.br

# Testar HTTPS
curl https://api.monein.com.br

# Testar health endpoint
curl https://api.monein.com.br/api/health
```

## ⚠️ Limitações da Hostinger Compartilhada

### Possíveis Problemas

1. **Sem acesso root/sudo**: Não consegue dar permissão ao Node.js para portas 80/443
2. **Firewall gerenciado**: Hostinger pode bloquear portas
3. **Proxy reverso automático**: Hostinger pode ter seu próprio proxy

### Soluções Alternativas

#### Opção 1: Usar Portas Altas (3000, 3001)

Se não conseguir usar portas 80/443:

```bash
# .env
SSL_ENABLED=false
PORT=3000
PUBLIC_API_BASE=https://api.monein.com.br
```

E configurar redirecionamento no painel da Hostinger (se disponível).

#### Opção 2: Usar o Proxy da Hostinger

Configurar no painel da Hostinger:
- Domínio: api.monein.com.br
- Tipo: Node.js Application
- Porta da aplicação: 3000
- SSL: Ativado

#### Opção 3: Usar .htaccess (Apache)

Se a Hostinger usar Apache:

```bash
cd /home/u991291448/domains/api.monein.com.br/public_html
nano .htaccess
```

Adicionar:

```apache
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Proxy para Node.js
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ http://localhost:3000/$1 [P,L]
```

## 🔍 Troubleshooting

### Erro: "Permission denied" na porta 443

**Causa**: Node.js sem permissão para portas < 1024

**Solução 1** (preferencial):
```bash
sudo setcap 'cap_net_bind_service=+ep' $(which node)
```

**Solução 2** (se não tiver sudo):
Use porta alta (3000) e configure proxy no painel da Hostinger

### Erro: "Address already in use"

**Causa**: Outra aplicação usando a porta

**Verificar**:
```bash
lsof -i :443
lsof -i :80
```

**Solução**:
```bash
pm2 stop all
pm2 start ecosystem.config.js
```

### Erro: "Certificate not found"

**Causa**: Caminho do certificado incorreto

**Solução**:
Execute `./deploy/find-ssl-certs.sh` para encontrar o caminho correto

### Aplicação não inicia

**Verificar logs**:
```bash
pm2 logs monein-api --err
cat logs/pm2-error.log
```

**Reiniciar**:
```bash
pm2 delete monein-api
pm2 start ecosystem.config.js
```

## 📚 Scripts Disponíveis

```bash
# Encontrar certificados SSL
./deploy/find-ssl-certs.sh

# Configurar SSL automaticamente
./deploy/setup-hostinger-ssl.sh

# Deploy completo
./deploy/deploy-https-direct.sh
```

## 🆘 Suporte

Se encontrar problemas:

1. Verifique os logs: `pm2 logs monein-api`
2. Execute o script de busca: `./deploy/find-ssl-certs.sh`
3. Contate o suporte da Hostinger sobre permissões SSH/Node.js

## 📞 Contato Hostinger

- Painel: https://hpanel.hostinger.com
- Suporte: Via chat no painel
- Documentação: https://support.hostinger.com

---

**Nota**: A Hostinger compartilhada pode ter limitações. Para melhor performance e controle total, considere usar VPS da Hostinger ou outro provedor.

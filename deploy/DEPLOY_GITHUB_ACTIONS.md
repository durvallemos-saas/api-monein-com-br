# 🚀 Deploy Automático com GitHub Actions

Este guia explica como configurar o deploy automático da API MONEIN usando GitHub Actions.

## 📋 Pré-requisitos

- Repositório no GitHub
- Acesso SSH ao servidor (já fornecido)
- Node.js 18+ instalado no servidor
- PM2 instalado no servidor (será instalado automaticamente se não existir)

## 🔐 Configurar Secrets no GitHub

### Passo 1: Acessar configurações do repositório

1. Vá para o repositório no GitHub: `https://github.com/durvallemos-saas/api-monein-com-br`
2. Clique em **Settings** (Configurações)
3. No menu lateral, clique em **Secrets and variables** > **Actions**
4. Clique em **New repository secret**

### Passo 2: Adicionar os seguintes secrets

Adicione cada secret individualmente:

#### Credenciais SSH
```
Nome: SSH_HOST
Valor: 77.37.127.18
```

```
Nome: SSH_PORT
Valor: 65002
```

```
Nome: SSH_USERNAME
Valor: u991291448
```

```
Nome: SSH_PASSWORD
Valor: AAnmlg2060##
```

#### Credenciais Supabase
```
Nome: SUPABASE_URL
Valor: https://gsmswwlabefrvouarwkk.supabase.co
```

```
Nome: SUPABASE_SERVICE_ROLE_KEY
Valor: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzbXN3d2xhYmVmcnZvdWFyd2trIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTgxMDQ5NiwiZXhwIjoyMDg1Mzg2NDk2fQ.cGZpJf95zIV2YNuCH53ZiTOGKfiVS3kXSS3yAl59ut4
```

```
Nome: SUPABASE_ANON_KEY
Valor: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzbXN3d2xhYmVmcnZvdWFyd2trIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4MTA0OTYsImV4cCI6MjA4NTM4NjQ5Nn0.VVP3w8x5J6Y0MnR9m9vGO-sR2HN5JCNgXPQBZ6LxZkI
```

#### Credenciais OpenAI
```
Nome: OPENAI_API_KEY
Valor: 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
```

```
Nome: OPENAI_WEBHOOK_SECRET
Valor: whsec_gBPzO2K6/X8CKpRbAkrb3pKd4TOR+Fy646/i2jEiko0=
```

## ✅ Verificar Configuração

Após adicionar todos os secrets, você deve ter **9 secrets** configurados:

- ✅ SSH_HOST
- ✅ SSH_PORT
- ✅ SSH_USERNAME
- ✅ SSH_PASSWORD
- ✅ SUPABASE_URL
- ✅ SUPABASE_SERVICE_ROLE_KEY
- ✅ SUPABASE_ANON_KEY
- ✅ OPENAI_API_KEY
- ✅ OPENAI_WEBHOOK_SECRET

## 🚀 Como Fazer Deploy

### Deploy Automático (recomendado)

O deploy acontece automaticamente quando você faz push para a branch `main`:

```bash
git add .
git commit -m "Deploy to production"
git push origin main
```

### Deploy Manual

Você também pode disparar o deploy manualmente:

1. Vá para o repositório no GitHub
2. Clique em **Actions**
3. Clique no workflow **Deploy to Production**
4. Clique em **Run workflow**
5. Selecione a branch `main`
6. Clique em **Run workflow**

## 📊 Monitorar Deploy

### Via GitHub Actions

1. Vá para **Actions** no repositório
2. Clique no workflow em execução
3. Acompanhe os logs de cada etapa

### Via SSH no Servidor

```bash
# Conectar via SSH
ssh -p 65002 u991291448@77.37.127.18

# Ver status do PM2
pm2 status

# Ver logs em tempo real
pm2 logs monein-api

# Ver logs recentes
pm2 logs monein-api --lines 100
```

## 🔧 Estrutura de Pastas no Servidor

```
/home/u991291448/
├── domains/
│   └── monein.com.br/
│       ├── public_html/     # Frontend (se houver)
│       └── api/             # Backend (nossa API)
│           ├── dist/        # Código compilado
│           ├── node_modules/
│           ├── package.json
│           ├── package-lock.json
│           └── .env
└── logs/
    └── monein-api.log       # Logs da aplicação
```

## 🐛 Troubleshooting

### Deploy falhou na etapa de SSH

**Problema**: Não consegue conectar ao servidor

**Solução**:
- Verifique se os secrets SSH estão corretos
- Teste a conexão SSH manualmente: `ssh -p 65002 u991291448@77.37.127.18`

### Deploy bem-sucedido mas API não responde

**Problema**: Deploy completo mas API retorna erro 502/503

**Solução**:
```bash
# Conectar ao servidor
ssh -p 65002 u991291448@77.37.127.18

# Verificar logs
pm2 logs monein-api --lines 50

# Reiniciar aplicação
pm2 restart monein-api

# Verificar se está rodando
pm2 status
```

### Erro "pm2 command not found"

**Problema**: PM2 não está instalado

**Solução**:
```bash
# No servidor
npm install -g pm2
```

### Aplicação não inicia no boot do servidor

**Problema**: Após reiniciar o servidor, a aplicação não inicia

**Solução**:
```bash
# No servidor
pm2 startup
pm2 save
```

## 🔒 Configurar Nginx (Proxy Reverso)

Para expor a API no domínio `api.monein.com.br`:

1. Crie o arquivo de configuração do Nginx:
```bash
sudo nano /etc/nginx/sites-available/api.monein.com.br
```

2. Adicione a configuração:
```nginx
server {
    server_name api.monein.com.br;
    listen 80;

    client_max_body_size 25m;

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
    }
}
```

3. Habilite o site:
```bash
sudo ln -s /etc/nginx/sites-available/api.monein.com.br /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

4. Configure SSL com Certbot:
```bash
sudo certbot --nginx -d api.monein.com.br
```

## 🎉 Pronto!

Agora você tem deploy automático configurado. Toda vez que fizer push para `main`, a aplicação será automaticamente:

1. ✅ Compilada
2. ✅ Enviada para o servidor
3. ✅ Instaladas as dependências
4. ✅ Reiniciada com PM2

## 📞 Suporte

Se encontrar problemas:

1. Verifique os logs no GitHub Actions
2. Conecte via SSH e verifique os logs do PM2
3. Verifique se todos os secrets estão configurados corretamente

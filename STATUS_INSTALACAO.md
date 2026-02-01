# ✅ API INSTALADA COM SUCESSO!

## 🎉 Status Atual

✅ **Código clonado** do GitHub  
✅ **Dependências instaladas**  
✅ **TypeScript compilado**  
✅ **.env configurado**  
✅ **API rodando** na porta 3000 (internamente)  

**Problema**: Porta 3000 está **bloqueada** pelo firewall da Hostinger

## 🔧 Configurar Proxy no Painel Hostinger

### Passo 1: Acessar Painel
1. Acesse: https://hpanel.hostinger.com/
2. Vá em **"Websites"** → **"monein.com.br"**

### Passo 2: Configurar Aplicação Node.js
1. No menu lateral, procure por **"Aplicações"** ou **"Node.js"** ou **"Proxy"**
2. Clique em **"Adicionar Aplicação Node.js"** ou **"Configurar Proxy"**

### Passo 3: Configurações
```
Domínio: api.monein.com.br
Tipo: Node.js Application / Reverse Proxy
Porta da Aplicação: 3000
Caminho: /home/u991291448/domains/monein.com.br/public_html/api/api
Comando de Início: node dist/server.js
Versão do Node: 20.x
```

### Passo 4: SSL
- ✅ Ativar SSL (Let's Encrypt) - Já está instalado!
- ✅ Forçar HTTPS

### Passo 5: Salvar e Testar

Após salvar, teste:
```bash
curl https://api.monein.com.br/api/health
```

## 📋 Alternativa: Usar .htaccess (se não tiver opção Node.js)

Se não encontrar opção para Node.js no painel, configure via `.htaccess`:

```bash
# Conectar via SSH
ssh -p 65002 u991291448@77.37.127.18

# Criar .htaccess
cd /home/u991291448/domains/api.monein.com.br/public_html
nano .htaccess
```

Cole este conteúdo:
```apache
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ http://localhost:3000/$1 [P,L]

ProxyPass / http://localhost:3000/
ProxyPassReverse / http://localhost:3000/
```

## 🔄 Reiniciar Aplicação

Se precisar reiniciar a aplicação:

```bash
ssh -p 65002 u991291448@77.37.127.18

# Encontrar e matar processo
ps aux | grep "node dist/server.js"
kill <PID>

# Iniciar novamente
export PATH=$PATH:/opt/alt/alt-nodejs20/root/usr/bin
cd /home/u991291448/domains/monein.com.br/public_html/api/api
nohup node dist/server.js > logs/app.log 2>&1 &

# Verificar
curl http://localhost:3000/api/health
```

## 📊 Verificar Status

```bash
# Ver se está rodando
ps aux | grep node

# Ver logs
tail -f /home/u991291448/domains/monein.com.br/public_html/api/api/logs/app.log

# Testar localmente no servidor
curl http://localhost:3000/api/health
```

## 🆘 Se Nada Funcionar

Contate o suporte da Hostinger e peça ajuda para:
- **"Configurar proxy reverso para api.monein.com.br apontando para localhost:3000"**
- **"Liberar porta 3000 no firewall"** (menos provável)
- **"Configurar aplicação Node.js no domínio api.monein.com.br"**

## 📞 Contato Suporte Hostinger
- Chat: https://hpanel.hostinger.com/
- Mencione: "Preciso configurar proxy reverso para minha aplicação Node.js"

---

**A API está funcionando internamente! Só precisa configurar o proxy no painel. 🚀**

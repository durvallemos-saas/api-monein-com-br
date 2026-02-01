# 🔗 Configurar Webhooks

## 1. Webhook OpenAI

### Passo 1: Acessar Dashboard OpenAI

1. **Login**: https://platform.openai.com/
2. **Vá para**: Settings → Webhooks
3. **Ou direto**: https://platform.openai.com/settings/organization/webhooks

### Passo 2: Criar Webhook

1. **Clique em**: "Add webhook endpoint"

2. **Preencha**:
   ```
   URL: https://api.monein.com.br/api/webhooks/openai
   Description: MONEIN Production Webhook
   ```

3. **Selecione os eventos**:
   - ✅ `assistant.run.completed`
   - ✅ `assistant.run.failed`
   - ✅ `assistant.run.cancelled`
   - ✅ `thread.message.completed`
   - ✅ `thread.run.step.completed`
   
   Ou selecione: **"Send me everything"**

4. **Copie o Webhook Secret**:
   - Formato: `whsec_...`
   - **IMPORTANTE**: Guarde este secret!

### Passo 3: Atualizar Secret no Servidor

```bash
ssh -p 65002 u991291448@77.37.127.18
cd /home/u991291448/domains/monein.com.br/public_html/api

# Editar .env
nano .env

# Atualizar (se necessário):
OPENAI_WEBHOOK_SECRET=whsec_SEU_NOVO_SECRET_AQUI

# Salvar: Ctrl+O, Enter, Ctrl+X

# Reiniciar API
npx pm2 restart monein-api
```

### Passo 4: Testar Webhook

No dashboard da OpenAI:
1. Clique em: **"Send test event"**
2. Selecione um evento de teste
3. Clique em: **"Send test"**

Verifique os logs:
```bash
ssh -p 65002 u991291448@77.37.127.18
npx pm2 logs monein-api --lines 50
```

Deve aparecer algo como:
```
[INFO] Webhook OpenAI recebido
[INFO] Evento: assistant.run.completed
```

## 2. Webhook WhatsApp

### Passo 1: Acessar Meta for Developers

1. **Login**: https://developers.facebook.com/
2. **Vá para**: Seus Apps
3. **Selecione ou crie**: App do WhatsApp Business

### Passo 2: Configurar WhatsApp Business API

1. **Menu lateral**: WhatsApp → Configuration

2. **Webhook Configuration**:
   ```
   Callback URL: https://api.monein.com.br/api/webhooks/whatsapp
   Verify Token: MEU_TOKEN_SECRETO_AQUI
   ```
   
   **Importante**: O Verify Token pode ser qualquer string secreta que você escolher.
   Exemplo: `monein_whatsapp_2026_secure_token`

3. **Clique em**: "Verify and Save"

### Passo 3: Atualizar Token no Servidor

```bash
ssh -p 65002 u991291448@77.37.127.18
cd /home/u991291448/domains/monein.com.br/public_html/api

# Editar .env
nano .env

# Adicionar/atualizar:
WHATSAPP_VERIFY_TOKEN=monein_whatsapp_2026_secure_token
WHATSAPP_ACCESS_TOKEN=SEU_TOKEN_DE_ACESSO
WHATSAPP_PHONE_NUMBER_ID=SEU_PHONE_NUMBER_ID
WHATSAPP_BUSINESS_ACCOUNT_ID=SEU_BUSINESS_ACCOUNT_ID

# Salvar e reiniciar
npx pm2 restart monein-api
```

### Passo 4: Subscrever nos Eventos

No Meta for Developers:
1. **Webhook Fields**: Marque:
   - ✅ `messages`
   - ✅ `message_status`
   - ✅ `messaging_optins`
   - ✅ `messaging_referrals`

2. **Clique em**: "Subscribe"

### Passo 5: Obter Tokens

**Phone Number ID**:
- WhatsApp → API Setup
- Copie o "Phone number ID"

**Access Token**:
- WhatsApp → API Setup
- Clique em "Generate access token"
- Copie o token (começa com `EAA...`)

**Business Account ID**:
- Settings → Basic
- Copie o "App ID" ou "WhatsApp Business Account ID"

### Passo 6: Testar Webhook

Envie uma mensagem de teste para seu número do WhatsApp Business.

Verifique os logs:
```bash
npx pm2 logs monein-api --lines 50
```

Deve aparecer:
```
[INFO] Webhook WhatsApp recebido
[INFO] Mensagem de: +5511999999999
```

## 3. Salvar Credenciais no Banco

Alternativamente, salve as credenciais no Supabase:

### Via Supabase Dashboard

1. **Acesse**: https://supabase.com/dashboard
2. **Projeto**: gsmswwlabefrvouarwkk
3. **Table Editor** → `monein_gestor_integracoes`

### Inserir OpenAI

```sql
INSERT INTO monein_gestor_integracoes (
  integracao,
  ativa,
  api_key,
  webhook_secret
) VALUES (
  'openai',
  true,
  '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',
  'whsec_gBPzO2K6/X8CKpRbAkrb3pKd4TOR+Fy646/i2jEiko0='
);
```

### Inserir WhatsApp

```sql
INSERT INTO monein_gestor_integracoes (
  integracao,
  ativa,
  phone_number_id,
  business_account_id,
  access_token,
  verify_token
) VALUES (
  'whatsapp',
  true,
  'SEU_PHONE_NUMBER_ID',
  'SEU_BUSINESS_ACCOUNT_ID',
  'SEU_ACCESS_TOKEN',
  'monein_whatsapp_2026_secure_token'
);
```

## 🔍 Testar Endpoints

### Teste Manual - OpenAI

```bash
# Simular webhook da OpenAI
curl -X POST https://api.monein.com.br/api/webhooks/openai \
  -H "Content-Type: application/json" \
  -H "x-openai-signature: test" \
  -d '{
    "type": "assistant.run.completed",
    "data": {
      "id": "run_test",
      "status": "completed"
    }
  }'
```

### Teste Manual - WhatsApp

```bash
# Verificação (GET)
curl "https://api.monein.com.br/api/webhooks/whatsapp?hub.mode=subscribe&hub.verify_token=monein_whatsapp_2026_secure_token&hub.challenge=CHALLENGE_TEST"

# Deve retornar: CHALLENGE_TEST

# Webhook (POST)
curl -X POST https://api.monein.com.br/api/webhooks/whatsapp \
  -H "Content-Type: application/json" \
  -d '{
    "entry": [{
      "changes": [{
        "value": {
          "messages": [{
            "from": "5511999999999",
            "text": {
              "body": "Teste"
            }
          }]
        }
      }]
    }]
  }'
```

## 📊 Monitorar Webhooks

### Ver Logs em Tempo Real

```bash
ssh -p 65002 u991291448@77.37.127.18
npx pm2 logs monein-api
```

### Ver Últimos Eventos

```bash
npx pm2 logs monein-api --lines 100 | grep -i webhook
```

### Verificar Status no Banco

```sql
-- No Supabase SQL Editor
SELECT * FROM openai_webhooks 
ORDER BY created_at DESC 
LIMIT 10;

SELECT * FROM whatsapp_messages 
ORDER BY created_at DESC 
LIMIT 10;
```

## 🐛 Troubleshooting

### OpenAI: "Webhook signature verification failed"

**Causa**: Secret incorreto ou expirado

**Solução**:
1. Copie o secret novamente do dashboard
2. Atualize no `.env`
3. Reinicie: `npx pm2 restart monein-api`

### WhatsApp: "Verification failed"

**Causa**: Verify token não confere

**Solução**:
1. Verifique o token no `.env`
2. Use o mesmo token no Meta for Developers
3. Reinicie a API

### Webhook não está sendo chamado

**Causa**: URL incorreta ou API offline

**Solução**:
```bash
# Verificar se API está rodando
curl https://api.monein.com.br/api/health

# Ver logs
ssh -p 65002 u991291448@77.37.127.18
npx pm2 logs monein-api

# Verificar status
npx pm2 status
```

## ✅ Checklist Final

### OpenAI
- [ ] Webhook criado no dashboard
- [ ] URL configurada: `https://api.monein.com.br/api/webhooks/openai`
- [ ] Secret atualizado no `.env`
- [ ] Teste enviado e logs verificados
- [ ] Eventos salvos no banco

### WhatsApp
- [ ] Webhook configurado no Meta for Developers
- [ ] URL: `https://api.monein.com.br/api/webhooks/whatsapp`
- [ ] Verify token configurado
- [ ] Access token obtido
- [ ] Phone Number ID configurado
- [ ] Teste enviado (mensagem real)
- [ ] Mensagens salvas no banco

## 🎉 Pronto!

Agora sua API está:
- ✅ Publicada em `https://api.monein.com.br`
- ✅ Com SSL/HTTPS configurado
- ✅ Recebendo webhooks da OpenAI
- ✅ Recebendo webhooks do WhatsApp
- ✅ Salvando eventos no Supabase

**Endpoints ativos:**
- `GET  /api/health` - Health check
- `POST /api/webhooks/openai` - OpenAI webhooks
- `GET  /api/webhooks/whatsapp` - Verificação WhatsApp
- `POST /api/webhooks/whatsapp` - Mensagens WhatsApp

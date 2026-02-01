# Migrations SQL para MONEIN

Este diretório contém todas as migrations necessárias para configurar o banco de dados do sistema MONEIN.

## Como aplicar as migrations

### Opção 1: Via Supabase Dashboard
1. Acesse o Supabase Dashboard
2. Vá em SQL Editor
3. Cole o conteúdo de cada migration na ordem
4. Execute cada migration

### Opção 2: Via psql
```bash
# Defina a connection string do seu banco
export DATABASE_URL="postgresql://user:pass@host:5432/dbname"

# Execute as migrations em ordem
psql $DATABASE_URL < 016_openai_webhooks_async_tasks.sql
psql $DATABASE_URL < 017_create_monein_gestor_planos.sql
psql $DATABASE_URL < 018_create_monein_gestor_info_base.sql
psql $DATABASE_URL < 019_create_whatsapp_messages.sql
```

### Opção 3: Via Supabase CLI
```bash
# Certifique-se de estar linkado ao projeto correto
supabase link --project-ref seu-project-ref

# Execute as migrations
supabase db push
```

## Ordem das migrations

1. **016_openai_webhooks_async_tasks.sql** - Tabelas para webhooks OpenAI e tarefas assíncronas
2. **017_create_monein_gestor_planos.sql** - Tabela de planos do sistema
3. **018_create_monein_gestor_info_base.sql** - Informações base e assets
4. **019_create_whatsapp_messages.sql** - Tabelas para mensagens WhatsApp

## Observações

- As migrations usam `IF NOT EXISTS` para evitar erros em caso de re-execução
- Ajuste as permissões (RLS) conforme necessário para seu caso de uso
- Lembre-se de configurar os assets (favicon, logos, backgrounds) após aplicar as migrations
- As URLs de exemplo nas migrations devem ser substituídas pelas URLs reais do seu bucket

## Bucket de Assets

Após aplicar as migrations, não esqueça de:

1. Criar o bucket `site-assets` no Supabase Storage
2. Torná-lo público
3. Fazer upload dos assets:
   - favicon.ico
   - logo-light.png (logo para fundo branco)
   - logo-dark.png (logo para fundo escuro)
   - background-login.jpg (background da tela de login)
4. Atualizar as URLs na tabela `monein_gestor_info_base`

```sql
UPDATE monein_gestor_info_base
SET 
  favicon = 'https://xxxxx.supabase.co/storage/v1/object/public/site-assets/favicon.ico',
  foto_logo_principal_fundo_branco = 'https://xxxxx.supabase.co/storage/v1/object/public/site-assets/logo-light.png',
  foto_logo_principal_fundo_escuro = 'https://xxxxx.supabase.co/storage/v1/object/public/site-assets/logo-dark.png',
  background_login = 'https://xxxxx.supabase.co/storage/v1/object/public/site-assets/background-login.jpg'
WHERE id = (SELECT id FROM monein_gestor_info_base LIMIT 1);
```

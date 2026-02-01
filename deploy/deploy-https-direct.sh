#!/bin/bash
# ==============================================================================
# Script de Deploy - Node.js HTTPS Direto (SEM NGINX)
# ==============================================================================
# Este script faz deploy da API rodando HTTPS diretamente no Node.js
# 
# Pré-requisitos:
#   1. Certificado SSL instalado em /etc/letsencrypt/
#   2. Node.js instalado
#   3. PM2 instalado globalmente
# 
# Como usar:
#   chmod +x deploy-https-direct.sh
#   ./deploy-https-direct.sh
# ==============================================================================

set -e

echo "🚀 Iniciando deploy da MONEIN API (HTTPS Direto)..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variáveis
REPO_URL="https://github.com/durvallemos-saas/api-monein-com-br.git"
APP_DIR="/home/u991291448/domains/monein.com.br/public_html/api"
BRANCH="main"

# Função para imprimir mensagens
print_message() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

# 1. Verificar se os certificados SSL existem
print_step "Verificando certificados SSL da Hostinger..."

SSL_LOCATIONS=(
    "/home/u991291448/.ssl/api.monein.com.br"
    "/home/u991291448/ssl/api.monein.com.br"
    "/home/u991291448/domains/api.monein.com.br/ssl"
    "/etc/letsencrypt/live/api.monein.com.br"
)

SSL_FOUND=false
for location in "${SSL_LOCATIONS[@]}"; do
    if [ -f "$location/privkey.pem" ] || [ -f "$location/private.key" ]; then
        print_message "Certificados SSL encontrados em: $location"
        SSL_FOUND=true
        break
    fi
done

if [ "$SSL_FOUND" = false ]; then
    print_error "Certificados SSL não encontrados!"
    print_warning "Execute: ./deploy/setup-hostinger-ssl.sh"
    exit 1
fi

# 2. Dar permissão ao Node.js para usar portas 80 e 443
print_step "Configurando permissões para portas privilegiadas..."
NODE_PATH=$(which node)
if sudo setcap 'cap_net_bind_service=+ep' "$NODE_PATH"; then
    print_message "Permissões configuradas para $NODE_PATH"
else
    print_error "Falha ao configurar permissões. Execute: sudo setcap 'cap_net_bind_service=+ep' \$(which node)"
    exit 1
fi

# 3. Navegar para o diretório da aplicação
print_step "Navegando para $APP_DIR..."
cd "$APP_DIR" || exit 1

# 4. Fazer backup do .env
print_step "Fazendo backup do arquivo .env..."
if [ -f ".env" ]; then
    cp .env .env.backup
    print_message "Backup criado: .env.backup"
else
    print_warning "Arquivo .env não encontrado"
fi

# 5. Atualizar código do repositório
print_step "Atualizando código do repositório..."
if [ -d ".git" ]; then
    git fetch origin
    git reset --hard origin/$BRANCH
    print_message "Código atualizado da branch $BRANCH"
else
    print_error "Diretório não é um repositório Git"
    exit 1
fi

# 6. Restaurar .env
if [ -f ".env.backup" ]; then
    cp .env.backup .env
    print_message "Arquivo .env restaurado"
fi

# 7. Instalar dependências
print_step "Instalando dependências..."
npm install --production
print_message "Dependências instaladas"

# 8. Compilar TypeScript
print_step "Compilando TypeScript..."
npm run build
print_message "Build concluído"

# 9. Verificar se PM2 está instalado
if ! command -v pm2 &> /dev/null; then
    print_error "PM2 não está instalado!"
    print_warning "Instale com: npm install -g pm2"
    exit 1
fi

# 10. Parar Nginx se estiver rodando
print_step "Verificando se Nginx está rodando..."
if sudo systemctl is-active --quiet nginx; then
    print_warning "Nginx está rodando. Parando..."
    sudo systemctl stop nginx
    sudo systemctl disable nginx
    print_message "Nginx parado e desabilitado"
else
    print_message "Nginx não está rodando"
fi

# 11. Reiniciar aplicação com PM2
print_step "Reiniciando aplicação..."
if pm2 describe monein-api > /dev/null 2>&1; then
    pm2 reload ecosystem.config.js --update-env
    print_message "Aplicação reiniciada"
else
    pm2 start ecosystem.config.js
    pm2 save
    print_message "Aplicação iniciada"
fi

# 12. Verificar status
print_step "Verificando status da aplicação..."
pm2 status monein-api

# 13. Exibir logs recentes
print_step "Logs recentes:"
pm2 logs monein-api --lines 20 --nostream

echo ""
print_message "Deploy concluído com sucesso! 🎉"
echo ""
echo "📋 Informações importantes:"
echo "   - Servidor HTTPS rodando na porta 443"
echo "   - Redirecionamento HTTP (porta 80) para HTTPS"
echo "   - Nginx NÃO está sendo usado"
echo ""
echo "🔍 Comandos úteis:"
echo "   pm2 status        - Ver status da aplicação"
echo "   pm2 logs          - Ver logs em tempo real"
echo "   pm2 restart all   - Reiniciar aplicação"
echo "   pm2 monit         - Monitor interativo"
echo ""
echo "🌐 Teste a API em: https://api.monein.com.br"
echo ""

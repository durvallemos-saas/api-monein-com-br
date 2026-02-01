#!/bin/bash
# ==============================================================================
# Setup Inicial - Hostinger
# ==============================================================================
# Execute este script no servidor para configurar o projeto pela primeira vez
# ==============================================================================

echo "🚀 Configurando projeto MONEIN API..."

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${YELLOW}ℹ${NC} $1"; }
print_step() { echo -e "${BLUE}▶${NC} $1"; }

# Configurações
REPO_URL="https://github.com/durvallemos-saas/api-monein-com-br.git"
APP_DIR="/home/u991291448/domains/monein.com.br/public_html/api"
BACKUP_DIR="/home/u991291448/backups/api-$(date +%Y%m%d_%H%M%S)"

# 1. Verificar se é necessário fazer backup
if [ -d "$APP_DIR" ] && [ "$(ls -A $APP_DIR)" ]; then
    print_step "Fazendo backup do diretório existente..."
    mkdir -p "$(dirname $BACKUP_DIR)"
    cp -r "$APP_DIR" "$BACKUP_DIR"
    print_success "Backup salvo em: $BACKUP_DIR"
    
    # Salvar .env se existir
    if [ -f "$APP_DIR/.env" ]; then
        cp "$APP_DIR/.env" "$BACKUP_DIR/.env"
        print_success "Arquivo .env salvo no backup"
    fi
fi

# 2. Limpar diretório atual
print_step "Limpando diretório..."
cd /home/u991291448/domains/monein.com.br/public_html
rm -rf api
mkdir -p api
cd api

print_success "Diretório limpo"

# 3. Clonar repositório
print_step "Clonando repositório do GitHub..."
if git clone "$REPO_URL" .; then
    print_success "Repositório clonado"
else
    print_error "Falha ao clonar repositório"
    print_info "Execute manualmente:"
    echo "  cd $APP_DIR"
    echo "  git clone $REPO_URL ."
    exit 1
fi

# 4. Entrar na pasta da API
cd "$APP_DIR/api"

# 5. Restaurar .env se existir no backup
if [ -f "$BACKUP_DIR/.env" ]; then
    print_step "Restaurando arquivo .env..."
    cp "$BACKUP_DIR/.env" .env
    print_success "Arquivo .env restaurado"
else
    print_info "Nenhum .env encontrado no backup"
    print_info "Crie um arquivo .env baseado no .env.example"
fi

# 6. Instalar dependências
print_step "Instalando dependências..."
if npm install; then
    print_success "Dependências instaladas"
else
    print_error "Falha ao instalar dependências"
    exit 1
fi

# 7. Compilar TypeScript
print_step "Compilando TypeScript..."
if npm run build; then
    print_success "Build concluído"
else
    print_error "Falha no build"
    exit 1
fi

# 8. Verificar PM2
print_step "Verificando PM2..."
if ! command -v pm2 &> /dev/null; then
    print_error "PM2 não está instalado!"
    print_info "Instale com: npm install -g pm2"
    exit 1
else
    print_success "PM2 está instalado"
fi

echo ""
print_success "Setup concluído! 🎉"
echo ""
echo "📋 Próximos passos:"
echo ""
echo "1. Configure o arquivo .env:"
echo "   cd $APP_DIR/api"
echo "   nano .env"
echo ""
echo "2. Execute o script de configuração SSL:"
echo "   ./deploy/setup-hostinger-ssl.sh"
echo ""
echo "3. Inicie a aplicação:"
echo "   pm2 start ecosystem.config.js"
echo "   pm2 save"
echo ""
echo "4. Teste a aplicação:"
echo "   ./deploy/test-api.sh"
echo ""

#!/bin/bash
# Deploy script para API MONEIN
# Este script automatiza o processo de deploy do backend

set -e  # Exit on error

echo "==================================="
echo "MONEIN API - Deploy Script"
echo "==================================="

# Variáveis
APP_DIR="/var/www/api-monein"
APP_NAME="monein-api"
BACKUP_DIR="/var/backups/monein-api"

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Funções auxiliares
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. Verificar se PM2 está instalado
if ! command -v pm2 &> /dev/null; then
    log_warn "PM2 não encontrado. Instalando..."
    npm install -g pm2
fi

# 2. Criar diretório se não existir
if [ ! -d "$APP_DIR" ]; then
    log_info "Criando diretório da aplicação..."
    mkdir -p "$APP_DIR"
fi

# 3. Criar backup do código anterior (se existir)
if [ -d "$APP_DIR/api" ]; then
    log_info "Criando backup do código anterior..."
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar -czf "$BACKUP_FILE" -C "$APP_DIR" api
    log_info "Backup criado: $BACKUP_FILE"
fi

# 4. Copiar código novo
log_info "Copiando arquivos da aplicação..."
cp -r ./api "$APP_DIR/"

# 5. Navegar para o diretório
cd "$APP_DIR/api"

# 6. Instalar dependências
log_info "Instalando dependências..."
npm ci --production=false

# 7. Build do TypeScript
log_info "Compilando TypeScript..."
npm run build

# 8. Verificar se arquivo .env existe
if [ ! -f ".env" ]; then
    log_error "Arquivo .env não encontrado!"
    log_warn "Copie o arquivo .env.example e configure as variáveis de ambiente:"
    log_warn "  cp .env.example .env"
    log_warn "  nano .env"
    exit 1
fi

# 9. Parar processo existente (se houver)
if pm2 describe "$APP_NAME" &> /dev/null; then
    log_info "Parando aplicação anterior..."
    pm2 stop "$APP_NAME"
    pm2 delete "$APP_NAME"
fi

# 10. Iniciar aplicação com PM2
log_info "Iniciando aplicação..."
PORT=3000 NODE_ENV=production pm2 start dist/server.js --name "$APP_NAME" \
    --max-memory-restart 500M \
    --time

# 11. Salvar configuração do PM2
pm2 save

# 12. Configurar PM2 para iniciar no boot (se ainda não configurado)
if ! pm2 startup | grep -q "already"; then
    log_info "Configurando PM2 para iniciar no boot..."
    pm2 startup
fi

# 13. Verificar status
log_info "Verificando status da aplicação..."
pm2 status "$APP_NAME"

echo ""
log_info "==================================="
log_info "Deploy concluído com sucesso!"
log_info "==================================="
echo ""
log_info "Comandos úteis:"
echo "  - Ver logs:        pm2 logs $APP_NAME"
echo "  - Ver status:      pm2 status"
echo "  - Reiniciar:       pm2 restart $APP_NAME"
echo "  - Parar:           pm2 stop $APP_NAME"
echo "  - Monitorar:       pm2 monit"
echo ""

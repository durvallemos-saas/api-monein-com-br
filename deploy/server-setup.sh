#!/bin/bash
# ==============================================================================
# Script de Configuração Inicial do Servidor
# ==============================================================================
# Execute este script UMA VEZ no servidor para preparar o ambiente
# 
# Como usar:
#   1. Conecte via SSH: ssh -p 65002 u991291448@77.37.127.18
#   2. Baixe este script: wget https://raw.githubusercontent.com/durvallemos-saas/api-monein-com-br/main/deploy/server-setup.sh
#   3. Dê permissão: chmod +x server-setup.sh
#   4. Execute: ./server-setup.sh
# ==============================================================================

set -e

echo "🚀 Configurando servidor para MONEIN API..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variáveis
APP_DIR="/home/u991291448/domains/monein.com.br/public_html/api"
LOG_DIR="/home/u991291448/logs"
NODE_VERSION="18"

# Função para imprimir mensagens
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

# Verificar se está rodando como usuário correto
if [ "$USER" != "u991291448" ]; then
    print_warning "Execute este script como usuário u991291448"
fi

# 1. Criar diretórios necessários
print_message "Criando estrutura de diretórios..."
mkdir -p "$APP_DIR"
mkdir -p "$LOG_DIR"

# 2. Verificar Node.js
print_message "Verificando instalação do Node.js..."
if ! command -v node &> /dev/null; then
    print_error "Node.js não encontrado. Instalando via NVM..."
    
    # Instalar NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    
    # Carregar NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Instalar Node.js
    nvm install "$NODE_VERSION"
    nvm use "$NODE_VERSION"
    nvm alias default "$NODE_VERSION"
else
    NODE_CURRENT=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    print_message "Node.js já instalado (versão $(node -v))"
    
    if [ "$NODE_CURRENT" -lt "$NODE_VERSION" ]; then
        print_warning "Recomendado atualizar para Node.js $NODE_VERSION ou superior"
    fi
fi

# 3. Instalar PM2
print_message "Verificando PM2..."
if ! command -v pm2 &> /dev/null; then
    print_message "Instalando PM2..."
    npm install -g pm2
else
    print_message "PM2 já instalado (versão $(pm2 -v))"
fi

# 4. Configurar PM2 para iniciar no boot
print_message "Configurando PM2 para iniciar no boot..."
pm2 startup || print_warning "Não foi possível configurar PM2 startup (pode precisar de sudo)"

# 5. Criar arquivo de log inicial
touch "$LOG_DIR/monein-api.log"

# 6. Verificar portas disponíveis
print_message "Verificando porta 3000..."
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    print_warning "Porta 3000 já está em uso"
    print_message "Processos usando a porta 3000:"
    lsof -i :3000
else
    print_message "Porta 3000 disponível ✓"
fi

# 7. Criar script de deploy manual (fallback)
print_message "Criando script de deploy manual..."
cat > "$APP_DIR/../manual-deploy.sh" << 'EOF'
#!/bin/bash
# Script de deploy manual (use apenas se o GitHub Actions falhar)

APP_DIR="/home/u991291448/domains/monein.com.br/api"

cd "$APP_DIR" || exit 1

echo "📦 Instalando dependências..."
npm ci --production

echo "🔄 Reiniciando aplicação..."
pm2 delete monein-api 2>/dev/null || true
pm2 start dist/server.js --name monein-api --log /home/u991291448/logs/monein-api.log
pm2 save

echo "✅ Deploy manual concluído!"
echo "📊 Status:"
pm2 status
EOF

chmod +x "$APP_DIR/../manual-deploy.sh"

# 8. Criar script de verificação de saúde
print_message "Criando script de health check..."
cat > "$APP_DIR/../health-check.sh" << 'EOF'
#!/bin/bash
# Script para verificar saúde da aplicação

echo "🔍 Verificando status da aplicação..."
echo ""

# PM2 Status
echo "📊 Status PM2:"
pm2 status

echo ""
echo "📝 Últimas 20 linhas do log:"
pm2 logs monein-api --lines 20 --nostream

echo ""
echo "🌐 Testando endpoint de saúde:"
curl -s http://localhost:3000/api/health | json_pp || echo "Erro ao acessar API"
EOF

chmod +x "$APP_DIR/../health-check.sh"

# 9. Resumo
echo ""
echo "=========================================="
print_message "✅ Configuração inicial completa!"
echo "=========================================="
echo ""
echo "📁 Estrutura criada:"
echo "   - Aplicação: $APP_DIR"
echo "   - Logs: $LOG_DIR"
echo ""
echo "🔧 Ferramentas instaladas:"
echo "   - Node.js: $(node -v)"
echo "   - npm: $(npm -v)"
echo "   - PM2: $(pm2 -v)"
echo ""
echo "📜 Scripts auxiliares criados:"
echo "   - Deploy manual: $APP_DIR/../manual-deploy.sh"
echo "   - Health check: $APP_DIR/../health-check.sh"
echo ""
echo "🚀 Próximos passos:"
echo "   1. Configure os secrets no GitHub (veja DEPLOY_GITHUB_ACTIONS.md)"
echo "   2. Faça push para main para iniciar o primeiro deploy"
echo "   3. Ou execute o deploy manual após copiar os arquivos"
echo ""
echo "📊 Comandos úteis:"
echo "   - Ver logs: pm2 logs monein-api"
echo "   - Status: pm2 status"
echo "   - Restart: pm2 restart monein-api"
echo "   - Stop: pm2 stop monein-api"
echo "   - Health check: bash $APP_DIR/../health-check.sh"
echo ""

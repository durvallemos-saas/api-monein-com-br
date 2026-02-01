#!/bin/bash
# ==============================================================================
# Setup SSL na Hostinger - HTTPS Direto
# ==============================================================================
# A Hostinger gerencia os certificados SSL automaticamente.
# Este script configura a aplicação para usar HTTPS direto.
# ==============================================================================

set -e

echo "🔐 Configurando SSL na Hostinger..."

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_step() { echo -e "${BLUE}▶${NC} $1"; }

APP_DIR="/home/u991291448/domains/monein.com.br/public_html/api"

# 1. Encontrar certificados SSL
print_step "Procurando certificados SSL da Hostinger..."

SSL_LOCATIONS=(
    "/home/u991291448/.ssl/api.monein.com.br"
    "/home/u991291448/ssl/api.monein.com.br"
    "/home/u991291448/domains/api.monein.com.br/ssl"
)

SSL_KEY=""
SSL_CERT=""

for location in "${SSL_LOCATIONS[@]}"; do
    if [ -f "$location/privkey.pem" ] && [ -f "$location/fullchain.pem" ]; then
        SSL_KEY="$location/privkey.pem"
        SSL_CERT="$location/fullchain.pem"
        print_message "Certificados encontrados em: $location"
        break
    elif [ -f "$location/private.key" ] && [ -f "$location/certificate.crt" ]; then
        SSL_KEY="$location/private.key"
        SSL_CERT="$location/certificate.crt"
        print_message "Certificados encontrados em: $location"
        break
    fi
done

if [ -z "$SSL_KEY" ] || [ -z "$SSL_CERT" ]; then
    print_error "Certificados SSL não encontrados!"
    print_warning "Executando script de busca..."
    ./find-ssl-certs.sh
    echo ""
    print_warning "Configure manualmente os caminhos no .env:"
    echo "   SSL_KEY_PATH=/caminho/para/privkey.pem"
    echo "   SSL_CERT_PATH=/caminho/para/fullchain.pem"
    exit 1
fi

# 2. Verificar permissões do Node.js
print_step "Verificando permissões do Node.js..."

NODE_PATH=$(which node)
CURRENT_CAP=$(getcap "$NODE_PATH" 2>/dev/null || echo "none")

if [[ "$CURRENT_CAP" == *"cap_net_bind_service+ep"* ]]; then
    print_message "Node.js já tem permissão para portas 80/443"
else
    print_warning "Node.js precisa de permissão para portas 80/443"
    echo ""
    echo "Execute como root ou com sudo:"
    echo "   sudo setcap 'cap_net_bind_service=+ep' $NODE_PATH"
    echo ""
    read -p "Deseja executar agora? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        if sudo setcap 'cap_net_bind_service=+ep' "$NODE_PATH"; then
            print_message "Permissões configuradas"
        else
            print_error "Falha ao configurar permissões"
            exit 1
        fi
    else
        print_warning "Configure manualmente depois"
    fi
fi

# 3. Atualizar .env
print_step "Atualizando arquivo .env..."

cd "$APP_DIR"

if [ ! -f ".env" ]; then
    print_warning "Arquivo .env não encontrado. Criando..."
    touch .env
fi

# Backup do .env
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)

# Atualizar ou adicionar configurações SSL
if grep -q "SSL_ENABLED" .env; then
    sed -i "s|^SSL_ENABLED=.*|SSL_ENABLED=true|" .env
else
    echo "SSL_ENABLED=true" >> .env
fi

if grep -q "SSL_KEY_PATH" .env; then
    sed -i "s|^SSL_KEY_PATH=.*|SSL_KEY_PATH=$SSL_KEY|" .env
else
    echo "SSL_KEY_PATH=$SSL_KEY" >> .env
fi

if grep -q "SSL_CERT_PATH" .env; then
    sed -i "s|^SSL_CERT_PATH=.*|SSL_CERT_PATH=$SSL_CERT|" .env
else
    echo "SSL_CERT_PATH=$SSL_CERT" >> .env
fi

if grep -q "^PORT=" .env; then
    sed -i "s|^PORT=.*|PORT=443|" .env
else
    echo "PORT=443" >> .env
fi

if grep -q "^HTTP_PORT=" .env; then
    sed -i "s|^HTTP_PORT=.*|HTTP_PORT=80|" .env
else
    echo "HTTP_PORT=80" >> .env
fi

if grep -q "PUBLIC_API_BASE" .env; then
    sed -i "s|^PUBLIC_API_BASE=.*|PUBLIC_API_BASE=https://api.monein.com.br|" .env
else
    echo "PUBLIC_API_BASE=https://api.monein.com.br" >> .env
fi

print_message "Arquivo .env atualizado"

# 4. Exibir configurações
echo ""
print_step "Configurações SSL:"
echo "   SSL_ENABLED=true"
echo "   SSL_KEY_PATH=$SSL_KEY"
echo "   SSL_CERT_PATH=$SSL_CERT"
echo "   PORT=443"
echo "   HTTP_PORT=80"
echo ""

# 5. Testar se os certificados são válidos
print_step "Testando certificados..."
if openssl x509 -in "$SSL_CERT" -noout -text &>/dev/null; then
    print_message "Certificado SSL válido"
    
    # Exibir informações do certificado
    echo ""
    echo "📋 Informações do certificado:"
    openssl x509 -in "$SSL_CERT" -noout -subject -issuer -dates
    echo ""
else
    print_error "Certificado SSL inválido!"
    exit 1
fi

print_message "Configuração SSL concluída! 🎉"
echo ""
echo "🚀 Próximos passos:"
echo "   1. Build da aplicação: npm run build"
echo "   2. Iniciar/reiniciar com PM2: pm2 reload ecosystem.config.js --update-env"
echo "   3. Verificar logs: pm2 logs monein-api"
echo "   4. Testar: curl https://api.monein.com.br"
echo ""

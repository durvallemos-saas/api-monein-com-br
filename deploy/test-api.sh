#!/bin/bash
# ==============================================================================
# Script de Teste da API - Execute no servidor SSH
# ==============================================================================

echo "🔍 Testando API MONEIN..."
echo ""

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${YELLOW}ℹ${NC} $1"; }

# 1. Verificar se PM2 está rodando
echo "1️⃣ Verificando PM2..."
if pm2 list | grep -q "monein-api"; then
    print_success "Aplicação encontrada no PM2"
    pm2 describe monein-api | grep -E "status|uptime|restarts"
else
    print_error "Aplicação não encontrada no PM2"
    echo "Execute: pm2 start ecosystem.config.js"
fi
echo ""

# 2. Verificar portas em uso
echo "2️⃣ Verificando portas..."
if command -v netstat &> /dev/null; then
    print_info "Portas em uso pelo Node.js:"
    netstat -tulpn 2>/dev/null | grep node || echo "Nenhuma porta Node.js encontrada"
elif command -v ss &> /dev/null; then
    print_info "Portas em uso pelo Node.js:"
    ss -tulpn 2>/dev/null | grep node || echo "Nenhuma porta Node.js encontrada"
else
    print_info "netstat/ss não disponível"
fi
echo ""

# 3. Verificar logs do PM2
echo "3️⃣ Logs recentes do PM2:"
pm2 logs monein-api --lines 20 --nostream 2>/dev/null || echo "Sem logs disponíveis"
echo ""

# 4. Testar localhost
echo "4️⃣ Testando conexão local..."

# Testar porta 3000
if curl -s -m 3 http://localhost:3000 > /dev/null 2>&1; then
    print_success "localhost:3000 está respondendo"
    curl -s http://localhost:3000/api/health | head -5
else
    print_error "localhost:3000 NÃO responde"
fi
echo ""

# Testar porta 443
if curl -k -s -m 3 https://localhost:443 > /dev/null 2>&1; then
    print_success "localhost:443 está respondendo"
else
    print_error "localhost:443 NÃO responde"
fi
echo ""

# Testar porta 80
if curl -s -m 3 http://localhost:80 > /dev/null 2>&1; then
    print_success "localhost:80 está respondendo"
else
    print_error "localhost:80 NÃO responde"
fi
echo ""

# 5. Verificar arquivo .env
echo "5️⃣ Verificando configurações..."
if [ -f ".env" ]; then
    print_success "Arquivo .env existe"
    echo "Configurações:"
    grep -E "^(NODE_ENV|PORT|SSL_ENABLED|PUBLIC_API_BASE)" .env | head -5
else
    print_error "Arquivo .env NÃO existe"
fi
echo ""

# 6. Verificar permissões do Node
echo "6️⃣ Verificando permissões do Node.js..."
NODE_PATH=$(which node)
CAP=$(getcap "$NODE_PATH" 2>/dev/null)
if [ -n "$CAP" ]; then
    print_success "Node.js tem permissões: $CAP"
else
    print_error "Node.js NÃO tem permissões para portas 80/443"
    echo "Execute: sudo setcap 'cap_net_bind_service=+ep' \$(which node)"
fi
echo ""

# 7. Ver erros recentes
echo "7️⃣ Erros recentes:"
pm2 logs monein-api --err --lines 10 --nostream 2>/dev/null || echo "Sem erros recentes"
echo ""

# 8. Resumo
echo "=================================================="
echo "📋 RESUMO"
echo "=================================================="
echo ""
echo "Para corrigir problemas:"
echo "1. Ver logs completos: pm2 logs monein-api"
echo "2. Reiniciar: pm2 restart monein-api"
echo "3. Ver status: pm2 status"
echo "4. Ver processos: pm2 describe monein-api"
echo ""
echo "Se a API não iniciar:"
echo "1. Verificar .env existe e está correto"
echo "2. Recompilar: npm run build"
echo "3. Iniciar: pm2 start ecosystem.config.js"
echo ""

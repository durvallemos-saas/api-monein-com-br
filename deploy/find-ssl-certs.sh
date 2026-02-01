#!/bin/bash
# ==============================================================================
# Script para Encontrar Certificados SSL na Hostinger
# ==============================================================================

echo "🔍 Procurando certificados SSL na Hostinger..."

# Locais comuns na Hostinger
POSSIBLE_PATHS=(
    "/home/u991291448/.ssl"
    "/home/u991291448/ssl"
    "/home/u991291448/domains/monein.com.br/ssl"
    "/home/u991291448/domains/api.monein.com.br/ssl"
    "/usr/local/ssl"
    "/etc/letsencrypt/live/api.monein.com.br"
    "/etc/ssl/certs"
)

echo ""
echo "📁 Verificando locais possíveis:"
for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -d "$path" ]; then
        echo "✓ Encontrado: $path"
        ls -la "$path" 2>/dev/null
        echo ""
    fi
done

echo "🔎 Buscando arquivos .pem e .crt no home:"
find /home/u991291448 -name "*.pem" -o -name "*.crt" -o -name "*.key" 2>/dev/null | grep -i ssl

echo ""
echo "📝 Informações do domínio:"
ls -la /home/u991291448/domains/monein.com.br/ 2>/dev/null

echo ""
echo "🌐 Verificar configurações SSL da Hostinger:"
echo "   - Painel: Segurança > SSL"
echo "   - Certificado: Lifetime SSL (ativo)"
echo "   - Domínio: api.monein.com.br"

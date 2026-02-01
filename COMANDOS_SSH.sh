#!/bin/bash
# ==============================================================================
# COMANDOS PARA EXECUTAR NO SERVIDOR HOSTINGER
# ==============================================================================
# Execute estes comandos linha por linha no SSH da Hostinger
# ==============================================================================

echo "=================================================="
echo "🚀 DEPLOY HTTPS DIRETO - HOSTINGER"
echo "=================================================="
echo ""

# 1. CONECTAR VIA SSH
echo "1️⃣ Conecte via SSH:"
echo "   ssh -p 65002 u991291448@77.37.127.18"
echo ""

# 2. NAVEGAR PARA O DIRETÓRIO
echo "2️⃣ Navegue para o diretório da API:"
echo "   cd /home/u991291448/domains/monein.com.br/public_html/api"
echo ""

# 3. ATUALIZAR CÓDIGO
echo "3️⃣ Atualize o código do GitHub:"
echo "   git fetch origin"
echo "   git reset --hard origin/main"
echo ""

# 4. BACKUP DO .env
echo "4️⃣ Faça backup do .env (se existir):"
echo "   cp .env .env.backup"
echo ""

# 5. ENCONTRAR CERTIFICADOS
echo "5️⃣ Encontre os certificados SSL:"
echo "   chmod +x deploy/find-ssl-certs.sh"
echo "   ./deploy/find-ssl-certs.sh"
echo ""

# 6. CONFIGURAR SSL
echo "6️⃣ Configure o SSL automaticamente:"
echo "   chmod +x deploy/setup-hostinger-ssl.sh"
echo "   ./deploy/setup-hostinger-ssl.sh"
echo ""

# 7. INSTALAR DEPENDÊNCIAS
echo "7️⃣ Instale as dependências:"
echo "   npm install"
echo ""

# 8. BUILD
echo "8️⃣ Compile o TypeScript:"
echo "   npm run build"
echo ""

# 9. DAR PERMISSÃO AO NODE (se necessário)
echo "9️⃣ Dê permissão ao Node.js para usar portas 80/443:"
echo "   sudo setcap 'cap_net_bind_service=+ep' \$(which node)"
echo "   # OU, se não tiver sudo, edite o .env para PORT=3000"
echo ""

# 10. INICIAR/REINICIAR COM PM2
echo "🔟 Inicie/reinicie a aplicação:"
echo "   pm2 reload ecosystem.config.js --update-env"
echo "   # OU, se for a primeira vez:"
echo "   pm2 start ecosystem.config.js"
echo "   pm2 save"
echo ""

# 11. VERIFICAR STATUS
echo "1️⃣1️⃣ Verifique o status:"
echo "   pm2 status"
echo "   pm2 logs monein-api --lines 50"
echo ""

# 12. TESTAR API
echo "1️⃣2️⃣ Teste a API:"
echo "   curl -I http://api.monein.com.br"
echo "   curl https://api.monein.com.br"
echo "   curl https://api.monein.com.br/api/health"
echo ""

echo "=================================================="
echo "✅ DEPLOY CONCLUÍDO!"
echo "=================================================="
echo ""
echo "📋 Comandos Úteis:"
echo "   pm2 status              - Ver status"
echo "   pm2 logs monein-api     - Ver logs em tempo real"
echo "   pm2 restart monein-api  - Reiniciar"
echo "   pm2 stop monein-api     - Parar"
echo ""
echo "🌐 URL da API: https://api.monein.com.br"
echo ""

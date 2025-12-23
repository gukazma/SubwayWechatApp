#!/bin/bash
# Ubuntu 服务器快速配置脚本
# 适用于 Ubuntu 20.04/22.04

set -e

echo "========================================"
echo "   地铁小程序服务器环境配置"
echo "========================================"
echo ""

# 1. 更新系统
echo "[1/9] 更新系统..."
sudo apt-get update -y

# 2. 安装 Node.js 18
echo "[2/9] 安装 Node.js 18..."
if ! command -v node &> /dev/null || [ $(node --version | cut -d'.' -f1 | sed 's/v//') -lt 18 ]; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi
echo "Node.js: $(node --version)"

# 3. 安装 PM2
echo "[3/9] 安装 PM2..."
if ! command -v pm2 &> /dev/null; then
    sudo npm install -g pm2
fi
echo "PM2: v$(pm2 --version)"

# 4. 安装 Git
echo "[4/9] 安装 Git..."
if ! command -v git &> /dev/null; then
    sudo apt-get install -y git
fi
echo "Git: $(git --version)"

# 5. 创建项目目录
echo "[5/9] 创建项目目录..."
sudo mkdir -p /var/www/subway-server
sudo chown $USER:$USER /var/www/subway-server

# 6. 克隆代码
echo "[6/9] 克隆代码..."
if [ -d "/var/www/subway-server/.git" ]; then
    echo "代码已存在，更新中..."
    cd /var/www/subway-server
    git pull origin master || git pull origin main
else
    cd /var/www
    git clone https://github.com/gukazma/SubwayWechatApp.git subway-server
fi

# 7. 配置环境
echo "[7/9] 配置环境..."
cd /var/www/subway-server/server

if [ ! -f .env.production ]; then
    cat > .env.production << 'EOF'
NODE_ENV=production
PORT=3000
HOST=0.0.0.0
CORS_ORIGIN=*
LOG_LEVEL=info
EOF
    echo "已创建 .env.production"
fi

# 8. 安装依赖
echo "[8/9] 安装依赖..."
npm install --production

# 9. 启动服务
echo "[9/9] 启动服务..."
if pm2 list | grep -q "subway-wechat-server"; then
    pm2 restart subway-wechat-server
else
    pm2 start ecosystem.config.js --env production
fi
pm2 save
pm2 startup | grep -o 'sudo.*' | bash || true

# 10. 配置防火墙
echo "[10/9] 配置防火墙..."
if command -v ufw &> /dev/null; then
    sudo ufw allow 22/tcp
    sudo ufw allow 3000/tcp
    echo "y" | sudo ufw enable
fi

# 测试
echo ""
echo "测试服务..."
sleep 3
curl -s http://localhost:3000/api/test | grep -q "200" && echo "✅ 服务正常" || echo "⚠️ 服务测试失败"

echo ""
echo "========================================"
echo "   ✅ 配置完成！"
echo "========================================"
echo ""
echo "服务状态:"
pm2 status
echo ""
echo "API 测试: curl http://localhost:3000/api/test"
echo "查看日志: pm2 logs subway-wechat-server"

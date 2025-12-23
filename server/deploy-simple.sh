#!/bin/bash

# 简化版部署脚本 - 一键部署

# 配置
SERVER="your-username@your-server-ip"
REMOTE_PATH="/var/www/subway-server"

echo "🚀 开始部署..."

# 1. 同步代码到服务器
echo "📦 同步代码到服务器..."
rsync -avz --exclude 'node_modules' --exclude '.git' --exclude '.env*' \
      ./ $SERVER:$REMOTE_PATH/

# 2. 在服务器上安装依赖并重启
echo "🔧 安装依赖并重启服务..."
ssh $SERVER << 'EOF'
cd /var/www/subway-server
npm install --production
pm2 restart subway-wechat-server || pm2 start ecosystem.config.js --env production
pm2 save
EOF

echo "✅ 部署完成！"

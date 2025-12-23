# 🚀 GitHub Actions 自动部署 - 快速配置清单

> 代码已推送到 GitHub: https://github.com/gukazma/SubwayWechatApp

## ⚡ 5 分钟快速配置

### 📝 第 1 步：准备服务器信息

准备以下信息：

```
服务器 IP:     _____________________
SSH 用户名:    _____________________
SSH 端口:      22 (默认)
部署路径:      /var/www/subway-server
```

---

### 🔑 第 2 步：获取 SSH 私钥

**在本地电脑执行**：

```bash
# 查看您的 SSH 私钥
cat ~/.ssh/id_rsa

# 或者如果使用 ed25519
cat ~/.ssh/id_ed25519
```

**复制整个输出内容**（包括 BEGIN 和 END 行）：

```
-----BEGIN OPENSSH PRIVATE KEY-----
xxxxxxxxxxxxxxxxxxxxx
...
-----END OPENSSH PRIVATE KEY-----
```

---

### 🎯 第 3 步：配置 GitHub Secrets

1. 打开仓库：https://github.com/gukazma/SubwayWechatApp

2. 点击 **Settings** → **Secrets and variables** → **Actions**

3. 点击 **New repository secret**，依次添加：

#### ① SERVER_HOST
- **Name**: `SERVER_HOST`
- **Value**: 您的服务器 IP（如：`123.45.67.89`）

#### ② SERVER_USER
- **Name**: `SERVER_USER`
- **Value**: SSH 用户名（如：`root` 或 `ubuntu`）

#### ③ SSH_PRIVATE_KEY
- **Name**: `SSH_PRIVATE_KEY`
- **Value**: 粘贴第 2 步复制的完整私钥内容

#### ④ SERVER_PORT（可选）
- **Name**: `SERVER_PORT`
- **Value**: `22`（如果使用默认端口 22 可以不配置）

---

### 🖥️ 第 4 步：准备服务器环境

**SSH 连接到服务器**：

```bash
ssh your-username@your-server-ip
```

**执行以下命令**：

```bash
# 1. 安装 Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. 安装 PM2
sudo npm install -g pm2

# 3. 安装 Git
sudo apt-get install -y git

# 4. 创建部署目录
sudo mkdir -p /var/www/subway-server
sudo chown $USER:$USER /var/www/subway-server

# 5. 克隆代码（首次）
cd /var/www
git clone https://github.com/gukazma/SubwayWechatApp.git subway-server
cd subway-server/server

# 6. 创建环境配置
cat > .env.production << 'EOF'
NODE_ENV=production
PORT=3000
HOST=0.0.0.0
CORS_ORIGIN=*
LOG_LEVEL=info
EOF

# 7. 安装依赖并启动（首次）
npm install --production
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup

# 按照 pm2 startup 的提示执行返回的命令

# 8. 配置防火墙
sudo ufw allow 22/tcp
sudo ufw allow 3000/tcp
sudo ufw enable

# 9. 测试服务
curl http://localhost:3000/api/test
```

---

### ✅ 第 5 步：触发首次部署

#### 方式 1：手动触发（推荐首次使用）

1. 打开：https://github.com/gukazma/SubwayWechatApp/actions

2. 点击左侧 **Deploy to Production**

3. 点击右侧 **Run workflow** 按钮

4. 选择 **master** 分支

5. 点击绿色的 **Run workflow** 按钮

6. 等待部署完成（约 1-2 分钟）

#### 方式 2：自动触发

修改任意后端代码并推送：

```bash
# 在本地项目目录
cd server
echo "// Test auto deployment" >> index.js

git add server/index.js
git commit -m "Test: Trigger auto deployment"
git push github master
```

几秒钟后在 Actions 页面就能看到自动触发的部署。

---

### 🔍 第 6 步：验证部署

**1. 查看 GitHub Actions 日志**：

访问：https://github.com/gukazma/SubwayWechatApp/actions

点击最新的 workflow 查看详细日志。

**2. 在服务器验证**：

```bash
# SSH 连接到服务器
ssh your-username@your-server-ip

# 查看服务状态
pm2 status

# 查看日志
pm2 logs subway-wechat-server

# 测试 API
curl http://localhost:3000/api/test
```

**3. 在浏览器测试**：

访问：`http://your-server-ip:3000/api/test`

如果看到以下响应，说明部署成功：

```json
{
  "code": 200,
  "message": "Server is running!",
  "data": {
    "timestamp": "2025-...",
    "version": "1.0.0",
    "environment": "production"
  }
}
```

---

### 📱 第 7 步：配置小程序前端

修改前端 API 地址：

**文件**：`src/config/env.js`

```javascript
production: {
  baseURL: 'http://YOUR_SERVER_IP:3000/api',  // 改为您的服务器 IP
  apiTimeout: 30000,
  enableLog: false
}
```

提交并推送：

```bash
git add src/config/env.js
git commit -m "Update production API URL"
git push github master
```

---

## ✨ 完成！

现在您的项目已经配置了自动化部署！

### 🎯 工作流程

```
本地修改代码
   ↓
git push github master
   ↓
GitHub Actions 自动触发
   ↓
连接服务器并部署
   ↓
自动重启服务
   ↓
健康检查
   ↓
部署完成 ✅
```

### 📚 相关文档

- **详细部署指南**: [GITHUB_ACTIONS_GUIDE.md](GITHUB_ACTIONS_GUIDE.md)
- **环境配置说明**: [ENV_GUIDE.md](ENV_GUIDE.md)
- **完整部署方案**: [DEPLOYMENT.md](DEPLOYMENT.md)
- **快速部署**: [server/QUICK_START.md](server/QUICK_START.md)

### 🆘 遇到问题？

1. 查看 [GITHUB_ACTIONS_GUIDE.md](GITHUB_ACTIONS_GUIDE.md) 的故障排查部分
2. 查看 GitHub Actions 日志
3. SSH 到服务器查看 PM2 日志：`pm2 logs`

---

## 🔄 后续使用

### 日常开发流程

```bash
# 1. 修改代码
vim server/index.js

# 2. 提交代码
git add .
git commit -m "Update: xxx"

# 3. 推送到 GitHub（自动触发部署）
git push github master
```

### 查看部署状态

- **GitHub**: https://github.com/gukazma/SubwayWechatApp/actions
- **服务器**: `pm2 status` 和 `pm2 logs`

### 常用命令

```bash
# 查看服务状态
pm2 status

# 查看日志
pm2 logs subway-wechat-server

# 重启服务
pm2 restart subway-wechat-server

# 停止服务
pm2 stop subway-wechat-server
```

---

**祝您使用愉快！** 🎉

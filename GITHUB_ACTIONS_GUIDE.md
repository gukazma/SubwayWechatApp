# GitHub Actions 自动化部署指南

本指南将帮助您使用 GitHub Actions 实现自动化部署。

## 📋 目录

1. [前置准备](#前置准备)
2. [服务器配置](#服务器配置)
3. [GitHub 仓库配置](#github-仓库配置)
4. [配置 SSH 密钥](#配置-ssh-密钥)
5. [配置 GitHub Secrets](#配置-github-secrets)
6. [首次部署](#首次部署)
7. [触发自动部署](#触发自动部署)
8. [查看部署日志](#查看部署日志)
9. [故障排查](#故障排查)

---

## 前置准备

### 1. 需要的信息

准备以下信息：

| 项目 | 说明 | 示例 |
|------|------|------|
| 服务器 IP | 您的服务器公网 IP | `123.45.67.89` |
| 服务器用户名 | SSH 登录用户名 | `root` 或 `ubuntu` |
| SSH 端口 | SSH 端口号 | `22`（默认） |
| 部署路径 | 代码部署位置 | `/var/www/subway-server` |

### 2. 服务器要求

- ✅ 已安装 Node.js 18+
- ✅ 已安装 PM2
- ✅ 已安装 Git
- ✅ 开放了必要的端口（22, 3000）

---

## 服务器配置

### 步骤 1: 连接到服务器

```bash
ssh your-username@your-server-ip
```

### 步骤 2: 安装必要软件

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装 Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装 PM2
sudo npm install -g pm2

# 安装 Git
sudo apt-get install -y git

# 验证安装
node --version
npm --version
pm2 --version
git --version
```

### 步骤 3: 创建部署目录并克隆代码

```bash
# 创建目录
sudo mkdir -p /var/www/subway-server
sudo chown $USER:$USER /var/www/subway-server

# 克隆代码（首次）
cd /var/www
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git subway-server
cd subway-server

# 进入 server 目录
cd server

# 创建生产环境配置
cat > .env.production << 'EOF'
NODE_ENV=production
PORT=3000
HOST=0.0.0.0
CORS_ORIGIN=*
LOG_LEVEL=info
EOF

# 安装依赖
npm install --production

# 启动服务（首次）
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup  # 设置开机自启，按提示执行返回的命令
```

### 步骤 4: 配置防火墙

```bash
# Ubuntu/Debian
sudo ufw allow 22/tcp
sudo ufw allow 3000/tcp
sudo ufw enable

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --reload
```

### 步骤 5: 测试服务

```bash
# 检查服务状态
pm2 status

# 测试 API
curl http://localhost:3000/api/test

# 查看日志
pm2 logs subway-wechat-server
```

---

## GitHub 仓库配置

### 步骤 1: 创建 GitHub 仓库

1. 访问 [GitHub](https://github.com/)
2. 点击右上角 `+` → `New repository`
3. 填写仓库名称，如 `subway-wechat-app`
4. 选择 Public 或 Private
5. 点击 `Create repository`

### 步骤 2: 推送代码到 GitHub

在本地项目目录执行：

```bash
# 如果是新仓库
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main

# 如果已有仓库
git add .
git commit -m "Add deployment configuration"
git push
```

---

## 配置 SSH 密钥

### 方式一：使用现有 SSH 密钥（推荐）

如果您已经可以通过 SSH 登录服务器：

```bash
# 在本地查看私钥
cat ~/.ssh/id_rsa

# 或者
cat ~/.ssh/id_ed25519
```

复制整个私钥内容（包括 `-----BEGIN` 和 `-----END` 行）。

### 方式二：创建新的 SSH 密钥

```bash
# 在本地生成新密钥（专用于部署）
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github_actions_deploy

# 将公钥添加到服务器
ssh-copy-id -i ~/.ssh/github_actions_deploy.pub your-username@your-server-ip

# 或手动添加
cat ~/.ssh/github_actions_deploy.pub
# 复制输出内容，然后在服务器上执行：
# echo "复制的公钥内容" >> ~/.ssh/authorized_keys

# 查看私钥（用于 GitHub Secrets）
cat ~/.ssh/github_actions_deploy
```

### 测试 SSH 连接

```bash
# 使用私钥测试连接
ssh -i ~/.ssh/github_actions_deploy your-username@your-server-ip

# 如果成功连接，说明配置正确
```

---

## 配置 GitHub Secrets

### 步骤 1: 进入 Secrets 设置

1. 打开您的 GitHub 仓库
2. 点击 `Settings`（设置）
3. 在左侧菜单找到 `Secrets and variables` → `Actions`
4. 点击 `New repository secret`

### 步骤 2: 添加以下 Secrets

#### 1️⃣ SERVER_HOST（必需）

- **Name**: `SERVER_HOST`
- **Value**: 您的服务器 IP 地址
- 示例: `123.45.67.89`

#### 2️⃣ SERVER_USER（必需）

- **Name**: `SERVER_USER`
- **Value**: SSH 登录用户名
- 示例: `root` 或 `ubuntu`

#### 3️⃣ SSH_PRIVATE_KEY（必需）

- **Name**: `SSH_PRIVATE_KEY`
- **Value**: SSH 私钥的完整内容

复制私钥时，确保包含完整内容：

```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtz
... (中间省略很多行) ...
AAAAAAAAAAE=
-----END OPENSSH PRIVATE KEY-----
```

#### 4️⃣ SERVER_PORT（可选）

- **Name**: `SERVER_PORT`
- **Value**: SSH 端口号
- 默认: `22`（如果使用默认端口可以不设置）

### 步骤 3: 验证 Secrets

配置完成后，您应该看到：

- ✅ SERVER_HOST
- ✅ SERVER_USER
- ✅ SSH_PRIVATE_KEY
- ⚪ SERVER_PORT（可选）

---

## 首次部署

### 步骤 1: 确保代码已推送

```bash
git status
git add .
git commit -m "Setup GitHub Actions deployment"
git push origin main  # 或 master
```

### 步骤 2: 手动触发部署

1. 打开 GitHub 仓库
2. 点击 `Actions` 标签
3. 在左侧选择 `Deploy to Production`
4. 点击右侧 `Run workflow` 按钮
5. 选择分支（main 或 master）
6. 点击绿色的 `Run workflow` 按钮

### 步骤 3: 观察部署过程

部署会经历以下步骤：

1. 📥 Checkout code - 检出代码
2. 🔧 Setup Node.js - 设置 Node.js 环境
3. 📦 Install dependencies - 安装依赖
4. ✅ Run tests - 运行测试
5. 🚀 Deploy to server - 部署到服务器
6. 🔍 Health check - 健康检查
7. 📢 Notification - 通知结果

---

## 触发自动部署

### 自动触发条件

当满足以下条件时，会自动触发部署：

1. **推送代码到 main/master 分支**
   ```bash
   git push origin main
   ```

2. **只有当 server 目录有变化时**
   - 修改了 `server/` 目录下的文件
   - 或修改了 `.github/workflows/deploy.yml`

### 测试自动部署

修改后端代码并推送：

```bash
# 修改一个文件
echo "// Test deployment" >> server/index.js

# 提交并推送
git add server/index.js
git commit -m "Test: Trigger auto deployment"
git push origin main
```

几秒钟后，在 GitHub Actions 页面就能看到自动触发的部署。

---

## 查看部署日志

### 在 GitHub 查看

1. 打开仓库的 `Actions` 页面
2. 点击最新的 workflow 运行
3. 点击 `deploy` 作业查看详细日志
4. 展开各个步骤查看输出

### 在服务器查看

```bash
# 查看 PM2 日志
pm2 logs subway-wechat-server

# 查看最近 50 行日志
pm2 logs subway-wechat-server --lines 50

# 只查看错误日志
pm2 logs subway-wechat-server --err

# 查看 PM2 状态
pm2 status
```

---

## 故障排查

### 问题 1: SSH 连接失败

**错误信息**:
```
Error: Failed to connect to server
```

**解决方法**:

1. 检查 SERVER_HOST 和 SERVER_USER 是否正确
2. 验证 SSH 私钥格式是否正确（包含完整的 BEGIN 和 END 行）
3. 确保服务器防火墙允许来自 GitHub 的连接
4. 在本地测试 SSH 连接：
   ```bash
   ssh -i ~/.ssh/your_key your-user@your-server
   ```

### 问题 2: PM2 未找到

**错误信息**:
```
PM2 not found! Please install PM2 first.
```

**解决方法**:

在服务器上安装 PM2：
```bash
sudo npm install -g pm2
pm2 --version
```

### 问题 3: Git pull 失败

**错误信息**:
```
fatal: could not read Username for 'https://github.com'
```

**解决方法**:

使用 SSH URL 而不是 HTTPS：
```bash
# 在服务器上
cd /var/www/subway-server
git remote set-url origin git@github.com:YOUR_USERNAME/YOUR_REPO.git

# 或者重新克隆
cd /var/www
rm -rf subway-server
git clone git@github.com:YOUR_USERNAME/YOUR_REPO.git subway-server
```

### 问题 4: 权限错误

**错误信息**:
```
Permission denied
```

**解决方法**:

```bash
# 修改目录所有者
sudo chown -R $USER:$USER /var/www/subway-server

# 或者使用 sudo 用户部署
# 修改 SERVER_USER 为 root 或有 sudo 权限的用户
```

### 问题 5: 端口占用

**错误信息**:
```
Error: listen EADDRINUSE: address already in use :::3000
```

**解决方法**:

```bash
# 查看占用端口的进程
sudo netstat -tulpn | grep 3000

# 停止旧进程
pm2 stop all
pm2 delete all

# 重新启动
pm2 start ecosystem.config.js --env production
pm2 save
```

### 问题 6: 健康检查失败

**警告信息**:
```
⚠️ Health check returned status code: 000
```

**解决方法**:

1. 检查服务是否正常启动：
   ```bash
   pm2 status
   pm2 logs subway-wechat-server
   ```

2. 手动测试 API：
   ```bash
   curl http://localhost:3000/api/test
   ```

3. 检查防火墙设置

---

## 高级配置

### 添加通知（可选）

可以添加邮件、Slack 等通知。在 `.github/workflows/deploy.yml` 最后添加：

```yaml
- name: Send notification to Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### 配置多环境部署

创建多个 workflow 文件：
- `.github/workflows/deploy-staging.yml` - 测试环境
- `.github/workflows/deploy-production.yml` - 生产环境

---

## 部署检查清单

部署前请确认：

- [ ] 服务器已安装 Node.js、PM2、Git
- [ ] 服务器已创建 `/var/www/subway-server` 目录
- [ ] 服务器已配置 `.env.production` 文件
- [ ] SSH 密钥已正确配置
- [ ] GitHub Secrets 已全部添加
- [ ] 代码已推送到 GitHub
- [ ] 防火墙已开放必要端口
- [ ] 已手动测试过一次部署

---

## 完整部署流程图

```
┌─────────────────┐
│  本地修改代码    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  git push       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ GitHub Actions  │
│  自动触发       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  连接服务器     │
│  SSH            │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  拉取最新代码   │
│  git pull       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  安装依赖       │
│  npm install    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  重启服务       │
│  pm2 restart    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  健康检查       │
│  curl API       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  部署完成 ✅    │
└─────────────────┘
```

---

## 恭喜！🎉

您已经成功配置了 GitHub Actions 自动化部署！

现在，每次您推送代码到 main/master 分支，系统都会自动部署到服务器。

**下一步**:
- 配置域名和 HTTPS
- 添加数据库
- 配置监控和告警
- 优化部署流程

如有问题，请查看 [DEPLOYMENT.md](DEPLOYMENT.md) 或提交 Issue。

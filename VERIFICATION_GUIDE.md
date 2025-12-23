# 🔍 配置验证脚本

此脚本帮助您验证 GitHub Actions 自动部署的所有配置是否正确。

---

## ✅ 验证清单

### 1. 本地 SSH 密钥验证

```bash
# 检查密钥文件是否存在
ls -lh ~/.ssh/github_deploy*

# 查看公钥内容
cat ~/.ssh/github_deploy.pub

# 查看私钥开头（确认格式）
head -n 2 ~/.ssh/github_deploy
```

**预期结果**：
- ✅ 两个文件都存在：`github_deploy` 和 `github_deploy.pub`
- ✅ 公钥以 `ssh-ed25519` 开头
- ✅ 私钥以 `-----BEGIN OPENSSH PRIVATE KEY-----` 开头

---

### 2. SSH 连接测试

**请提供您的服务器信息**：
- 服务器 IP: _______________
- SSH 用户名: _______________

```bash
# 测试 SSH 连接（替换为您的信息）
ssh -i ~/.ssh/github_deploy your-username@your-server-ip "echo '✅ SSH 连接成功！'"
```

**预期结果**：
- ✅ 不需要输入密码
- ✅ 显示 "✅ SSH 连接成功！"

---

### 3. GitHub Secrets 验证

访问：https://github.com/gukazma/SubwayWechatApp/settings/secrets/actions

**检查清单**：
- [ ] `SERVER_HOST` 已配置（服务器 IP）
- [ ] `SERVER_USER` 已配置（SSH 用户名）
- [ ] `SSH_PRIVATE_KEY` 已配置（完整私钥内容）

**注意**：GitHub 不会显示 Secret 的值，只能看到名称和更新时间。

---

### 4. 服务器环境验证

SSH 连接到服务器后执行：

```bash
# 检查 Node.js
node --version
# 预期：v18.x.x 或更高

# 检查 PM2
pm2 --version
# 预期：5.x.x

# 检查 Git
git --version
# 预期：2.x.x

# 检查项目目录
ls -la /var/www/subway-server/
# 预期：存在 .git 目录

# 检查代码
cd /var/www/subway-server && git status
# 预期：On branch master

# 检查 .env.production
cat /var/www/subway-server/server/.env.production
# 预期：包含 NODE_ENV=production 等配置

# 检查服务状态
pm2 status
# 预期：subway-wechat-server 状态为 online

# 测试 API
curl http://localhost:3000/api/test
# 预期：返回 JSON，code: 200
```

---

### 5. 防火墙验证

```bash
# 检查防火墙状态
sudo ufw status

# 预期看到：
# 22/tcp    ALLOW    Anywhere
# 3000/tcp  ALLOW    Anywhere
```

---

### 6. 从外网访问测试

在本地浏览器或命令行测试：

```bash
# 替换为您的服务器 IP
curl http://YOUR_SERVER_IP:3000/api/test
```

**预期结果**：
```json
{
  "code": 200,
  "message": "Server is running!",
  "data": {
    "timestamp": "...",
    "version": "1.0.0",
    "environment": "production"
  }
}
```

---

## 🧪 完整验证脚本

### 本地验证（在 Windows PowerShell 中运行）

```powershell
Write-Host "=== 1. 检查 SSH 密钥 ===" -ForegroundColor Cyan
if (Test-Path ~/.ssh/github_deploy) {
    Write-Host "✅ 私钥文件存在" -ForegroundColor Green
} else {
    Write-Host "❌ 私钥文件不存在" -ForegroundColor Red
}

if (Test-Path ~/.ssh/github_deploy.pub) {
    Write-Host "✅ 公钥文件存在" -ForegroundColor Green
} else {
    Write-Host "❌ 公钥文件不存在" -ForegroundColor Red
}

Write-Host "`n=== 2. SSH 连接测试 ===" -ForegroundColor Cyan
$SERVER_USER = Read-Host "输入服务器用户名"
$SERVER_IP = Read-Host "输入服务器 IP"

Write-Host "测试 SSH 连接..." -ForegroundColor Yellow
try {
    $result = ssh -i ~/.ssh/github_deploy "$SERVER_USER@$SERVER_IP" "echo 'SSH连接成功'"
    if ($result -eq "SSH连接成功") {
        Write-Host "✅ SSH 连接成功" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ SSH 连接失败: $_" -ForegroundColor Red
}

Write-Host "`n=== 3. GitHub Secrets ===" -ForegroundColor Cyan
Write-Host "请访问以下链接检查 Secrets 配置：" -ForegroundColor Yellow
Write-Host "https://github.com/gukazma/SubwayWechatApp/settings/secrets/actions" -ForegroundColor Blue

Write-Host "`n=== 4. 外网访问测试 ===" -ForegroundColor Cyan
Write-Host "测试 API 访问..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://${SERVER_IP}:3000/api/test" -TimeoutSec 10
    if ($response.code -eq 200) {
        Write-Host "✅ API 访问成功" -ForegroundColor Green
        Write-Host "环境: $($response.data.environment)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ API 访问失败: $_" -ForegroundColor Red
    Write-Host "提示：检查服务器防火墙是否开放 3000 端口" -ForegroundColor Yellow
}
```

### 服务器验证（在 Ubuntu 服务器上运行）

```bash
#!/bin/bash

echo "=== 服务器环境验证 ==="
echo ""

# Node.js
echo -n "Node.js: "
if command -v node &> /dev/null; then
    node --version
else
    echo "❌ 未安装"
fi

# PM2
echo -n "PM2: "
if command -v pm2 &> /dev/null; then
    echo "v$(pm2 --version)"
else
    echo "❌ 未安装"
fi

# Git
echo -n "Git: "
if command -v git &> /dev/null; then
    git --version
else
    echo "❌ 未安装"
fi

# 项目目录
echo ""
echo "=== 项目检查 ==="
if [ -d "/var/www/subway-server" ]; then
    echo "✅ 项目目录存在"

    if [ -d "/var/www/subway-server/.git" ]; then
        echo "✅ Git 仓库已初始化"
    fi

    if [ -f "/var/www/subway-server/server/.env.production" ]; then
        echo "✅ .env.production 已配置"
    else
        echo "❌ .env.production 不存在"
    fi
else
    echo "❌ 项目目录不存在"
fi

# 服务状态
echo ""
echo "=== 服务状态 ==="
pm2 status | grep subway-wechat-server

# API 测试
echo ""
echo "=== API 测试 ==="
response=$(curl -s http://localhost:3000/api/test)
if echo "$response" | grep -q '"code":200'; then
    echo "✅ API 正常运行"
    echo "$response" | grep -o '"environment":"[^"]*"'
else
    echo "❌ API 测试失败"
fi

# 防火墙
echo ""
echo "=== 防火墙状态 ==="
sudo ufw status | grep -E "22|3000"
```

---

## 📊 验证结果评估

### 全部通过 ✅

如果所有检查都通过，您可以：
1. 触发一次手动部署测试
2. 修改代码测试自动部署

### 部分失败 ⚠️

根据具体失败项查看对应的故障排查：

| 失败项 | 解决方案 |
|-------|---------|
| SSH 密钥不存在 | 重新生成：`ssh-keygen -t ed25519 -f ~/.ssh/github_deploy` |
| SSH 连接失败 | 检查公钥是否已添加到服务器 |
| Node.js 未安装 | 运行 setup-ubuntu.sh |
| PM2 未安装 | `sudo npm install -g pm2` |
| 项目目录不存在 | 克隆代码或运行 setup-ubuntu.sh |
| API 测试失败 | 检查服务是否启动：`pm2 status` |
| 外网访问失败 | 检查防火墙：`sudo ufw allow 3000/tcp` |

---

## 🚀 下一步：触发部署

所有验证通过后，可以触发首次部署：

### 方式 1: 手动触发

1. 访问：https://github.com/gukazma/SubwayWechatApp/actions
2. 点击 "Deploy to Production"
3. 点击 "Run workflow"
4. 选择 master 分支
5. 点击运行

### 方式 2: 自动触发

```bash
# 修改代码触发
cd server
echo "// Test deployment - $(date)" >> index.js
git add server/index.js
git commit -m "test: Trigger auto deployment"
git push github master
```

---

## 📞 需要帮助？

如果验证过程中遇到问题：

1. 查看对应的故障排查文档
2. 检查 GitHub Actions 日志
3. 查看服务器日志：`pm2 logs`
4. 提交 Issue 寻求帮助

---

**准备好了？开始部署测试吧！** 🎉

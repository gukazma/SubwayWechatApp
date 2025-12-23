# 🔍 快速验证命令

## 方式 1: 使用 PowerShell 验证脚本（推荐）

在项目目录下，右键点击 `verify-config.ps1` 选择"使用 PowerShell 运行"

或在 PowerShell 中执行：

```powershell
.\verify-config.ps1
```

脚本会自动检查：
- ✅ SSH 密钥
- ✅ SSH 连接
- ✅ GitHub Secrets（需要手动确认）
- ✅ 服务器环境
- ✅ 服务状态
- ✅ API 访问

---

## 方式 2: 手动验证命令

### 1️⃣ 验证 SSH 密钥（本地）

```powershell
# 检查密钥文件
ls ~/.ssh/github_deploy*

# 查看公钥
cat ~/.ssh/github_deploy.pub
```

**预期**：显示两个文件和公钥内容

---

### 2️⃣ 验证 SSH 连接（本地）

```powershell
# 替换为您的服务器信息
ssh -i ~/.ssh/github_deploy your-username@your-server-ip "echo '✅ SSH 连接成功'"
```

**预期**：不需要密码，显示 "✅ SSH 连接成功"

---

### 3️⃣ 验证 GitHub Secrets

访问：https://github.com/gukazma/SubwayWechatApp/settings/secrets/actions

**检查**：应该看到 3 个 Secrets：
- `SERVER_HOST`
- `SERVER_USER`
- `SSH_PRIVATE_KEY`

---

### 4️⃣ 验证服务器环境（在服务器上）

```bash
# SSH 连接到服务器
ssh your-username@your-server-ip

# 检查软件版本
node --version    # 应该是 v18.x.x
pm2 --version     # 应该是 5.x.x
git --version     # 应该是 2.x.x

# 检查项目
ls -la /var/www/subway-server/

# 检查服务
pm2 status

# 测试 API
curl http://localhost:3000/api/test
```

**预期**：
- Node.js, PM2, Git 都已安装
- 项目目录存在
- 服务状态为 online
- API 返回 JSON，code: 200

---

### 5️⃣ 验证外网访问（本地）

```powershell
# 替换为您的服务器 IP
curl http://YOUR_SERVER_IP:3000/api/test
```

或在浏览器访问：`http://YOUR_SERVER_IP:3000/api/test`

**预期**：返回 JSON 响应

---

## ✅ 验证清单

### 本地配置
- [ ] SSH 私钥存在：`~/.ssh/github_deploy`
- [ ] SSH 公钥存在：`~/.ssh/github_deploy.pub`
- [ ] SSH 可以免密连接服务器

### GitHub 配置
- [ ] SERVER_HOST 已配置
- [ ] SERVER_USER 已配置
- [ ] SSH_PRIVATE_KEY 已配置（完整私钥）

### 服务器环境
- [ ] Node.js 18+ 已安装
- [ ] PM2 已安装
- [ ] Git 已安装
- [ ] 项目已克隆到 `/var/www/subway-server`
- [ ] `.env.production` 已创建
- [ ] 服务正在运行（pm2 status 显示 online）

### 网络访问
- [ ] 防火墙已开放 22 端口（SSH）
- [ ] 防火墙已开放 3000 端口（API）
- [ ] 可以从外网访问 API

---

## 🧪 快速测试脚本

### Windows PowerShell 一键验证

```powershell
# 设置服务器信息
$SERVER_IP = "YOUR_SERVER_IP"      # 替换为实际 IP
$SERVER_USER = "YOUR_USERNAME"      # 替换为实际用户名

Write-Host "=== 开始验证 ===" -ForegroundColor Cyan

# 1. SSH 连接
Write-Host "`n[1/4] 测试 SSH 连接..." -ForegroundColor Yellow
try {
    $result = ssh -i ~/.ssh/github_deploy $SERVER_USER@$SERVER_IP "echo 'connected'"
    if ($result -eq "connected") {
        Write-Host "✅ SSH 连接成功" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ SSH 连接失败" -ForegroundColor Red
}

# 2. 检查服务器环境
Write-Host "`n[2/4] 检查服务器环境..." -ForegroundColor Yellow
ssh -i ~/.ssh/github_deploy $SERVER_USER@$SERVER_IP @"
echo "Node.js: `$(node --version 2>/dev/null || echo '❌ 未安装')"
echo "PM2: v`$(pm2 --version 2>/dev/null || echo '❌ 未安装')"
echo "Git: `$(git --version 2>/dev/null || echo '❌ 未安装')"
"@

# 3. 检查服务状态
Write-Host "`n[3/4] 检查服务状态..." -ForegroundColor Yellow
ssh -i ~/.ssh/github_deploy $SERVER_USER@$SERVER_IP "pm2 status | grep subway-wechat-server || echo '❌ 服务未启动'"

# 4. 测试 API
Write-Host "`n[4/4] 测试 API 访问..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://${SERVER_IP}:3000/api/test" -TimeoutSec 10
    if ($response.code -eq 200) {
        Write-Host "✅ API 访问成功" -ForegroundColor Green
        Write-Host "   环境: $($response.data.environment)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ API 访问失败" -ForegroundColor Red
}

Write-Host "`n=== 验证完成 ===" -ForegroundColor Cyan
```

---

## 🎯 全部通过后的下一步

### 1. 手动触发部署测试

访问：https://github.com/gukazma/SubwayWechatApp/actions

- 点击 "Deploy to Production"
- 点击 "Run workflow"
- 选择 master 分支
- 点击运行

### 2. 观察部署过程

查看每个步骤的执行情况：
- 📥 Checkout code
- 🔧 Setup Node.js
- 📦 Install dependencies
- 🚀 Deploy to server
- 🔍 Health check
- 📢 Notification

### 3. 验证部署结果

```bash
# 在服务器上
pm2 logs subway-wechat-server
```

或访问：`http://YOUR_SERVER_IP:3000/api/test`

---

**使用 verify-config.ps1 脚本可以自动完成所有验证！** 🚀

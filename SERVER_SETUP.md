# 🖥️ 服务器环境配置指南

完成 GitHub Secrets 配置后，需要准备服务器环境。

---

## 方式 1: 自动配置（推荐）⭐

使用一键配置脚本，自动完成所有安装和配置。

### 步骤 1: 上传脚本到服务器

**在本地执行**:

```bash
# 方式 A: 使用 SCP 上传
scp setup-server.sh your-username@your-server-ip:~/

# 方式 B: 直接下载
# （在服务器上执行）
wget https://raw.githubusercontent.com/gukazma/SubwayWechatApp/master/setup-server.sh
```

### 步骤 2: 执行配置脚本

**SSH 连接到服务器后执行**:

```bash
# 添加执行权限
chmod +x setup-server.sh

# 运行脚本
bash setup-server.sh
```

脚本会自动完成以下操作:
- ✅ 更新系统
- ✅ 安装 Node.js 18
- ✅ 安装 PM2
- ✅ 安装 Git
- ✅ 创建项目目录 /var/www/subway-server
- ✅ 克隆代码
- ✅ 创建 .env.production 文件
- ✅ 安装依赖
- ✅ 启动服务
- ✅ 配置防火墙
- ✅ 测试服务

**预计时间**: 5-10 分钟

---

## 方式 2: 手动配置

如果自动脚本失败，可以手动配置。

### 步骤 1: 连接到服务器

```bash
ssh your-username@your-server-ip
```

### 步骤 2: 安装 Node.js 18

```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 验证安装
node --version  # 应该显示 v18.x.x
npm --version
```

### 步骤 3: 安装 PM2

```bash
sudo npm install -g pm2

# 验证安装
pm2 --version
```

### 步骤 4: 安装 Git

```bash
sudo apt-get install -y git

# 验证安装
git --version
```

### 步骤 5: 创建项目目录

```bash
sudo mkdir -p /var/www/subway-server
sudo chown $USER:$USER /var/www/subway-server
```

### 步骤 6: 克隆代码

```bash
cd /var/www
git clone https://github.com/gukazma/SubwayWechatApp.git subway-server
cd subway-server
```

### 步骤 7: 配置环境

```bash
cd server

# 创建生产环境配置
cat > .env.production << 'EOF'
NODE_ENV=production
PORT=3000
HOST=0.0.0.0
CORS_ORIGIN=*
LOG_LEVEL=info
EOF
```

### 步骤 8: 安装依赖

```bash
npm install --production
```

### 步骤 9: 启动服务

```bash
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup  # 按照提示执行返回的命令
```

### 步骤 10: 配置防火墙

```bash
# Ubuntu/Debian (UFW)
sudo ufw allow 22/tcp
sudo ufw allow 3000/tcp
sudo ufw enable

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --reload
```

### 步骤 11: 测试服务

```bash
# 查看服务状态
pm2 status

# 查看日志
pm2 logs subway-wechat-server

# 测试 API
curl http://localhost:3000/api/test
```

---

## 验证配置

### 1. 检查服务状态

```bash
pm2 status
```

应该看到 `subway-wechat-server` 状态为 `online`。

### 2. 测试 API

```bash
curl http://localhost:3000/api/test
```

应该返回:

```json
{
  "code": 200,
  "message": "Server is running!",
  "data": {
    "timestamp": "2025-12-23...",
    "version": "1.0.0",
    "environment": "production"
  }
}
```

### 3. 检查防火墙

```bash
# UFW
sudo ufw status

# 应该看到
# 22/tcp    ALLOW    Anywhere
# 3000/tcp  ALLOW    Anywhere
```

### 4. 从外网访问（可选）

在浏览器中访问:

```
http://your-server-ip:3000/api/test
```

---

## 配置清单

完成后请确认:

- [ ] Node.js 18+ 已安装
- [ ] PM2 已安装
- [ ] Git 已安装
- [ ] 项目目录 `/var/www/subway-server` 已创建
- [ ] 代码已克隆
- [ ] `.env.production` 文件已创建
- [ ] 依赖已安装 (node_modules 目录存在)
- [ ] 服务已启动 (`pm2 status` 显示 online)
- [ ] 防火墙已配置 (22, 3000 端口开放)
- [ ] API 测试通过

---

## 常用命令

```bash
# 查看服务状态
pm2 status

# 查看日志（实时）
pm2 logs subway-wechat-server

# 查看最近 100 行日志
pm2 logs subway-wechat-server --lines 100

# 重启服务
pm2 restart subway-wechat-server

# 停止服务
pm2 stop subway-wechat-server

# 删除服务
pm2 delete subway-wechat-server

# 实时监控
pm2 monit

# 查看详细信息
pm2 describe subway-wechat-server
```

---

## 故障排查

### 问题 1: Node.js 版本过低

```bash
# 卸载旧版本
sudo apt-get remove nodejs

# 重新安装 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 问题 2: PM2 命令未找到

```bash
# 确保 npm 全局 bin 在 PATH 中
export PATH=$PATH:$(npm config get prefix)/bin
echo 'export PATH=$PATH:$(npm config get prefix)/bin' >> ~/.bashrc
source ~/.bashrc

# 重新安装 PM2
sudo npm install -g pm2
```

### 问题 3: 端口被占用

```bash
# 查看 3000 端口占用
sudo netstat -tulpn | grep 3000

# 或
sudo lsof -i :3000

# 杀死占用进程
sudo kill -9 <PID>
```

### 问题 4: 权限问题

```bash
# 修改目录所有者
sudo chown -R $USER:$USER /var/www/subway-server

# 或使用 sudo 运行
sudo pm2 start ecosystem.config.js --env production
```

### 问题 5: Git 克隆失败

```bash
# 使用 HTTPS 克隆
git clone https://github.com/gukazma/SubwayWechatApp.git subway-server

# 如果仍然失败，尝试配置代理或手动下载 ZIP
```

---

## 环境变量配置（高级）

如果需要自定义配置，编辑 `.env.production`:

```bash
cd /var/www/subway-server/server
vi .env.production
```

可配置项:

```env
# 环境标识
NODE_ENV=production

# 服务端口
PORT=3000

# 监听地址（0.0.0.0 允许外部访问）
HOST=0.0.0.0

# CORS 配置（生产环境建议设置具体域名）
CORS_ORIGIN=*

# 日志级别
LOG_LEVEL=info

# 数据库配置（如果使用）
# DB_HOST=localhost
# DB_PORT=3306
# DB_NAME=subway_db
# DB_USER=root
# DB_PASSWORD=your_password
```

修改后重启服务:

```bash
pm2 restart subway-wechat-server
```

---

## 下一步

服务器环境配置完成后:

1. ✅ 确认 [GitHub Secrets](SECRETS_SETUP.md) 已配置
2. ✅ 确认服务器环境已准备
3. ➡️ 进行[自动部署测试](TEST_DEPLOYMENT.md)

---

**需要帮助？** 查看 [故障排查](GITHUB_ACTIONS_GUIDE.md#故障排查) 或提交 Issue。

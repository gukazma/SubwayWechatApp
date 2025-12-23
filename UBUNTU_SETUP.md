# 🐧 Ubuntu 服务器配置指南

针对 **Ubuntu 22.04 64位** 的快速配置指南。

---

## 🚀 快速配置（推荐）

### 方式 1: 一键配置脚本

在服务器上执行：

```bash
# 下载并运行配置脚本
wget https://raw.githubusercontent.com/gukazma/SubwayWechatApp/master/setup-ubuntu.sh
bash setup-ubuntu.sh
```

脚本会自动完成：
- ✅ 安装 Node.js 18
- ✅ 安装 PM2
- ✅ 安装 Git
- ✅ 克隆代码
- ✅ 配置环境
- ✅ 安装依赖
- ✅ 启动服务
- ✅ 配置防火墙

**预计时间**: 5-10 分钟

---

## ❌ 常见问题：行尾格式错误

### 问题现象

```bash
$ sh setup-server.sh
: not found: 2:
: not found: 5:
```

### 原因

脚本文件使用了 Windows 的 CRLF 行尾格式，Linux 需要 LF 格式。

### 解决方案

#### 方案 1: 使用专门的 Ubuntu 脚本（推荐）

```bash
wget https://raw.githubusercontent.com/gukazma/SubwayWechatApp/master/setup-ubuntu.sh
bash setup-ubuntu.sh
```

#### 方案 2: 转换行尾格式

```bash
# 安装 dos2unix
sudo apt-get install -y dos2unix

# 转换文件
dos2unix setup-server.sh

# 运行脚本
bash setup-ubuntu.sh
```

#### 方案 3: 使用 sed 转换

```bash
sed -i 's/\r$//' setup-server.sh
bash setup-server.sh
```

---

## 📝 手动配置步骤

如果自动脚本失败，可以手动执行以下步骤：

### 1. 更新系统

```bash
sudo apt-get update -y
sudo apt-get upgrade -y
```

### 2. 安装 Node.js 18

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 验证安装
node --version  # 应该显示 v18.x.x
npm --version
```

### 3. 安装 PM2

```bash
sudo npm install -g pm2

# 验证安装
pm2 --version
```

### 4. 安装 Git

```bash
sudo apt-get install -y git

# 验证安装
git --version
```

### 5. 创建项目目录并克隆代码

```bash
# 创建目录
sudo mkdir -p /var/www/subway-server
sudo chown $USER:$USER /var/www/subway-server

# 克隆代码
cd /var/www
git clone https://github.com/gukazma/SubwayWechatApp.git subway-server
cd subway-server
```

### 6. 配置环境变量

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

### 7. 安装依赖

```bash
npm install --production
```

### 8. 启动服务

```bash
pm2 start ecosystem.config.js --env production
pm2 save

# 设置开机自启
pm2 startup
# 复制并执行返回的命令，例如：
# sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu
```

### 9. 配置防火墙

```bash
# 允许 SSH 和应用端口
sudo ufw allow 22/tcp
sudo ufw allow 3000/tcp

# 启用防火墙
sudo ufw enable

# 查看状态
sudo ufw status
```

### 10. 测试服务

```bash
# 查看服务状态
pm2 status

# 测试 API
curl http://localhost:3000/api/test

# 查看日志
pm2 logs subway-wechat-server
```

---

## ✅ 验证配置

### 检查软件版本

```bash
node --version    # v18.x.x
npm --version     # 9.x.x
pm2 --version     # 5.x.x
git --version     # 2.x.x
```

### 检查服务状态

```bash
pm2 status
```

应该看到 `subway-wechat-server` 状态为 `online`。

### 检查 API

```bash
curl http://localhost:3000/api/test
```

应该返回：

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

### 检查防火墙

```bash
sudo ufw status
```

应该显示：

```
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
3000/tcp                   ALLOW       Anywhere
```

---

## 🔧 常用命令

```bash
# 查看服务状态
pm2 status

# 查看日志（实时）
pm2 logs subway-wechat-server

# 查看最近日志
pm2 logs subway-wechat-server --lines 100

# 重启服务
pm2 restart subway-wechat-server

# 停止服务
pm2 stop subway-wechat-server

# 查看详细信息
pm2 describe subway-wechat-server

# 监控
pm2 monit

# 更新代码
cd /var/www/subway-server
git pull origin master
cd server
npm install --production
pm2 restart subway-wechat-server
```

---

## 🆘 故障排查

### 问题 1: Node.js 版本过低

```bash
# 卸载旧版本
sudo apt-get remove nodejs

# 清理
sudo apt-get autoremove

# 重新安装
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 问题 2: PM2 权限错误

```bash
# 使用 sudo 全局安装
sudo npm install -g pm2

# 或者修复 npm 权限
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
npm install -g pm2
```

### 问题 3: 端口占用

```bash
# 查看端口占用
sudo netstat -tulpn | grep 3000

# 或
sudo lsof -i :3000

# 停止占用端口的进程
pm2 stop all
pm2 delete all

# 重新启动
cd /var/www/subway-server/server
pm2 start ecosystem.config.js --env production
```

### 问题 4: Git 克隆失败

```bash
# 检查网络
ping github.com

# 使用 HTTPS 克隆
git clone https://github.com/gukazma/SubwayWechatApp.git

# 如果仍然失败，手动下载
wget https://github.com/gukazma/SubwayWechatApp/archive/refs/heads/master.zip
unzip master.zip
mv SubwayWechatApp-master subway-server
```

### 问题 5: 防火墙阻止连接

```bash
# 检查防火墙状态
sudo ufw status

# 允许端口
sudo ufw allow 3000/tcp

# 如果需要临时关闭防火墙测试
sudo ufw disable

# 记得重新启用
sudo ufw enable
```

### 问题 6: 服务无法启动

```bash
# 查看详细错误日志
pm2 logs subway-wechat-server --err

# 手动启动测试
cd /var/www/subway-server/server
node index.js

# 检查环境配置
cat .env.production

# 检查依赖
npm list --depth=0
```

---

## 🎯 下一步

服务器配置完成后：

1. ✅ 返回配置 [GitHub Secrets](SECRETS_SETUP.md)
2. ✅ [测试自动部署](TEST_DEPLOYMENT.md)
3. ✅ 配置域名和 HTTPS（可选）

---

## 📚 相关文档

- [SERVER_SETUP.md](SERVER_SETUP.md) - 通用服务器配置指南
- [WINDOWS_SSH_SETUP.md](WINDOWS_SSH_SETUP.md) - Windows SSH 配置
- [TEST_DEPLOYMENT.md](TEST_DEPLOYMENT.md) - 部署测试

---

**脚本已修复行尾问题，现在可以直接在 Ubuntu 上运行！** 🚀

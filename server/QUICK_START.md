# 快速部署指南

## 5分钟快速部署到生产服务器

### 前置条件

- 一台 Linux 服务器（Ubuntu/CentOS）
- 已安装 Node.js 18+
- 已安装 Git
- 服务器可通过 SSH 访问

---

## 步骤 1: 服务器准备

```bash
# 安装 Node.js (如果未安装)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装 PM2
sudo npm install -g pm2

# 创建部署目录
sudo mkdir -p /var/www/subway-server
sudo chown $USER:$USER /var/www/subway-server
```

---

## 步骤 2: 部署代码

```bash
# 方式一：从 Git 克隆
cd /var/www
git clone your-repo-url subway-server
cd subway-server/server

# 方式二：从本地上传
# 在本地执行：
scp -r server/* your-user@your-server:/var/www/subway-server/
```

---

## 步骤 3: 配置环境

```bash
cd /var/www/subway-server

# 创建生产环境配置
cat > .env.production << EOF
NODE_ENV=production
PORT=3000
HOST=0.0.0.0
CORS_ORIGIN=*
LOG_LEVEL=info
EOF

# 安装依赖
npm install --production
```

---

## 步骤 4: 启动服务

```bash
# 使用 PM2 启动
pm2 start index.js --name subway-wechat-server --env production

# 保存 PM2 配置
pm2 save

# 设置开机自启
pm2 startup
# 按照提示执行返回的命令
```

---

## 步骤 5: 验证部署

```bash
# 检查服务状态
pm2 status

# 查看日志
pm2 logs subway-wechat-server

# 测试 API
curl http://localhost:3000/api/test
```

---

## 步骤 6: 配置防火墙

```bash
# Ubuntu/Debian
sudo ufw allow 3000/tcp
sudo ufw reload

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --reload
```

---

## 步骤 7: 前端配置

修改前端 `src/config/env.js`：

```javascript
production: {
  baseURL: 'http://your-server-ip:3000/api'  // 改为你的服务器IP
}
```

---

## 常用命令

```bash
# 重启服务
pm2 restart subway-wechat-server

# 停止服务
pm2 stop subway-wechat-server

# 查看日志
pm2 logs subway-wechat-server

# 查看监控
pm2 monit

# 删除服务
pm2 delete subway-wechat-server
```

---

## 更新代码

```bash
cd /var/www/subway-server
git pull origin main
npm install --production
pm2 restart subway-wechat-server
```

---

## 故障排查

### 服务无法启动

```bash
# 查看详细错误
pm2 logs subway-wechat-server --err

# 检查端口占用
netstat -tulpn | grep 3000

# 手动测试启动
node index.js
```

### 无法访问 API

1. 检查防火墙是否开放端口
2. 检查服务是否运行: `pm2 status`
3. 检查 CORS 配置
4. 查看日志: `pm2 logs`

---

## 完成！🎉

现在你的后端服务已经部署成功！

访问测试：`http://your-server-ip:3000/api/test`

下一步：
- 配置域名和 HTTPS（参考 [DEPLOYMENT.md](../DEPLOYMENT.md)）
- 设置数据库连接
- 配置微信小程序合法域名

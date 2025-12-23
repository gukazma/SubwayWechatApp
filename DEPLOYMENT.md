# 部署文档

本文档详细说明如何将地铁微信小程序后端部署到生产环境，以及如何区分开发和生产环境。

## 目录

- [环境配置](#环境配置)
- [部署方式](#部署方式)
  - [方式一：使用 PM2 部署](#方式一使用-pm2-部署)
  - [方式二：使用 Docker 部署](#方式二使用-docker-部署)
  - [方式三：使用 GitHub Actions 自动部署](#方式三使用-github-actions-自动部署)
- [环境变量配置](#环境变量配置)
- [前端环境切换](#前端环境切换)
- [常见问题](#常见问题)

---

## 环境配置

### 开发环境 vs 生产环境

项目支持两种环境：

| 环境 | 说明 | 配置文件 |
|------|------|---------|
| development | 本地开发 | `.env.development` |
| production | 生产部署 | `.env.production` |

### 环境变量说明

在 `server/` 目录下创建对应的环境配置文件：

**开发环境** (`.env.development`)
```env
NODE_ENV=development
PORT=3000
HOST=localhost
CORS_ORIGIN=*
```

**生产环境** (`.env.production`)
```env
NODE_ENV=production
PORT=3000
HOST=0.0.0.0
CORS_ORIGIN=https://your-domain.com
DB_HOST=your-production-db
DB_PASSWORD=your-secure-password
```

---

## 部署方式

### 方式一：使用 PM2 部署

PM2 是 Node.js 的进程管理器，适合生产环境使用。

#### 1. 安装 PM2

```bash
npm install -g pm2
```

#### 2. 配置 PM2

编辑 `server/ecosystem.config.js`，修改部署配置：

```javascript
deploy: {
  production: {
    user: 'your-username',          // 服务器用户名
    host: 'your-server-ip',         // 服务器IP
    repo: 'git@github.com:...',     // Git仓库地址
    path: '/var/www/subway-server'  // 部署路径
  }
}
```

#### 3. 初始化部署

在服务器上首次部署：

```bash
cd server
pm2 deploy ecosystem.config.js production setup
pm2 deploy ecosystem.config.js production
```

#### 4. 本地快速部署

```bash
cd server

# 开发模式
npm run dev

# 生产模式
npm run prod

# 使用 PM2 启动
npm run pm2:start

# 重启服务
npm run pm2:restart

# 停止服务
npm run pm2:stop
```

#### 5. 查看日志

```bash
pm2 logs subway-wechat-server
pm2 status
pm2 monit
```

---

### 方式二：使用 Docker 部署

Docker 提供了容器化部署方案，环境隔离更好。

#### 1. 构建镜像

```bash
cd server
docker build -t subway-wechat-server:latest .
```

#### 2. 使用 Docker Compose 部署

编辑 `server/docker-compose.yml`，确保配置正确。

启动服务：

```bash
docker-compose up -d
```

查看日志：

```bash
docker-compose logs -f
```

停止服务：

```bash
docker-compose down
```

#### 3. 部署到远程服务器

```bash
# 构建并推送镜像
docker build -t your-registry/subway-server:latest .
docker push your-registry/subway-server:latest

# 在服务器上拉取并运行
ssh your-server
docker pull your-registry/subway-server:latest
docker-compose up -d
```

---

### 方式三：使用 GitHub Actions 自动部署

实现 Git push 后自动部署到服务器。

#### 1. 配置 GitHub Secrets

在 GitHub 仓库的 Settings > Secrets and variables > Actions 中添加：

| Secret 名称 | 说明 |
|------------|------|
| `SERVER_HOST` | 服务器IP地址 |
| `SERVER_USER` | 服务器用户名 |
| `SSH_PRIVATE_KEY` | SSH 私钥 |

#### 2. 配置服务器

在服务器上：

```bash
# 克隆仓库
cd /var/www
git clone your-repo subway-server
cd subway-server/server

# 安装依赖
npm install --production

# 配置环境变量
cp .env.example .env.production
vi .env.production  # 编辑配置

# 启动服务
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup  # 设置开机自启
```

#### 3. 触发部署

```bash
git add .
git commit -m "Update code"
git push origin main  # 推送到 main 分支自动触发部署
```

---

### 使用部署脚本

项目提供了两个部署脚本：

#### 完整版部署脚本

```bash
cd server
chmod +x deploy.sh
./deploy.sh
```

提供交互式菜单，支持：
- 常规部署 (PM2)
- Docker 部署
- 仅构建前端
- 查看服务状态
- 回滚部署

#### 简化版部署脚本

```bash
cd server
chmod +x deploy-simple.sh

# 修改脚本中的服务器配置
vi deploy-simple.sh

# 执行一键部署
./deploy-simple.sh
```

---

## 前端环境切换

### 1. 环境配置文件

前端配置位于 `src/config/env.js`：

```javascript
const ENV_CONFIG = {
  development: {
    baseURL: 'http://localhost:3000/api',
    apiTimeout: 10000
  },
  production: {
    baseURL: 'https://your-api-domain.com/api',
    apiTimeout: 30000
  }
}
```

### 2. 使用 API 封装

修改页面代码，使用封装的 API 请求：

```javascript
// 旧方式（直接使用 uni.request）
import { testConnection, getSubwayLines } from '@/api/subway.js'

// 新方式（使用封装的 API）
export default {
  methods: {
    async testConnection() {
      try {
        const res = await testConnection()
        console.log('连接成功:', res)
      } catch (err) {
        console.error('连接失败:', err)
      }
    },

    async getSubwayLines() {
      try {
        const res = await getSubwayLines()
        this.subwayLines = res.data
      } catch (err) {
        console.error('获取失败:', err)
      }
    }
  }
}
```

### 3. 微信小程序域名配置

生产环境需要在微信公众平台配置合法域名：

1. 登录[微信公众平台](https://mp.weixin.qq.com/)
2. 进入"开发 > 开发管理 > 开发设置"
3. 在"服务器域名"中添加：
   - **request 合法域名**: `https://your-api-domain.com`
4. 保存配置

---

## 常见问题

### 1. 如何查看部署日志？

**PM2:**
```bash
pm2 logs subway-wechat-server
pm2 logs subway-wechat-server --lines 100
```

**Docker:**
```bash
docker-compose logs -f
docker logs subway-wechat-server
```

### 2. 部署后连接失败怎么办？

检查清单：
- [ ] 服务器防火墙是否开放 3000 端口
- [ ] 环境变量配置是否正确
- [ ] CORS 配置是否允许前端域名
- [ ] 服务是否正常运行 (`pm2 status` 或 `docker ps`)

```bash
# 检查端口占用
netstat -tulpn | grep 3000

# 检查服务状态
pm2 status
# 或
curl http://localhost:3000/api/test
```

### 3. 如何开放服务器端口？

**Ubuntu/Debian (使用 ufw):**
```bash
sudo ufw allow 3000/tcp
sudo ufw reload
```

**CentOS/RHEL (使用 firewalld):**
```bash
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --reload
```

### 4. 如何回滚到上一个版本？

**PM2:**
```bash
cd /var/www/subway-server
git log --oneline  # 查看提交历史
git checkout <commit-hash>
npm install --production
pm2 restart subway-wechat-server
```

**Docker:**
```bash
docker pull your-registry/subway-server:previous-tag
docker-compose down
docker-compose up -d
```

### 5. 如何配置 HTTPS？

使用 Nginx 反向代理：

```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 6. 如何监控服务健康状态？

使用 PM2 内置监控：

```bash
pm2 install pm2-server-monit
pm2 monit
```

或使用第三方服务如：
- UptimeRobot
- Pingdom
- New Relic

---

## 生产环境检查清单

部署前请确认：

- [ ] 已配置 `.env.production` 文件
- [ ] 数据库连接信息正确
- [ ] CORS 配置为具体域名（不使用 `*`）
- [ ] 已配置 HTTPS 证书
- [ ] 服务器防火墙已开放必要端口
- [ ] 已设置 PM2 开机自启或 Docker 自动重启
- [ ] 微信小程序已配置合法域名
- [ ] 已配置日志收集
- [ ] 已设置定期备份

---

## 技术支持

如有问题，请查看：
- [主 README](README.md)
- [GitHub Issues](https://github.com/your-repo/issues)

---

**祝部署顺利！** 🚀

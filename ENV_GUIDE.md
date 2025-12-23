# 环境管理与自动化部署完整方案

本项目已配置完整的开发/生产环境区分和自动化部署方案。

## 📁 项目结构

```
SubwayWechatApp/
├── server/                          # 后端服务
│   ├── index.js                     # 后端主文件（已支持环境变量）
│   ├── package.json                 # 后端依赖（已添加部署脚本）
│   ├── .env.development             # 开发环境配置
│   ├── .env.production              # 生产环境配置
│   ├── .env.example                 # 环境配置示例
│   ├── .gitignore                   # Git 忽略文件
│   ├── Dockerfile                   # Docker 镜像配置
│   ├── .dockerignore                # Docker 忽略文件
│   ├── docker-compose.yml           # Docker Compose 配置
│   ├── ecosystem.config.js          # PM2 配置文件
│   ├── deploy.sh                    # 完整部署脚本
│   ├── deploy-simple.sh             # 简化部署脚本
│   └── QUICK_START.md               # 快速部署指南
│
├── src/                             # 前端源码
│   ├── config/
│   │   └── env.js                   # 前端环境配置
│   ├── utils/
│   │   └── request.js               # API 请求封装
│   ├── api/
│   │   └── subway.js                # 地铁 API 模块
│   └── pages/
│       └── index/index.vue          # 主页面
│
├── .github/
│   └── workflows/
│       └── deploy.yml               # GitHub Actions CI/CD
│
├── README.md                        # 项目说明
└── DEPLOYMENT.md                    # 详细部署文档
```

---

## 🔧 环境配置说明

### 后端环境变量

| 文件 | 用途 | 说明 |
|-----|------|-----|
| `.env.development` | 开发环境 | 本地开发使用 |
| `.env.production` | 生产环境 | 服务器部署使用 |
| `.env.example` | 配置模板 | 提交到 Git，供参考 |

**关键配置项：**
- `NODE_ENV`: 环境标识 (development/production)
- `PORT`: 服务端口
- `HOST`: 监听地址 (localhost/0.0.0.0)
- `CORS_ORIGIN`: 跨域配置

### 前端环境配置

位于 `src/config/env.js`：

```javascript
const ENV_CONFIG = {
  development: {
    baseURL: 'http://localhost:3000/api',  // 开发环境 API 地址
  },
  production: {
    baseURL: 'https://your-domain.com/api',  // 生产环境 API 地址
  }
}
```

---

## 🚀 部署方式对比

| 方式 | 优点 | 缺点 | 适用场景 |
|-----|------|------|---------|
| **PM2** | 简单、轻量、日志管理好 | 需要手动配置 | 中小型项目 |
| **Docker** | 环境隔离、一致性好 | 学习成本高 | 容器化部署 |
| **GitHub Actions** | 自动化、无需手动操作 | 依赖 GitHub | 持续集成 |
| **手动部署** | 灵活、可控 | 容易出错 | 测试环境 |

---

## 📝 使用指南

### 本地开发

```bash
# 后端
cd server
npm install
npm run dev              # 使用开发环境配置

# 前端
npm run dev:mp-weixin    # 编译微信小程序
```

### 生产部署

#### 方式 1: 使用 PM2（推荐）

```bash
# 1. 上传代码到服务器
cd server
scp -r * user@server:/var/www/subway-server/

# 2. SSH 到服务器
ssh user@server

# 3. 部署
cd /var/www/subway-server
npm install --production
pm2 start ecosystem.config.js --env production
pm2 save
```

#### 方式 2: 使用 Docker

```bash
# 1. 构建镜像
cd server
docker build -t subway-server .

# 2. 启动容器
docker-compose up -d
```

#### 方式 3: 一键部署脚本

```bash
cd server
chmod +x deploy-simple.sh

# 修改脚本中的服务器配置
vi deploy-simple.sh

# 执行部署
./deploy-simple.sh
```

#### 方式 4: GitHub Actions 自动部署

1. 在 GitHub 仓库配置 Secrets
2. 推送代码到 main 分支
3. 自动触发部署

```bash
git push origin main  # 自动部署
```

---

## 🎯 环境切换

### 后端环境切换

```bash
# 开发环境
npm run dev

# 生产环境
npm run prod

# 使用 PM2
pm2 start ecosystem.config.js --env development  # 开发
pm2 start ecosystem.config.js --env production   # 生产
```

### 前端环境切换

前端根据 `src/config/env.js` 中的逻辑自动切换：

- 本地开发（localhost）→ 使用开发环境配置
- 生产域名 → 使用生产环境配置

也可以手动修改：

```javascript
// src/config/env.js
const getCurrentEnv = () => {
  return 'development'  // 或 'production'
}
```

---

## 📊 部署检查清单

### 后端部署前

- [ ] 已创建 `.env.production` 文件
- [ ] 已配置正确的数据库连接（如果有）
- [ ] 已修改 CORS_ORIGIN 为具体域名
- [ ] 已测试 API 接口正常工作

### 服务器配置

- [ ] 已安装 Node.js 18+
- [ ] 已安装 PM2 或 Docker
- [ ] 已开放防火墙端口（3000）
- [ ] 已配置 HTTPS（推荐使用 Nginx）

### 前端配置

- [ ] 已修改 `src/config/env.js` 中的生产环境 API 地址
- [ ] 微信小程序已配置合法域名
- [ ] 已测试前后端连接

---

## 🔍 常用命令速查

### 后端开发

```bash
npm run dev              # 开发模式
npm run prod             # 生产模式
npm run pm2:start        # PM2 启动
npm run pm2:restart      # PM2 重启
npm run pm2:stop         # PM2 停止
```

### Docker

```bash
docker-compose up -d     # 启动
docker-compose down      # 停止
docker-compose logs -f   # 查看日志
docker-compose restart   # 重启
```

### PM2

```bash
pm2 status               # 查看状态
pm2 logs                 # 查看日志
pm2 monit                # 实时监控
pm2 restart <name>       # 重启服务
pm2 stop <name>          # 停止服务
```

---

## 📚 相关文档

- [README.md](../README.md) - 项目介绍和基础使用
- [DEPLOYMENT.md](../DEPLOYMENT.md) - 详细部署文档
- [server/QUICK_START.md](../server/QUICK_START.md) - 5分钟快速部署

---

## 🆘 故障排查

### 问题：服务启动失败

```bash
# 查看详细日志
pm2 logs subway-wechat-server --err

# 检查环境变量
cat .env.production

# 手动启动测试
NODE_ENV=production node index.js
```

### 问题：前端连接后端失败

1. 检查后端是否正常运行
2. 检查防火墙端口是否开放
3. 检查 CORS 配置
4. 检查前端 API 地址配置

### 问题：Docker 容器无法启动

```bash
# 查看容器日志
docker-compose logs

# 检查端口占用
netstat -tulpn | grep 3000

# 重新构建
docker-compose build --no-cache
docker-compose up -d
```

---

## ✅ 最佳实践

1. **环境隔离**: 开发和生产环境严格分离
2. **配置管理**: 敏感信息使用环境变量，不提交到 Git
3. **自动化部署**: 使用 CI/CD 减少人为错误
4. **日志监控**: 配置日志收集和告警
5. **备份策略**: 定期备份数据和配置
6. **版本管理**: 使用 Git 标签管理版本
7. **文档维护**: 及时更新部署文档

---

**所有配置已完成，可以开始部署！** 🎉

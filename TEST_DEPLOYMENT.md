# 🧪 部署测试指南

完成 GitHub Secrets 和服务器环境配置后，进行部署测试。

---

## 📋 测试前检查

确保以下配置已完成:

### GitHub Secrets
- [ ] SERVER_HOST 已配置
- [ ] SERVER_USER 已配置
- [ ] SSH_PRIVATE_KEY 已配置

验证方法: 访问 https://github.com/gukazma/SubwayWechatApp/settings/secrets/actions

### 服务器环境
- [ ] Node.js 18+ 已安装
- [ ] PM2 已安装
- [ ] Git 已安装
- [ ] 代码已克隆到 `/var/www/subway-server`
- [ ] 服务正在运行 (`pm2 status` 显示 online)
- [ ] API 测试通过 (`curl http://localhost:3000/api/test`)

### SSH 连接
- [ ] 公钥已添加到服务器 `~/.ssh/authorized_keys`
- [ ] 本地可以使用私钥连接: `ssh -i ~/.ssh/github_deploy user@server`

---

## 方式 1: 手动触发部署（推荐首次测试）

### 步骤 1: 打开 Actions 页面

访问: https://github.com/gukazma/SubwayWechatApp/actions

### 步骤 2: 选择工作流

点击左侧 **"Deploy to Production"**

### 步骤 3: 手动触发

1. 点击右侧 **"Run workflow"** 按钮
2. 在弹出框中选择分支: **master**
3. 点击绿色的 **"Run workflow"** 按钮

### 步骤 4: 观察部署过程

部署会自动开始，您会看到一个新的 workflow 运行。

点击进入查看详细步骤:

1. 📥 Checkout code
2. 🔧 Setup Node.js
3. 📦 Install dependencies
4. ✅ Run tests
5. 🚀 Deploy to server via SSH
6. 🔍 Health check
7. 📢 Notification

### 步骤 5: 查看日志

点击每个步骤可以展开查看详细日志。

**预计时间**: 2-3 分钟

---

## 方式 2: 自动触发部署

### 步骤 1: 修改代码

修改后端任意文件:

```bash
cd server
echo "// Test auto deployment - $(date)" >> index.js
```

### 步骤 2: 提交并推送

```bash
git add server/index.js
git commit -m "test: Trigger auto deployment"
git push github master
```

### 步骤 3: 观察自动触发

几秒钟后，访问 https://github.com/gukazma/SubwayWechatApp/actions

您应该看到一个新的 workflow 自动运行。

---

## 验证部署结果

### 1. 检查 GitHub Actions 状态

访问: https://github.com/gukazma/SubwayWechatApp/actions

✅ **成功**: 显示绿色的 ✓ 标记
❌ **失败**: 显示红色的 ✗ 标记（查看日志排查问题）

### 2. 在服务器验证

SSH 连接到服务器:

```bash
ssh your-username@your-server-ip
```

执行以下命令:

```bash
# 查看服务状态
pm2 status

# 查看最新日志
pm2 logs subway-wechat-server --lines 50

# 查看部署时间
cd /var/www/subway-server
git log -1

# 测试 API
curl http://localhost:3000/api/test
```

### 3. 从外网访问

在浏览器中访问:

```
http://your-server-ip:3000/api/test
```

应该看到:

```json
{
  "code": 200,
  "message": "Server is running!",
  "data": {
    "timestamp": "2025-12-23T...",
    "version": "1.0.0",
    "environment": "production"
  }
}
```

### 4. 检查备份（可选）

```bash
# 查看备份文件
ls -lh /var/www/subway-server/backups/
```

每次部署都会自动创建备份。

---

## 部署成功标志

✅ 所有步骤都显示绿色 ✓
✅ Health check 通过
✅ 服务器上 `pm2 status` 显示 online
✅ API 可以正常访问
✅ 日志没有错误信息

---

## 常见问题排查

### 问题 1: SSH 连接失败

**错误信息**:
```
Failed to connect to server
```

**解决方法**:

1. 检查 SERVER_HOST 是否正确
2. 检查 SERVER_USER 是否正确
3. 检查 SSH_PRIVATE_KEY 是否完整
4. 在本地测试 SSH 连接:
   ```bash
   ssh -i ~/.ssh/github_deploy your-user@your-server
   ```
5. 确保服务器防火墙允许 SSH 连接

### 问题 2: Git pull 失败

**错误信息**:
```
fatal: could not read Username
```

**解决方法**:

在服务器上重新克隆或配置 Git:

```bash
cd /var/www
sudo rm -rf subway-server
git clone https://github.com/gukazma/SubwayWechatApp.git subway-server
```

### 问题 3: PM2 未找到

**错误信息**:
```
PM2 not found!
```

**解决方法**:

在服务器上安装 PM2:

```bash
sudo npm install -g pm2
pm2 --version
```

### 问题 4: 端口占用

**错误信息**:
```
Error: listen EADDRINUSE: address already in use :::3000
```

**解决方法**:

```bash
# 停止所有 PM2 进程
pm2 stop all
pm2 delete all

# 重新启动
cd /var/www/subway-server/server
pm2 start ecosystem.config.js --env production
pm2 save
```

### 问题 5: 权限错误

**错误信息**:
```
Permission denied
```

**解决方法**:

```bash
# 修改目录所有者
sudo chown -R $USER:$USER /var/www/subway-server

# 或者使用 sudo 用户部署
# 修改 GitHub Secrets 中的 SERVER_USER 为 root
```

### 问题 6: Health check 失败

**警告信息**:
```
⚠️ Health check returned status code: 000
```

**解决方法**:

1. 检查服务是否正常启动:
   ```bash
   pm2 status
   pm2 logs subway-wechat-server
   ```

2. 手动测试 API:
   ```bash
   curl http://localhost:3000/api/test
   ```

3. 检查防火墙是否阻止了访问

4. 等待几秒后再次访问

---

## 查看详细日志

### GitHub Actions 日志

1. 打开: https://github.com/gukazma/SubwayWechatApp/actions
2. 点击最新的 workflow 运行
3. 点击 "deploy" 作业
4. 展开各个步骤查看详细输出

### 服务器日志

```bash
# 实时查看日志
pm2 logs subway-wechat-server

# 查看最近 100 行
pm2 logs subway-wechat-server --lines 100

# 只查看错误日志
pm2 logs subway-wechat-server --err

# 查看日志文件
cat /var/www/subway-server/server/logs/combined.log
```

---

## 回滚部署（如果需要）

如果部署出现问题，可以回滚到上一个版本:

```bash
# SSH 连接到服务器
ssh your-username@your-server-ip

# 回滚代码
cd /var/www/subway-server
git log --oneline  # 查看提交历史
git checkout <previous-commit-hash>

# 重启服务
cd server
npm install --production
pm2 restart subway-wechat-server
```

---

## 测试完整工作流

### 场景 1: 修改 API 响应

```bash
# 1. 修改代码
cd server
vi index.js

# 在 /api/test 接口中添加新字段
# 例如: server: 'Subway WeChat Server'

# 2. 提交推送
git add index.js
git commit -m "test: Update API response"
git push github master

# 3. 观察自动部署
# 访问 https://github.com/gukazma/SubwayWechatApp/actions

# 4. 验证更新
curl http://your-server-ip:3000/api/test
```

### 场景 2: 添加新的 API 接口

```bash
# 1. 添加新接口
# 在 server/index.js 中添加:
# app.get('/api/hello', (req, res) => {
#   res.json({ message: 'Hello from auto deployment!' })
# })

# 2. 提交推送
git add server/index.js
git commit -m "feat: Add /api/hello endpoint"
git push github master

# 3. 等待部署完成

# 4. 测试新接口
curl http://your-server-ip:3000/api/hello
```

---

## 成功！🎉

如果您看到:

✅ GitHub Actions 显示绿色对勾
✅ 服务器服务正常运行
✅ API 可以正常访问
✅ 代码修改已生效

**恭喜！您已成功配置 GitHub Actions 自动化部署！**

---

## 下一步

现在您可以:

1. **配置域名和 HTTPS**: 使用 Nginx 反向代理
2. **添加数据库**: MySQL、MongoDB 等
3. **配置监控**: 使用 PM2 Plus、New Relic 等
4. **优化性能**: 添加缓存、负载均衡
5. **完善前端**: 修改前端 API 地址连接生产环境

---

## 日常使用流程

```
1. 本地开发 → git commit
2. git push github master
3. GitHub Actions 自动部署
4. 验证部署结果
5. ✅ 完成
```

**就是这么简单！** 🚀

---

## 相关文档

- [GitHub Actions 详细指南](GITHUB_ACTIONS_GUIDE.md)
- [快速配置清单](QUICK_SETUP.md)
- [故障排查](GITHUB_ACTIONS_GUIDE.md#故障排查)
- [环境管理](ENV_GUIDE.md)

---

**祝您使用愉快！** 如有问题，请查看文档或提交 Issue。

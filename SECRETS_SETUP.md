# 🔑 GitHub Secrets 配置指南

## SSH 密钥信息

### 📋 公钥（需要添加到服务器）

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEtOGY9r/sACV21CqpH2lrfUiHqGPIjkiqYVUBHSK2tr github-actions-deploy
```

### 🔐 私钥（需要添加到 GitHub Secrets）

```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBLThmPa/7AAldtQqqR9pa31Ih6hjyI5IqmFVAR0itrawAAAJhs8KmqbPCp
qgAAAAtzc2gtZWQyNTUxOQAAACBLThmPa/7AAldtQqqR9pa31Ih6hjyI5IqmFVAR0itraw
AAAEDYov3GAsZq+yA+MQjtyHnBzGgdJv8KdR1shPa0TBfgWEtOGY9r/sACV21CqpH2lrfU
iHqGPIjkiqYVUBHSK2trAAAAFWdpdGh1Yi1hY3Rpb25zLWRlcGxveQ==
-----END OPENSSH PRIVATE KEY-----
```

---

## 📝 配置步骤

### 步骤 1: 配置 GitHub Secrets

1. **打开 GitHub 仓库设置**

   访问: https://github.com/gukazma/SubwayWechatApp/settings/secrets/actions

2. **点击 "New repository secret"**

3. **添加以下 3 个 Secrets**:

#### ① SERVER_HOST
- **Name**: `SERVER_HOST`
- **Value**: `您的服务器IP地址`（例如：`123.45.67.89`）

#### ② SERVER_USER
- **Name**: `SERVER_USER`
- **Value**: `您的SSH用户名`（例如：`root` 或 `ubuntu`）

#### ③ SSH_PRIVATE_KEY
- **Name**: `SSH_PRIVATE_KEY`
- **Value**: 复制上面的完整私钥内容（从 `-----BEGIN` 到 `-----END`）

---

### 步骤 2: 将公钥添加到服务器

**方式 1: 自动添加（推荐）**

在本地执行以下命令（需要先能用密码 SSH 登录服务器）:

```bash
# 替换为您的服务器信息
ssh-copy-id -i ~/.ssh/github_deploy.pub your-username@your-server-ip
```

**方式 2: 手动添加**

如果自动添加失败，手动操作：

1. SSH 连接到服务器:
```bash
ssh your-username@your-server-ip
```

2. 在服务器上执行:
```bash
# 创建 .ssh 目录（如果不存在）
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 添加公钥
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEtOGY9r/sACV21CqpH2lrfUiHqGPIjkiqYVUBHSK2tr github-actions-deploy" >> ~/.ssh/authorized_keys

# 设置权限
chmod 600 ~/.ssh/authorized_keys
```

---

### 步骤 3: 测试 SSH 连接

在本地测试是否可以使用新密钥连接服务器:

```bash
ssh -i ~/.ssh/github_deploy your-username@your-server-ip
```

如果能成功连接，说明配置正确！

---

## ✅ 配置完成检查清单

配置完成后，请确认：

- [ ] GitHub Secrets 中有 3 个配置：SERVER_HOST, SERVER_USER, SSH_PRIVATE_KEY
- [ ] 公钥已添加到服务器的 ~/.ssh/authorized_keys
- [ ] 本地可以使用私钥 SSH 连接到服务器
- [ ] 服务器 ~/.ssh/authorized_keys 文件权限为 600

---

## 📱 需要的服务器信息

请准备以下信息用于配置：

| 项目 | 说明 | 您的值 |
|------|------|--------|
| 服务器 IP | 公网 IP 地址 | _____________ |
| SSH 用户名 | 登录用户名 | _____________ |
| SSH 端口 | 默认 22 | 22 |
| SSH 密码 | 首次配置需要 | _____________ |

---

## 🆘 常见问题

### Q: 如何获取服务器 IP？
A:
- 在服务器上执行: `curl ifconfig.me`
- 或登录云服务商控制台查看

### Q: SSH 用户名是什么？
A:
- 通常是 `root`、`ubuntu`、`admin` 等
- 看您平时如何登录服务器

### Q: ssh-copy-id 命令失败？
A:
- 使用方式 2 手动添加公钥
- 确保服务器允许密码登录（临时开启）

### Q: GitHub Secrets 在哪里配置？
A:
- 仓库页面 → Settings → Secrets and variables → Actions
- 或直接访问: https://github.com/gukazma/SubwayWechatApp/settings/secrets/actions

---

**下一步**: 完成 GitHub Secrets 配置后，继续[服务器环境准备](SERVER_SETUP.md)

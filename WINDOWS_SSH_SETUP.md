# 🪟 Windows 系统 - SSH 公钥配置指南

由于 Windows 系统没有 `ssh-copy-id` 命令，需要使用其他方式添加公钥到服务器。

---

## 方式 1: 使用 PowerShell（推荐）⭐

在本地 Windows PowerShell 中执行：

```powershell
# 读取公钥内容
$pubKey = Get-Content ~/.ssh/github_deploy.pub

# 通过 SSH 添加到服务器
# 替换 your-username 和 your-server-ip
ssh your-username@your-server-ip "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '$pubKey' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

**一行命令完成！**

---

## 方式 2: 手动复制（最简单）

### 步骤 1: 查看公钥内容

在本地执行：

```bash
cat ~/.ssh/github_deploy.pub
```

复制完整输出，例如：
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEtOGY9r/sACV21CqpH2lrfUiHqGPIjkiqYVUBHSK2tr github-actions-deploy
```

### 步骤 2: SSH 连接到服务器

```bash
ssh your-username@your-server-ip
```

### 步骤 3: 在服务器上添加公钥

在服务器上执行：

```bash
# 创建 .ssh 目录（如果不存在）
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 添加公钥（将下面的内容替换为您复制的公钥）
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEtOGY9r/sACV21CqpH2lrfUiHqGPIjkiqYVUBHSK2tr github-actions-deploy" >> ~/.ssh/authorized_keys

# 设置正确的权限
chmod 600 ~/.ssh/authorized_keys
```

---

## 方式 3: 使用 SCP 上传

### 步骤 1: 上传公钥文件到服务器

在本地执行：

```bash
scp ~/.ssh/github_deploy.pub your-username@your-server-ip:~/
```

### 步骤 2: SSH 连接到服务器

```bash
ssh your-username@your-server-ip
```

### 步骤 3: 添加公钥

在服务器上执行：

```bash
# 创建 .ssh 目录
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 将公钥添加到 authorized_keys
cat ~/github_deploy.pub >> ~/.ssh/authorized_keys

# 设置权限
chmod 600 ~/.ssh/authorized_keys

# 删除临时文件
rm ~/github_deploy.pub
```

---

## 方式 4: 使用 Git Bash（如果已安装 Git）

如果您安装了 Git for Windows，可以使用 Git Bash：

```bash
# 在 Git Bash 中执行
cat ~/.ssh/github_deploy.pub | ssh your-username@your-server-ip "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

---

## 验证配置

### 测试 SSH 连接

在本地执行：

```bash
# 使用新密钥测试连接
ssh -i ~/.ssh/github_deploy your-username@your-server-ip
```

如果能成功连接（不需要输入密码），说明配置成功！✅

---

## 🚨 常见问题

### 问题 1: 权限错误

**错误信息**：
```
Permission denied (publickey)
```

**解决方法**：

在服务器上检查并设置正确的权限：

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# 检查文件所有者
ls -la ~/.ssh/
```

确保 `.ssh` 目录和 `authorized_keys` 文件的所有者是当前用户。

### 问题 2: 公钥添加后仍需要密码

**可能原因**：
1. 权限不正确
2. SELinux 问题（CentOS/RHEL）
3. SSH 配置不允许公钥认证

**解决方法**：

```bash
# 1. 检查权限
ls -la ~/.ssh/

# 2. 如果是 CentOS/RHEL，运行：
restorecon -R ~/.ssh

# 3. 检查 SSH 服务器配置
sudo grep -i "PubkeyAuthentication" /etc/ssh/sshd_config
# 应该是: PubkeyAuthentication yes

# 如果修改了配置，重启 SSH 服务
sudo systemctl restart sshd
```

### 问题 3: Windows 路径问题

如果 `~/.ssh/github_deploy.pub` 找不到，使用完整路径：

```bash
# 查看公钥
cat C:/Users/你的用户名/.ssh/github_deploy.pub

# 或者在 PowerShell 中
Get-Content $env:USERPROFILE\.ssh\github_deploy.pub
```

---

## 📋 配置检查清单

完成后请验证：

- [ ] 公钥文件存在：`~/.ssh/github_deploy.pub`
- [ ] 公钥已添加到服务器：`~/.ssh/authorized_keys`
- [ ] 服务器权限正确：`.ssh` 为 700，`authorized_keys` 为 600
- [ ] 可以使用私钥 SSH 连接（不需要密码）
- [ ] 测试命令成功：`ssh -i ~/.ssh/github_deploy your-user@your-server`

---

## 🎯 快速配置命令（复制即用）

### PowerShell 一键配置

```powershell
# 替换下面的用户名和服务器 IP
$SERVER_USER = "your-username"
$SERVER_IP = "your-server-ip"

# 执行配置
$pubKey = Get-Content ~/.ssh/github_deploy.pub
ssh $SERVER_USER@$SERVER_IP "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '$pubKey' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

# 测试连接
ssh -i ~/.ssh/github_deploy $SERVER_USER@$SERVER_IP "echo '✅ SSH 配置成功！'"
```

### Git Bash 一键配置

```bash
# 替换下面的用户名和服务器 IP
SERVER_USER="your-username"
SERVER_IP="your-server-ip"

# 执行配置
cat ~/.ssh/github_deploy.pub | ssh $SERVER_USER@$SERVER_IP "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

# 测试连接
ssh -i ~/.ssh/github_deploy $SERVER_USER@$SERVER_IP "echo '✅ SSH 配置成功！'"
```

---

## 下一步

SSH 公钥配置完成后：

1. ✅ 继续配置 [GitHub Secrets](SECRETS_SETUP.md#步骤-1-配置-github-secrets)
2. ✅ 准备[服务器环境](SERVER_SETUP.md)
3. ✅ [测试部署](TEST_DEPLOYMENT.md)

---

**提示**：推荐使用 PowerShell 方式，最简单快捷！🚀

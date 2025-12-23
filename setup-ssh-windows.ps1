# Windows PowerShell 脚本 - 配置 SSH 公钥到服务器
# 使用方法:
# 1. 右键点击此文件 -> 使用 PowerShell 运行
# 2. 或者在 PowerShell 中执行: .\setup-ssh-windows.ps1

Write-Host "======================================" -ForegroundColor Blue
Write-Host "   SSH 公钥配置脚本 (Windows)" -ForegroundColor Blue
Write-Host "======================================" -ForegroundColor Blue
Write-Host ""

# 获取服务器信息
Write-Host "请输入服务器信息:" -ForegroundColor Yellow
$SERVER_USER = Read-Host "SSH 用户名 (例如: root 或 ubuntu)"
$SERVER_IP = Read-Host "服务器 IP 地址 (例如: 123.45.67.89)"

Write-Host ""
Write-Host "[1/4] 检查 SSH 公钥..." -ForegroundColor Green

# 检查公钥文件是否存在
$pubKeyPath = "$env:USERPROFILE\.ssh\github_deploy.pub"

if (-Not (Test-Path $pubKeyPath)) {
    Write-Host "错误: 找不到公钥文件 $pubKeyPath" -ForegroundColor Red
    Write-Host "请先运行 ssh-keygen 生成密钥对" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ 找到公钥文件" -ForegroundColor Green

# 读取公钥内容
Write-Host ""
Write-Host "[2/4] 读取公钥内容..." -ForegroundColor Green
$pubKey = Get-Content $pubKeyPath
Write-Host "公钥内容:" -ForegroundColor Cyan
Write-Host $pubKey -ForegroundColor Gray

# 添加公钥到服务器
Write-Host ""
Write-Host "[3/4] 将公钥添加到服务器..." -ForegroundColor Green
Write-Host "请输入服务器密码以继续:" -ForegroundColor Yellow

$command = "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '$pubKey' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && echo '✅ 公钥添加成功'"

try {
    ssh "$SERVER_USER@$SERVER_IP" $command

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "======================================" -ForegroundColor Green
        Write-Host "   ✅ 配置成功！" -ForegroundColor Green
        Write-Host "======================================" -ForegroundColor Green
    } else {
        throw "SSH 命令执行失败"
    }
} catch {
    Write-Host ""
    Write-Host "❌ 配置失败: $_" -ForegroundColor Red
    Write-Host "请检查:" -ForegroundColor Yellow
    Write-Host "  1. 服务器 IP 和用户名是否正确" -ForegroundColor Yellow
    Write-Host "  2. 服务器密码是否正确" -ForegroundColor Yellow
    Write-Host "  3. 网络连接是否正常" -ForegroundColor Yellow
    exit 1
}

# 测试 SSH 连接
Write-Host ""
Write-Host "[4/4] 测试 SSH 连接..." -ForegroundColor Green

$privateKeyPath = "$env:USERPROFILE\.ssh\github_deploy"

try {
    $testResult = ssh -i $privateKeyPath "$SERVER_USER@$SERVER_IP" "echo '✅ SSH 连接测试成功'"
    Write-Host $testResult -ForegroundColor Green

    Write-Host ""
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "   🎉 全部完成！" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "下一步:" -ForegroundColor Cyan
    Write-Host "  1. 配置 GitHub Secrets" -ForegroundColor White
    Write-Host "     访问: https://github.com/gukazma/SubwayWechatApp/settings/secrets/actions" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. 配置服务器环境" -ForegroundColor White
    Write-Host "     查看: SERVER_SETUP.md" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. 测试部署" -ForegroundColor White
    Write-Host "     查看: TEST_DEPLOYMENT.md" -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-Host "⚠️  SSH 连接测试失败: $_" -ForegroundColor Yellow
    Write-Host "但公钥已添加到服务器，请手动测试:" -ForegroundColor Yellow
    Write-Host "  ssh -i $privateKeyPath $SERVER_USER@$SERVER_IP" -ForegroundColor Gray
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

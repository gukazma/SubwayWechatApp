# PowerShell 配置验证脚本
# 用于验证 GitHub Actions 自动部署的所有配置

param(
    [string]$ServerIP,
    [string]$ServerUser
)

$ErrorActionPreference = "Continue"

Write-Host @"
======================================
   GitHub Actions 部署配置验证
======================================
"@ -ForegroundColor Blue

Write-Host ""

# 如果没有提供参数，询问用户
if (-not $ServerIP) {
    $ServerIP = Read-Host "请输入服务器 IP 地址"
}

if (-not $ServerUser) {
    $ServerUser = Read-Host "请输入 SSH 用户名"
}

Write-Host ""

# 验证计数
$passCount = 0
$failCount = 0
$totalTests = 6

function Test-Check {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [string]$SuccessMessage,
        [string]$FailMessage
    )

    Write-Host "[验证] $Name..." -ForegroundColor Cyan -NoNewline

    try {
        $result = & $Test
        if ($result) {
            Write-Host " ✅" -ForegroundColor Green
            if ($SuccessMessage) {
                Write-Host "       $SuccessMessage" -ForegroundColor Gray
            }
            $script:passCount++
            return $true
        } else {
            Write-Host " ❌" -ForegroundColor Red
            if ($FailMessage) {
                Write-Host "       $FailMessage" -ForegroundColor Yellow
            }
            $script:failCount++
            return $false
        }
    } catch {
        Write-Host " ❌" -ForegroundColor Red
        Write-Host "       错误: $_" -ForegroundColor Yellow
        $script:failCount++
        return $false
    }
}

Write-Host "=== 1/6 本地 SSH 密钥检查 ===" -ForegroundColor Blue
Write-Host ""

# 检查私钥
Test-Check -Name "私钥文件存在" -Test {
    Test-Path "$env:USERPROFILE\.ssh\github_deploy"
} -SuccessMessage "私钥文件: ~/.ssh/github_deploy" -FailMessage "请先生成 SSH 密钥"

# 检查公钥
Test-Check -Name "公钥文件存在" -Test {
    Test-Path "$env:USERPROFILE\.ssh\github_deploy.pub"
} -SuccessMessage "公钥文件: ~/.ssh/github_deploy.pub" -FailMessage "请先生成 SSH 密钥"

Write-Host ""
Write-Host "=== 2/6 SSH 连接测试 ===" -ForegroundColor Blue
Write-Host ""

# 测试 SSH 连接
$sshTest = Test-Check -Name "SSH 密钥连接" -Test {
    $result = ssh -i "$env:USERPROFILE\.ssh\github_deploy" -o "StrictHostKeyChecking=no" -o "ConnectTimeout=10" "$ServerUser@$ServerIP" "echo 'connected'" 2>$null
    $result -eq "connected"
} -SuccessMessage "可以使用密钥连接到服务器" -FailMessage "无法连接服务器，请检查：`n         1. 公钥是否已添加到服务器`n         2. 服务器 IP 和用户名是否正确`n         3. 服务器防火墙是否开放 22 端口"

Write-Host ""
Write-Host "=== 3/6 GitHub Secrets 检查 ===" -ForegroundColor Blue
Write-Host ""

Write-Host "[提示] GitHub Secrets 需要手动检查" -ForegroundColor Yellow
Write-Host "       访问: https://github.com/gukazma/SubwayWechatApp/settings/secrets/actions" -ForegroundColor Gray
Write-Host ""
$secretsOk = Read-Host "已配置所有 3 个 Secrets (SERVER_HOST, SERVER_USER, SSH_PRIVATE_KEY)? (y/n)"

if ($secretsOk -eq 'y') {
    Write-Host "✅ GitHub Secrets 已配置" -ForegroundColor Green
    $passCount++
} else {
    Write-Host "❌ 请配置 GitHub Secrets" -ForegroundColor Red
    $failCount++
}

Write-Host ""
Write-Host "=== 4/6 服务器环境检查 ===" -ForegroundColor Blue
Write-Host ""

if ($sshTest) {
    # 检查 Node.js
    Test-Check -Name "Node.js 已安装" -Test {
        $version = ssh -i "$env:USERPROFILE\.ssh\github_deploy" "$ServerUser@$ServerIP" "node --version 2>/dev/null"
        $version -match "v\d+"
    } -SuccessMessage "版本: $(ssh -i "$env:USERPROFILE\.ssh\github_deploy" "$ServerUser@$ServerIP" "node --version 2>/dev/null")" -FailMessage "请在服务器上安装 Node.js 18+"

    # 检查 PM2
    Test-Check -Name "PM2 已安装" -Test {
        $version = ssh -i "$env:USERPROFILE\.ssh\github_deploy" "$ServerUser@$ServerIP" "pm2 --version 2>/dev/null"
        $version -match "\d+"
    } -SuccessMessage "版本: $(ssh -i "$env:USERPROFILE\.ssh\github_deploy" "$ServerUser@$ServerIP" "pm2 --version 2>/dev/null")" -FailMessage "请在服务器上安装 PM2"

    # 检查项目目录
    Test-Check -Name "项目目录存在" -Test {
        $result = ssh -i "$env:USERPROFILE\.ssh\github_deploy" "$ServerUser@$ServerIP" "[ -d /var/www/subway-server ] && echo 'exists'"
        $result -eq "exists"
    } -SuccessMessage "目录: /var/www/subway-server" -FailMessage "请在服务器上克隆代码"
} else {
    Write-Host "⏭️  跳过服务器环境检查（SSH 连接失败）" -ForegroundColor Yellow
    $failCount += 3
}

Write-Host ""
Write-Host "=== 5/6 服务状态检查 ===" -ForegroundColor Blue
Write-Host ""

if ($sshTest) {
    # 检查服务运行状态
    Test-Check -Name "服务正在运行" -Test {
        $result = ssh -i "$env:USERPROFILE\.ssh\github_deploy" "$ServerUser@$ServerIP" "pm2 list | grep -q 'subway-wechat-server.*online' && echo 'running'"
        $result -eq "running"
    } -SuccessMessage "subway-wechat-server 状态: online" -FailMessage "请启动服务: pm2 start ecosystem.config.js --env production"
} else {
    Write-Host "⏭️  跳过服务状态检查（SSH 连接失败）" -ForegroundColor Yellow
    $failCount++
}

Write-Host ""
Write-Host "=== 6/6 API 访问测试 ===" -ForegroundColor Blue
Write-Host ""

# 测试 API 访问
Test-Check -Name "外网 API 访问" -Test {
    try {
        $response = Invoke-RestMethod -Uri "http://${ServerIP}:3000/api/test" -TimeoutSec 10 -ErrorAction Stop
        $response.code -eq 200
    } catch {
        $false
    }
} -SuccessMessage "API 可以从外网访问" -FailMessage "无法访问 API，请检查：`n         1. 服务是否启动 (pm2 status)`n         2. 防火墙是否开放 3000 端口 (sudo ufw allow 3000/tcp)"

# 显示结果
Write-Host ""
Write-Host "======================================" -ForegroundColor Blue
Write-Host "   验证结果" -ForegroundColor Blue
Write-Host "======================================" -ForegroundColor Blue
Write-Host ""

$percentage = [math]::Round(($passCount / $totalTests) * 100)

Write-Host "通过: $passCount / $totalTests ($percentage%)" -ForegroundColor $(if ($percentage -eq 100) { "Green" } elseif ($percentage -ge 50) { "Yellow" } else { "Red" })
Write-Host "失败: $failCount / $totalTests" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Red" })
Write-Host ""

# 给出建议
if ($passCount -eq $totalTests) {
    Write-Host "🎉 恭喜！所有配置都已正确！" -ForegroundColor Green
    Write-Host ""
    Write-Host "下一步：触发部署测试" -ForegroundColor Cyan
    Write-Host "  1. 访问: https://github.com/gukazma/SubwayWechatApp/actions" -ForegroundColor Gray
    Write-Host "  2. 点击 'Deploy to Production'" -ForegroundColor Gray
    Write-Host "  3. 点击 'Run workflow' 按钮" -ForegroundColor Gray
    Write-Host "  4. 选择 master 分支并运行" -ForegroundColor Gray
} elseif ($passCount -ge ($totalTests / 2)) {
    Write-Host "⚠️  部分配置存在问题" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "建议：" -ForegroundColor Cyan
    Write-Host "  1. 修复上述失败的检查项" -ForegroundColor Gray
    Write-Host "  2. 查看相关文档进行排查" -ForegroundColor Gray
    Write-Host "  3. 重新运行此验证脚本" -ForegroundColor Gray
} else {
    Write-Host "❌ 配置存在较多问题" -ForegroundColor Red
    Write-Host ""
    Write-Host "建议：" -ForegroundColor Cyan
    Write-Host "  1. 查看 QUICK_SETUP.md 重新配置" -ForegroundColor Gray
    Write-Host "  2. 按步骤逐项检查配置" -ForegroundColor Gray
    Write-Host "  3. 需要帮助可查看故障排查文档" -ForegroundColor Gray
}

Write-Host ""
Write-Host "详细文档：" -ForegroundColor Cyan
Write-Host "  - 验证指南: VERIFICATION_GUIDE.md" -ForegroundColor Gray
Write-Host "  - 快速配置: QUICK_SETUP.md" -ForegroundColor Gray
Write-Host "  - 故障排查: GITHUB_ACTIONS_GUIDE.md" -ForegroundColor Gray
Write-Host ""

# 询问是否要查看详细信息
$showDetails = Read-Host "是否显示服务器详细信息? (y/n)"

if ($showDetails -eq 'y' -and $sshTest) {
    Write-Host ""
    Write-Host "=== 服务器详细信息 ===" -ForegroundColor Blue
    Write-Host ""

    Write-Host "软件版本:" -ForegroundColor Cyan
    ssh -i "$env:USERPROFILE\.ssh\github_deploy" "$ServerUser@$ServerIP" @"
echo "Node.js: `$(node --version 2>/dev/null || echo '未安装')"
echo "PM2: v`$(pm2 --version 2>/dev/null || echo '未安装')"
echo "Git: `$(git --version 2>/dev/null | awk '{print `$3}' || echo '未安装')"
"@

    Write-Host ""
    Write-Host "服务状态:" -ForegroundColor Cyan
    ssh -i "$env:USERPROFILE\.ssh\github_deploy" "$ServerUser@$ServerIP" "pm2 status 2>/dev/null | grep -A 1 'subway-wechat-server' || echo '服务未启动'"

    Write-Host ""
    Write-Host "防火墙状态:" -ForegroundColor Cyan
    ssh -i "$env:USERPROFILE\.ssh\github_deploy" "$ServerUser@$ServerIP" "sudo ufw status 2>/dev/null | grep -E '22|3000' || echo '未配置或无权限查看'"
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

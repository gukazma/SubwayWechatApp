#!/bin/bash

# 服务器环境一键配置脚本
# 用途: 自动安装和配置服务器环境

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "========================================"
echo "   地铁小程序服务器环境配置脚本"
echo "========================================"
echo -e "${NC}"

# 打印信息
print_info() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[→]${NC} $1"
}

# 检查是否为 root 用户
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_warn "检测到 root 用户，建议使用普通用户运行此脚本"
        SUDO=""
    else
        SUDO="sudo"
    fi
}

# 1. 更新系统
update_system() {
    print_step "步骤 1/8: 更新系统包..."
    $SUDO apt-get update -y
    print_info "系统包更新完成"
}

# 2. 安装 Node.js 18
install_nodejs() {
    print_step "步骤 2/8: 安装 Node.js 18..."

    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_info "Node.js 已安装: $NODE_VERSION"

        # 检查版本是否 >= 18
        MAJOR_VERSION=$(node --version | cut -d'.' -f1 | sed 's/v//')
        if [ "$MAJOR_VERSION" -ge 18 ]; then
            print_info "Node.js 版本符合要求"
            return 0
        else
            print_warn "Node.js 版本过低，需要升级"
        fi
    fi

    print_info "正在安装 Node.js 18..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | $SUDO -E bash -
    $SUDO apt-get install -y nodejs

    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    print_info "Node.js $NODE_VERSION 安装成功"
    print_info "npm $NPM_VERSION 安装成功"
}

# 3. 安装 PM2
install_pm2() {
    print_step "步骤 3/8: 安装 PM2..."

    if command -v pm2 &> /dev/null; then
        PM2_VERSION=$(pm2 --version)
        print_info "PM2 已安装: v$PM2_VERSION"
        return 0
    fi

    $SUDO npm install -g pm2
    PM2_VERSION=$(pm2 --version)
    print_info "PM2 v$PM2_VERSION 安装成功"
}

# 4. 安装 Git
install_git() {
    print_step "步骤 4/8: 安装 Git..."

    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version)
        print_info "Git 已安装: $GIT_VERSION"
        return 0
    fi

    $SUDO apt-get install -y git
    GIT_VERSION=$(git --version)
    print_info "$GIT_VERSION 安装成功"
}

# 5. 创建项目目录
create_project_dir() {
    print_step "步骤 5/8: 创建项目目录..."

    PROJECT_DIR="/var/www/subway-server"

    if [ -d "$PROJECT_DIR" ]; then
        print_warn "目录已存在: $PROJECT_DIR"
        read -p "是否删除并重新创建? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            $SUDO rm -rf "$PROJECT_DIR"
            print_info "已删除旧目录"
        else
            print_info "保留现有目录"
            return 0
        fi
    fi

    $SUDO mkdir -p "$PROJECT_DIR"
    $SUDO chown $USER:$USER "$PROJECT_DIR"
    print_info "项目目录创建成功: $PROJECT_DIR"
}

# 6. 克隆代码
clone_code() {
    print_step "步骤 6/8: 克隆项目代码..."

    PROJECT_DIR="/var/www/subway-server"
    REPO_URL="https://github.com/gukazma/SubwayWechatApp.git"

    if [ -d "$PROJECT_DIR/.git" ]; then
        print_info "代码已存在，正在更新..."
        cd "$PROJECT_DIR"
        git pull origin master || git pull origin main
    else
        print_info "正在克隆代码..."
        cd /var/www
        git clone "$REPO_URL" subway-server
    fi

    print_info "代码克隆/更新完成"
}

# 7. 配置环境和安装依赖
setup_environment() {
    print_step "步骤 7/8: 配置环境..."

    cd /var/www/subway-server/server

    # 创建 .env.production
    if [ ! -f .env.production ]; then
        print_info "创建 .env.production 文件..."
        cat > .env.production << 'EOF'
NODE_ENV=production
PORT=3000
HOST=0.0.0.0
CORS_ORIGIN=*
LOG_LEVEL=info
EOF
        print_info ".env.production 文件已创建"
    else
        print_info ".env.production 文件已存在"
    fi

    # 安装依赖
    print_info "正在安装项目依赖..."
    npm install --production
    print_info "依赖安装完成"
}

# 8. 启动服务
start_service() {
    print_step "步骤 8/8: 启动服务..."

    cd /var/www/subway-server/server

    # 检查服务是否已经在运行
    if pm2 list | grep -q "subway-wechat-server"; then
        print_info "服务已在运行，正在重启..."
        pm2 restart subway-wechat-server
    else
        print_info "正在启动服务..."
        pm2 start ecosystem.config.js --env production
        pm2 save
    fi

    # 设置开机自启
    print_info "配置开机自启..."
    pm2 startup | grep -E "^sudo" | bash || true

    print_info "服务启动成功"
}

# 9. 配置防火墙
configure_firewall() {
    print_step "配置防火墙..."

    if command -v ufw &> /dev/null; then
        print_info "检测到 UFW 防火墙"
        $SUDO ufw allow 22/tcp
        $SUDO ufw allow 3000/tcp
        $SUDO ufw --force enable
        print_info "防火墙规则已配置"
    else
        print_warn "未检测到 UFW，请手动配置防火墙"
    fi
}

# 10. 测试服务
test_service() {
    print_step "测试服务..."

    sleep 3  # 等待服务启动

    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/test || echo "000")

    if [ "$response" = "200" ]; then
        print_info "✅ 服务测试成功！"
    else
        print_warn "服务测试失败，返回状态码: $response"
        print_warn "请检查服务日志: pm2 logs subway-wechat-server"
    fi
}

# 显示结果
show_result() {
    echo ""
    echo -e "${GREEN}========================================"
    echo "   ✅ 服务器配置完成！"
    echo "========================================${NC}"
    echo ""
    echo "📦 安装的软件:"
    echo "  • Node.js: $(node --version)"
    echo "  • npm: $(npm --version)"
    echo "  • PM2: $(pm2 --version)"
    echo "  • Git: $(git --version | awk '{print $3}')"
    echo ""
    echo "📂 项目位置: /var/www/subway-server"
    echo "🌐 API 测试: http://localhost:3000/api/test"
    echo ""
    echo "🔧 常用命令:"
    echo "  pm2 status              # 查看服务状态"
    echo "  pm2 logs                # 查看日志"
    echo "  pm2 restart all         # 重启所有服务"
    echo "  pm2 monit               # 实时监控"
    echo ""
    echo "📚 下一步:"
    echo "  1. 确认 GitHub Secrets 已配置"
    echo "  2. 推送代码触发自动部署"
    echo "  3. 查看部署日志验证"
    echo ""
}

# 主函数
main() {
    check_root
    update_system
    install_nodejs
    install_pm2
    install_git
    create_project_dir
    clone_code
    setup_environment
    start_service
    configure_firewall
    test_service
    show_result
}

# 运行主函数
main

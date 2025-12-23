#!/bin/bash

# 部署脚本
# 用途: 自动化部署到服务器

set -e  # 遇到错误立即退出

echo "======================================"
echo "   地铁微信小程序后端部署脚本"
echo "======================================"

# 配置变量
SERVER_USER="your-username"           # 服务器用户名
SERVER_HOST="your-server-ip"          # 服务器IP或域名
SERVER_PATH="/var/www/subway-server"  # 服务器部署路径
APP_NAME="subway-wechat-server"       # 应用名称

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印信息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查必要的命令
check_requirements() {
    print_info "检查必要的命令..."

    if ! command -v ssh &> /dev/null; then
        print_error "ssh 命令未找到，请先安装 openssh"
        exit 1
    fi

    if ! command -v rsync &> /dev/null; then
        print_warn "rsync 未找到，将使用 scp 进行文件传输"
        USE_RSYNC=false
    else
        USE_RSYNC=true
    fi
}

# 构建前端
build_frontend() {
    print_info "构建前端微信小程序..."
    cd ../
    npm run build:mp-weixin
    print_info "前端构建完成"
}

# 部署后端
deploy_backend() {
    print_info "开始部署后端到服务器..."

    # 创建部署目录
    ssh ${SERVER_USER}@${SERVER_HOST} "mkdir -p ${SERVER_PATH}"

    # 同步文件
    if [ "$USE_RSYNC" = true ]; then
        print_info "使用 rsync 同步文件..."
        rsync -avz --exclude 'node_modules' \
                   --exclude '.git' \
                   --exclude '.env*' \
                   --exclude 'logs' \
                   ./ ${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/
    else
        print_info "使用 scp 传输文件..."
        scp -r ./* ${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/
    fi

    # 远程执行部署命令
    print_info "在服务器上安装依赖并重启服务..."
    ssh ${SERVER_USER}@${SERVER_HOST} << EOF
        cd ${SERVER_PATH}

        # 安装依赖
        npm install --production

        # 使用 PM2 管理进程
        if command -v pm2 &> /dev/null; then
            echo "使用 PM2 重启应用..."
            pm2 delete ${APP_NAME} 2>/dev/null || true
            pm2 start ecosystem.config.js --env production
            pm2 save
        else
            echo "PM2 未安装，使用 node 直接启动..."
            nohup node index.js > output.log 2>&1 &
        fi

        echo "部署完成！"
EOF

    print_info "后端部署完成"
}

# 使用 Docker 部署
deploy_with_docker() {
    print_info "使用 Docker 部署..."

    # 构建镜像
    print_info "构建 Docker 镜像..."
    docker build -t ${APP_NAME}:latest .

    # 保存镜像并传输到服务器
    print_info "传输镜像到服务器..."
    docker save ${APP_NAME}:latest | ssh ${SERVER_USER}@${SERVER_HOST} "docker load"

    # 在服务器上启动容器
    print_info "在服务器上启动容器..."
    ssh ${SERVER_USER}@${SERVER_HOST} << EOF
        cd ${SERVER_PATH}
        docker-compose down
        docker-compose up -d
        echo "Docker 部署完成！"
EOF

    print_info "Docker 部署完成"
}

# 回滚部署
rollback() {
    print_info "回滚到上一个版本..."
    ssh ${SERVER_USER}@${SERVER_HOST} << EOF
        cd ${SERVER_PATH}
        git checkout HEAD~1
        npm install --production
        pm2 restart ${APP_NAME}
        echo "回滚完成！"
EOF
}

# 查看服务状态
check_status() {
    print_info "检查服务状态..."
    ssh ${SERVER_USER}@${SERVER_HOST} << EOF
        cd ${SERVER_PATH}
        if command -v pm2 &> /dev/null; then
            pm2 status
            pm2 logs ${APP_NAME} --lines 20
        else
            ps aux | grep node
        fi
EOF
}

# 主菜单
show_menu() {
    echo ""
    echo "请选择部署方式:"
    echo "1) 常规部署 (PM2)"
    echo "2) Docker 部署"
    echo "3) 仅构建前端"
    echo "4) 查看服务状态"
    echo "5) 回滚部署"
    echo "6) 退出"
    echo ""
    read -p "请输入选项 [1-6]: " choice

    case $choice in
        1)
            check_requirements
            deploy_backend
            ;;
        2)
            check_requirements
            deploy_with_docker
            ;;
        3)
            build_frontend
            ;;
        4)
            check_status
            ;;
        5)
            rollback
            ;;
        6)
            print_info "退出部署脚本"
            exit 0
            ;;
        *)
            print_error "无效选项，请重新选择"
            show_menu
            ;;
    esac
}

# 执行主菜单
show_menu

print_info "所有操作完成！"

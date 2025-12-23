module.exports = {
  apps: [
    {
      name: 'subway-wechat-server',
      script: './index.js',
      instances: 'max', // 或者指定数字，如 2
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'development',
        PORT: 3000
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      error_file: './logs/err.log',
      out_file: './logs/out.log',
      log_file: './logs/combined.log',
      time: true,
      max_memory_restart: '500M',
      autorestart: true,
      watch: false,
      ignore_watch: ['node_modules', 'logs'],
      max_restarts: 10,
      min_uptime: '10s'
    }
  ],

  deploy: {
    production: {
      user: 'your-username', // 服务器用户名
      host: 'your-server-ip', // 服务器IP或域名
      ref: 'origin/main',
      repo: 'git@github.com:your-username/your-repo.git', // Git仓库地址
      path: '/var/www/subway-wechat-server', // 服务器上的部署路径
      'post-deploy': 'npm install && pm2 reload ecosystem.config.js --env production',
      env: {
        NODE_ENV: 'production'
      }
    }
  }
}

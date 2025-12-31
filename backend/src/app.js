const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

// 中间件
app.use(cors());
app.use(express.json());

// 路由
const authRoutes = require('./routes/auth');
const stationRoutes = require('./routes/stations');
const supportRoutes = require('./routes/supports');

// 健康检查接口
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: '服务正常运行', database: 'in-memory' });
});

// 基础路由
app.get('/api', (req, res) => {
  res.json({ message: '地铁站站务员支援系统 API' });
});

// API 路由
app.use('/api/auth', authRoutes);
app.use('/api/stations', stationRoutes);
app.use('/api/supports', supportRoutes);

// 启动服务器
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 服务器运行在 http://localhost:${PORT}`);
  console.log(`📊 健康检查接口: http://localhost:${PORT}/api/health`);
});

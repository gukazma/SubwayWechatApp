require('dotenv').config({ path: `.env.${process.env.NODE_ENV || 'development'}` });
const express = require('express');
const cors = require('cors');

const app = express();

// 环境变量配置
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || 'localhost';
const NODE_ENV = process.env.NODE_ENV || 'development';
const CORS_ORIGIN = process.env.CORS_ORIGIN || '*';

// 中间件
app.use(cors({
  origin: CORS_ORIGIN,
  credentials: true
}));
app.use(express.json());

// 模拟数据库 - 地铁线路信息
const subwayLines = [
  { id: 1, name: '1号线', stations: 28, color: '#C23A2B' },
  { id: 2, name: '2号线', stations: 32, color: '#0071BC' },
  { id: 3, name: '3号线', stations: 25, color: '#FFD100' },
  { id: 4, name: '4号线', stations: 35, color: '#00A650' }
];

// 模拟用户收藏
let userFavorites = [];

// API 路由

// 1. 获取所有地铁线路
app.get('/api/subway/lines', (req, res) => {
  res.json({
    code: 200,
    message: '获取成功',
    data: subwayLines
  });
});

// 2. 获取单条线路详情
app.get('/api/subway/lines/:id', (req, res) => {
  const lineId = parseInt(req.params.id);
  const line = subwayLines.find(l => l.id === lineId);

  if (line) {
    res.json({
      code: 200,
      message: '获取成功',
      data: line
    });
  } else {
    res.status(404).json({
      code: 404,
      message: '线路不存在',
      data: null
    });
  }
});

// 3. 添加收藏
app.post('/api/favorites', (req, res) => {
  const { lineId, userId } = req.body;

  const favorite = {
    id: userFavorites.length + 1,
    lineId,
    userId,
    createdAt: new Date()
  };

  userFavorites.push(favorite);

  res.json({
    code: 200,
    message: '收藏成功',
    data: favorite
  });
});

// 4. 获取用户收藏列表
app.get('/api/favorites/:userId', (req, res) => {
  const userId = req.params.userId;
  const favorites = userFavorites.filter(f => f.userId === userId);

  // 关联地铁线路信息
  const favoritesWithLineInfo = favorites.map(fav => {
    const line = subwayLines.find(l => l.id === fav.lineId);
    return {
      ...fav,
      line
    };
  });

  res.json({
    code: 200,
    message: '获取成功',
    data: favoritesWithLineInfo
  });
});

// 5. 删除收藏
app.delete('/api/favorites/:id', (req, res) => {
  const favId = parseInt(req.params.id);
  const index = userFavorites.findIndex(f => f.id === favId);

  if (index !== -1) {
    userFavorites.splice(index, 1);
    res.json({
      code: 200,
      message: '删除成功',
      data: null
    });
  } else {
    res.status(404).json({
      code: 404,
      message: '收藏不存在',
      data: null
    });
  }
});

// 6. 测试接口
app.get('/api/test', (req, res) => {
  res.json({
    code: 200,
    message: 'Server is running!',
    data: {
      timestamp: new Date(),
      version: '1.0.0',
      environment: NODE_ENV
    }
  });
});

// 启动服务器
app.listen(PORT, HOST, () => {
  console.log(`🚇 地铁微信小程序后端服务已启动`);
  console.log(`📍 运行环境: ${NODE_ENV}`);
  console.log(`📍 服务地址: http://${HOST}:${PORT}`);
  console.log(`🔧 API 文档:`);
  console.log(`   GET  /api/test - 测试接口`);
  console.log(`   GET  /api/subway/lines - 获取所有线路`);
  console.log(`   GET  /api/subway/lines/:id - 获取线路详情`);
  console.log(`   POST /api/favorites - 添加收藏`);
  console.log(`   GET  /api/favorites/:userId - 获取用户收藏`);
  console.log(`   DELETE /api/favorites/:id - 删除收藏`);
});

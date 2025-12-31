const express = require('express');
const router = express.Router();
const { generateToken } = require('../utils/jwt');
const { createOrUpdateUser, findUserByOpenid } = require('../data/users');

/**
 * 微信登录接口
 * POST /api/auth/login
 */
router.post('/login', async (req, res) => {
  try {
    const { code } = req.body;

    if (!code) {
      return res.status(400).json({
        success: false,
        message: '缺少 code 参数'
      });
    }

    // TODO: 实际项目中需要调用微信 API 换取 openid
    // 这里使用模拟数据
    const mockOpenid = `mock_openid_${code}_${Date.now()}`;
    
    // 创建或更新用户
    const user = createOrUpdateUser({
      openid: mockOpenid,
      nickname: '测试用户',
      avatar: 'https://via.placeholder.com/100'
    });

    // 生成 token
    const token = generateToken({
      userId: user._id,
      openid: user.openid
    });

    res.json({
      success: true,
      data: {
        token,
        user: {
          _id: user._id,
          openid: user.openid,
          nickname: user.nickname,
          avatar: user.avatar
        }
      }
    });
  } catch (error) {
    console.error('登录失败:', error);
    res.status(500).json({
      success: false,
      message: '登录失败，请稍后重试'
    });
  }
});

module.exports = router;

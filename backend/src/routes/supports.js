const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../utils/jwt');
const { createSupportTask, getSupportsByUserId, updateSupportStatus } = require('../data/supports');
const { updateEntranceStaff } = require('../data/entrances');

/**
 * 创建支援报名
 * POST /api/supports
 */
router.post('/', authMiddleware, (req, res) => {
  try {
    const { stationId, entranceId, supportDate, startTime, endTime } = req.body;
    const userId = req.user.userId;
    
    if (!stationId || !entranceId || !supportDate || !startTime || !endTime) {
      return res.status(400).json({
        success: false,
        message: '缺少必要参数'
      });
    }
    
    // 创建支援任务
    const task = createSupportTask({
      stationId,
      entranceId,
      userId,
      supportDate: new Date(supportDate),
      startTime,
      endTime
    });
    
    // 更新出入口人数
    updateEntranceStaff(entranceId, 1);
    
    res.json({
      success: true,
      data: task
    });
  } catch (error) {
    console.error('创建支援报名失败:', error);
    res.status(500).json({
      success: false,
      message: '创建支援报名失败'
    });
  }
});

/**
 * 获取支援记录列表
 * GET /api/supports
 */
router.get('/', authMiddleware, (req, res) => {
  try {
    const userId = req.user.userId;
    const supports = getSupportsByUserId(userId);
    
    res.json({
      success: true,
      data: supports
    });
  } catch (error) {
    console.error('获取支援记录失败:', error);
    res.status(500).json({
      success: false,
      message: '获取支援记录失败'
    });
  }
});

/**
 * 取消支援报名
 * POST /api/supports/:id/cancel
 */
router.post('/:id/cancel', authMiddleware, (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;
    
    // 查找支援任务
    const task = findSupportById(id);
    
    if (!task) {
      return res.status(404).json({
        success: false,
        message: '支援记录不存在'
      });
    }
    
    // 只能取消自己的报名
    if (task.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: '无权取消此报名'
      });
    }
    
    // 只能取消待确认的报名
    if (task.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: '只能取消待确认的报名'
      });
    }
    
    // 更新状态为已取消
    updateSupportStatus(id, 'cancelled');
    
    // 更新出入口人数（减1）
    updateEntranceStaff(task.entranceId, -1);
    
    res.json({
      success: true,
      message: '已取消报名'
    });
  } catch (error) {
    console.error('取消支援报名失败:', error);
    res.status(500).json({
      success: false,
      message: '取消支援报名失败'
    });
  }
});

// 需要导入 findSupportById
const { findSupportById } = require('../data/supports');

module.exports = router;

const express = require('express');
const router = express.Router();
const { getAllStations, findStationById } = require('../data/stations');
const { getEntrancesByStationId } = require('../data/entrances');

/**
 * 获取站点列表
 * GET /api/stations
 */
router.get('/', (req, res) => {
  try {
    const stations = getAllStations();
    res.json({
      success: true,
      data: stations
    });
  } catch (error) {
    console.error('获取站点列表失败:', error);
    res.status(500).json({
      success: false,
      message: '获取站点列表失败'
    });
  }
});

/**
 * 获取站点详情
 * GET /api/stations/:id
 */
router.get('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const station = findStationById(id);
    
    if (!station) {
      return res.status(404).json({
        success: false,
        message: '站点不存在'
      });
    }
    
    res.json({
      success: true,
      data: station
    });
  } catch (error) {
    console.error('获取站点详情失败:', error);
    res.status(500).json({
      success: false,
      message: '获取站点详情失败'
    });
  }
});

/**
 * 获取站点的出入口列表
 * GET /api/stations/:id/entrances
 */
router.get('/:id/entrances', (req, res) => {
  try {
    const { id } = req.params;
    const entrances = getEntrancesByStationId(id);
    res.json({
      success: true,
      data: entrances
    });
  } catch (error) {
    console.error('获取出入口列表失败:', error);
    res.status(500).json({
      success: false,
      message: '获取出入口列表失败'
    });
  }
});

module.exports = router;

// 内存出入口存储（用于开发测试）
const entrances = [];

// 初始化模拟出入口数据
function initMockData() {
  if (entrances.length === 0) {
    // 为每个站点创建出入口
    const stationEntrances = [
      // 人民广场站出入口
      { _id: 'e1', stationId: '1', name: 'A口', type: 'entrance', requiredStaff: 3, currentStaff: 1, status: 'short' },
      { _id: 'e2', stationId: '1', name: 'B口', type: 'entrance', requiredStaff: 2, currentStaff: 2, status: 'full' },
      { _id: 'e3', stationId: '1', name: 'C口', type: 'exit', requiredStaff: 3, currentStaff: 2, status: 'normal' },
      { _id: 'e4', stationId: '1', name: 'D口', type: 'entrance', requiredStaff: 2, currentStaff: 0, status: 'short' },
      
      // 南京东路站出入口
      { _id: 'e5', stationId: '2', name: 'A口', type: 'entrance', requiredStaff: 3, currentStaff: 3, status: 'full' },
      { _id: 'e6', stationId: '2', name: 'B口', type: 'exit', requiredStaff: 2, currentStaff: 1, status: 'normal' },
      { _id: 'e7', stationId: '2', name: 'C口', type: 'entrance', requiredStaff: 3, currentStaff: 1, status: 'short' },
      
      // 陆家嘴站出入口
      { _id: 'e8', stationId: '3', name: '1号口', type: 'entrance', requiredStaff: 2, currentStaff: 2, status: 'full' },
      { _id: 'e9', stationId: '3', name: '2号口', type: 'exit', requiredStaff: 2, currentStaff: 0, status: 'short' },
      
      // 世纪大道站出入口
      { _id: 'e10', stationId: '4', name: 'A口', type: 'entrance', requiredStaff: 3, currentStaff: 1, status: 'short' },
      { _id: 'e11', stationId: '4', name: 'B口', type: 'entrance', requiredStaff: 2, currentStaff: 2, status: 'full' },
      
      // 静安寺站出入口
      { _id: 'e12', stationId: '5', name: '1号口', type: 'entrance', requiredStaff: 3, currentStaff: 0, status: 'short' },
      { _id: 'e13', stationId: '5', name: '2号口', type: 'exit', requiredStaff: 2, currentStaff: 1, status: 'normal' },
      { _id: 'e14', stationId: '5', name: '3号口', type: 'entrance', requiredStaff: 2, currentStaff: 2, status: 'full' }
    ];
    
    entrances.push(...stationEntrances);
  }
}

// 初始化数据
initMockData();

/**
 * 获取站点的所有出入口
 */
function getEntrancesByStationId(stationId) {
  return entrances.filter(e => e.stationId === stationId);
}

/**
 * 根据 ID 查找出入口
 */
function findEntranceById(id) {
  return entrances.find(e => e._id === id);
}

/**
 * 更新出入口人数
 */
function updateEntranceStaff(id, delta) {
  const entrance = findEntranceById(id);
  if (entrance) {
    entrance.currentStaff += delta;
    // 更新状态
    if (entrance.currentStaff >= entrance.requiredStaff) {
      entrance.status = 'full';
    } else if (entrance.currentStaff === 0) {
      entrance.status = 'short';
    } else {
      entrance.status = 'normal';
    }
    entrance.updatedAt = new Date();
    return entrance;
  }
  return null;
}

module.exports = {
  entrances,
  getEntrancesByStationId,
  findEntranceById,
  updateEntranceStaff
};

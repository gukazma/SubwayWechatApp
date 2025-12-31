// 内存站点存储（用于开发测试）
const stations = [];

// 初始化模拟站点数据
function initMockData() {
  if (stations.length === 0) {
    const mockStations = [
      {
        _id: '1',
        name: '人民广场站',
        code: 'PEOPLE_SQUARE',
        line: '1号线',
        location: { lat: 31.2304, lng: 121.4737 },
        status: 'active',
        createdAt: new Date()
      },
      {
        _id: '2',
        name: '南京东路站',
        code: 'NANJING_EAST',
        line: '2号线',
        location: { lat: 31.2335, lng: 121.4826 },
        status: 'active',
        createdAt: new Date()
      },
      {
        _id: '3',
        name: '陆家嘴站',
        code: 'LUJIAZUI',
        line: '2号线',
        location: { lat: 31.2396, lng: 121.4998 },
        status: 'active',
        createdAt: new Date()
      },
      {
        _id: '4',
        name: '世纪大道站',
        code: 'CENTURY_AVENUE',
        line: '2号线',
        location: { lat: 31.2351, lng: 121.5058 },
        status: 'active',
        createdAt: new Date()
      },
      {
        _id: '5',
        name: '静安寺站',
        code: 'JINGAN_TEMPLE',
        line: '2号线',
        location: { lat: 31.2279, lng: 121.4467 },
        status: 'active',
        createdAt: new Date()
      }
    ];
    stations.push(...mockStations);
  }
}

// 初始化数据
initMockData();

/**
 * 获取所有站点
 */
function getAllStations() {
  return stations;
}

/**
 * 根据 ID 查找站点
 */
function findStationById(id) {
  return stations.find(station => station._id === id);
}

module.exports = {
  stations,
  getAllStations,
  findStationById
};

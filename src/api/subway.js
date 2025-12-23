// 地铁相关 API
import { get, post, del } from '@/utils/request.js'

/**
 * 测试服务器连接
 */
export function testConnection() {
  return get('/test')
}

/**
 * 获取所有地铁线路
 */
export function getSubwayLines() {
  return get('/subway/lines', {}, { showLoading: true })
}

/**
 * 获取单条线路详情
 * @param {Number} id - 线路ID
 */
export function getSubwayLineById(id) {
  return get(`/subway/lines/${id}`)
}

/**
 * 添加收藏
 * @param {Number} lineId - 线路ID
 * @param {String} userId - 用户ID
 */
export function addFavorite(lineId, userId) {
  return post('/favorites', { lineId, userId })
}

/**
 * 获取用户收藏列表
 * @param {String} userId - 用户ID
 */
export function getUserFavorites(userId) {
  return get(`/favorites/${userId}`, {}, { showLoading: true })
}

/**
 * 删除收藏
 * @param {Number} favId - 收藏ID
 */
export function deleteFavorite(favId) {
  return del(`/favorites/${favId}`)
}

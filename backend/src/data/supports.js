// 内存支援任务存储（用于开发测试）
const supportTasks = [];

/**
 * 创建支援任务
 */
function createSupportTask(taskData) {
  const task = {
    _id: Date.now().toString(),
    createdAt: new Date(),
    updatedAt: new Date(),
    status: 'pending',
    ...taskData
  };
  supportTasks.push(task);
  return task;
}

/**
 * 获取用户的所有支援记录
 */
function getSupportsByUserId(userId) {
  return supportTasks.filter(task => task.userId === userId);
}

/**
 * 根据 ID 查找支援任务
 */
function findSupportById(id) {
  return supportTasks.find(task => task._id === id);
}

/**
 * 更新支援任务状态
 */
function updateSupportStatus(id, status) {
  const task = findSupportById(id);
  if (task) {
    task.status = status;
    task.updatedAt = new Date();
    return task;
  }
  return null;
}

module.exports = {
  supportTasks,
  createSupportTask,
  getSupportsByUserId,
  findSupportById,
  updateSupportStatus
};

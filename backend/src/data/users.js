// 内存用户存储（用于开发测试）
const users = [];

/**
 * 根据 openid 查找用户
 */
function findUserByOpenid(openid) {
  return users.find(user => user.openid === openid);
}

/**
 * 创建或更新用户
 */
function createOrUpdateUser(userData) {
  const existingUser = findUserByOpenid(userData.openid);
  
  if (existingUser) {
    // 更新用户信息
    Object.assign(existingUser, userData);
    return existingUser;
  } else {
    // 创建新用户
    const newUser = {
      _id: Date.now().toString(),
      createdAt: new Date(),
      ...userData
    };
    users.push(newUser);
    return newUser;
  }
}

/**
 * 根据 ID 查找用户
 */
function findUserById(userId) {
  return users.find(user => user._id === userId);
}

module.exports = {
  users,
  findUserByOpenid,
  createOrUpdateUser,
  findUserById
};

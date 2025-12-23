<template>
  <view class="container">
    <view class="header">
      <text class="title">地铁小程序 - API测试</text>
    </view>

    <!-- 测试连接按钮 -->
    <view class="section">
      <button class="btn" @click="testConnection" type="primary">
        测试服务器连接
      </button>
      <view v-if="serverStatus" class="status-box">
        <text class="status-text">{{ serverStatus }}</text>
      </view>
    </view>

    <!-- 获取地铁线路 -->
    <view class="section">
      <button class="btn" @click="getSubwayLines" type="default">
        获取地铁线路列表
      </button>
      <view v-if="subwayLines.length > 0" class="list">
        <view v-for="line in subwayLines" :key="line.id" class="line-item">
          <view class="line-info">
            <view class="line-color" :style="{backgroundColor: line.color}"></view>
            <text class="line-name">{{ line.name }}</text>
            <text class="line-stations">{{ line.stations }}站</text>
          </view>
          <button class="btn-small" @click="addFavorite(line.id)" size="mini">
            收藏
          </button>
        </view>
      </view>
    </view>

    <!-- 我的收藏 -->
    <view class="section">
      <button class="btn" @click="getFavorites" type="default">
        查看我的收藏
      </button>
      <view v-if="favorites.length > 0" class="list">
        <view v-for="fav in favorites" :key="fav.id" class="line-item">
          <view class="line-info">
            <view class="line-color" :style="{backgroundColor: fav.line.color}"></view>
            <text class="line-name">{{ fav.line.name }}</text>
          </view>
          <button class="btn-small btn-delete" @click="deleteFavorite(fav.id)" size="mini">
            删除
          </button>
        </view>
      </view>
      <view v-else-if="showEmptyFavorites" class="empty-text">
        <text>暂无收藏</text>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      serverStatus: '',
      subwayLines: [],
      favorites: [],
      showEmptyFavorites: false,
      userId: 'user_001', // 模拟用户ID
      baseURL: 'http://localhost:3000/api'
    }
  },
  onLoad() {
    console.log('页面加载完成');
  },
  methods: {
    // 测试服务器连接
    testConnection() {
      uni.showLoading({ title: '连接中...' });

      uni.request({
        url: `${this.baseURL}/test`,
        method: 'GET',
        success: (res) => {
          console.log('测试连接成功:', res.data);
          if (res.data.code === 200) {
            this.serverStatus = `✅ 服务器连接成功！\n${res.data.message}\n时间: ${new Date(res.data.data.timestamp).toLocaleString()}`;
            uni.showToast({
              title: '连接成功',
              icon: 'success'
            });
          }
        },
        fail: (err) => {
          console.error('连接失败:', err);
          this.serverStatus = `❌ 连接失败\n请确保后端服务已启动`;
          uni.showToast({
            title: '连接失败',
            icon: 'none'
          });
        },
        complete: () => {
          uni.hideLoading();
        }
      });
    },

    // 获取地铁线路列表
    getSubwayLines() {
      uni.showLoading({ title: '加载中...' });

      uni.request({
        url: `${this.baseURL}/subway/lines`,
        method: 'GET',
        success: (res) => {
          console.log('获取线路成功:', res.data);
          if (res.data.code === 200) {
            this.subwayLines = res.data.data;
            uni.showToast({
              title: '加载成功',
              icon: 'success'
            });
          }
        },
        fail: (err) => {
          console.error('获取线路失败:', err);
          uni.showToast({
            title: '加载失败',
            icon: 'none'
          });
        },
        complete: () => {
          uni.hideLoading();
        }
      });
    },

    // 添加收藏
    addFavorite(lineId) {
      uni.request({
        url: `${this.baseURL}/favorites`,
        method: 'POST',
        data: {
          lineId: lineId,
          userId: this.userId
        },
        header: {
          'content-type': 'application/json'
        },
        success: (res) => {
          console.log('添加收藏成功:', res.data);
          if (res.data.code === 200) {
            uni.showToast({
              title: '收藏成功',
              icon: 'success'
            });
          }
        },
        fail: (err) => {
          console.error('添加收藏失败:', err);
          uni.showToast({
            title: '收藏失败',
            icon: 'none'
          });
        }
      });
    },

    // 获取用户收藏
    getFavorites() {
      this.showEmptyFavorites = false;
      uni.showLoading({ title: '加载中...' });

      uni.request({
        url: `${this.baseURL}/favorites/${this.userId}`,
        method: 'GET',
        success: (res) => {
          console.log('获取收藏成功:', res.data);
          if (res.data.code === 200) {
            this.favorites = res.data.data;
            this.showEmptyFavorites = true;
            if (this.favorites.length > 0) {
              uni.showToast({
                title: '加载成功',
                icon: 'success'
              });
            }
          }
        },
        fail: (err) => {
          console.error('获取收藏失败:', err);
          uni.showToast({
            title: '加载失败',
            icon: 'none'
          });
        },
        complete: () => {
          uni.hideLoading();
        }
      });
    },

    // 删除收藏
    deleteFavorite(favId) {
      uni.request({
        url: `${this.baseURL}/favorites/${favId}`,
        method: 'DELETE',
        success: (res) => {
          console.log('删除收藏成功:', res.data);
          if (res.data.code === 200) {
            uni.showToast({
              title: '删除成功',
              icon: 'success'
            });
            // 刷新收藏列表
            this.getFavorites();
          }
        },
        fail: (err) => {
          console.error('删除收藏失败:', err);
          uni.showToast({
            title: '删除失败',
            icon: 'none'
          });
        }
      });
    }
  }
}
</script>

<style>
.container {
  padding: 30rpx;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.header {
  text-align: center;
  margin-bottom: 40rpx;
  padding: 30rpx 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 20rpx;
}

.title {
  font-size: 40rpx;
  font-weight: bold;
  color: #ffffff;
}

.section {
  margin-bottom: 40rpx;
  background-color: #ffffff;
  border-radius: 20rpx;
  padding: 30rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.1);
}

.btn {
  margin-bottom: 20rpx;
  border-radius: 10rpx;
}

.btn-small {
  padding: 0 20rpx;
  background-color: #07c160;
  color: #ffffff;
  border: none;
  border-radius: 8rpx;
}

.btn-delete {
  background-color: #fa5151;
}

.status-box {
  margin-top: 20rpx;
  padding: 20rpx;
  background-color: #f0f9ff;
  border-radius: 10rpx;
  border-left: 6rpx solid #1989fa;
}

.status-text {
  font-size: 28rpx;
  color: #333333;
  white-space: pre-line;
  line-height: 1.6;
}

.list {
  margin-top: 20rpx;
}

.line-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx;
  margin-bottom: 15rpx;
  background-color: #fafafa;
  border-radius: 10rpx;
  border: 2rpx solid #eeeeee;
}

.line-info {
  display: flex;
  align-items: center;
  flex: 1;
}

.line-color {
  width: 8rpx;
  height: 40rpx;
  border-radius: 4rpx;
  margin-right: 15rpx;
}

.line-name {
  font-size: 32rpx;
  font-weight: bold;
  color: #333333;
  margin-right: 15rpx;
}

.line-stations {
  font-size: 26rpx;
  color: #999999;
}

.empty-text {
  text-align: center;
  padding: 40rpx 0;
  color: #999999;
  font-size: 28rpx;
}
</style>

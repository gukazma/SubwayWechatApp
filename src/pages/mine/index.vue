<template>
	<view class="container">
		<view class="header">
			<image class="avatar" :src="userStore.avatar" mode="aspectFill"></image>
			<text class="nickname">{{ userStore.nickname }}</text>
		</view>
		
		<view class="menu-list">
			<view class="menu-item" @click="goToSupports">
				<view class="menu-left">
					<view class="menu-icon supports-icon">
						<text class="icon-text">记</text>
					</view>
					<text class="menu-title">我的支援记录</text>
				</view>
				<text class="arrow">›</text>
			</view>
			
			<view class="menu-item" @click="goToProfile">
				<view class="menu-left">
					<view class="menu-icon profile-icon">
						<text class="icon-text">人</text>
					</view>
					<text class="menu-title">个人信息</text>
				</view>
				<text class="arrow">›</text>
			</view>
		</view>
		
		<view class="logout-section">
			<button class="logout-btn" @click="handleLogout">
				<text>退出登录</text>
			</button>
		</view>
	</view>
</template>

<script setup>
import { onShow } from '@dcloudio/uni-app';
import { useUserStore } from '@/stores/user';

const userStore = useUserStore();

onShow(() => {
	// 检查登录状态
	if (!userStore.checkLogin()) {
		return;
	}
});

const goToSupports = () => {
	uni.navigateTo({
		url: '/pages/mine/supports'
	});
};

const goToProfile = () => {
	uni.navigateTo({
		url: '/pages/mine/profile'
	});
};

const handleLogout = () => {
	uni.showModal({
		title: '确认退出',
		content: '确定要退出登录吗？',
		success: (res) => {
			if (res.confirm) {
				userStore.logout();
				uni.showToast({
					title: '已退出登录',
					icon: 'success',
					duration: 1500
				});
				
				// 跳转到登录页
				setTimeout(() => {
					uni.reLaunch({
						url: '/pages/login/index'
					});
				}, 1500);
			}
		}
	});
};
</script>

<style scoped>
.container {
		min-height: 100vh;
		background: #f5f5f5;
		padding: 30rpx;
}

.header {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		border-radius: 20rpx;
		padding: 60rpx 40rpx;
		display: flex;
		flex-direction: column;
		align-items: center;
		margin-bottom: 40rpx;
		box-shadow: 0 10rpx 30rpx rgba(102, 126, 234, 0.3);
}

.avatar {
		width: 120rpx;
		height: 120rpx;
		border-radius: 60rpx;
		border: 4rpx solid rgba(255, 255, 255, 0.3);
		margin-bottom: 20rpx;
		background: #fff;
}

.nickname {
		font-size: 36rpx;
		font-weight: bold;
		color: #fff;
}

.menu-list {
		background: #fff;
		border-radius: 20rpx;
		overflow: hidden;
		margin-bottom: 40rpx;
		box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.08);
}

.menu-item {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 35rpx 30rpx;
		border-bottom: 1rpx solid #f0f0f0;
		transition: background 0.3s;
}

.menu-item:last-child {
		border-bottom: none;
}

.menu-item:active {
		background: #f8f8f8;
}

.menu-left {
		display: flex;
		align-items: center;
}

.menu-icon {
		width: 70rpx;
		height: 70rpx;
		border-radius: 35rpx;
		display: flex;
		align-items: center;
		justify-content: center;
		margin-right: 25rpx;
}

.supports-icon {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.profile-icon {
		background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.icon-text {
		font-size: 28rpx;
		font-weight: bold;
		color: #fff;
}

.menu-title {
		font-size: 30rpx;
		color: #333;
}

.arrow {
		font-size: 48rpx;
		color: #ccc;
		font-weight: bold;
}

.logout-section {
		padding: 0 30rpx;
}

.logout-btn {
		width: 100%;
		height: 90rpx;
		background: #fff;
		color: #ff4d4f;
		border-radius: 45rpx;
		font-size: 30rpx;
		font-weight: bold;
		border: 2rpx solid #ff4d4f;
		box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.08);
}

.logout-btn:active {
		background: #fff5f5;
}
</style>

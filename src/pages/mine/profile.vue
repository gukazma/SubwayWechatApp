<template>
	<view class="container">
		<view class="header">
			<text class="title">个人信息</text>
		</view>
		
		<view class="loading-container" v-if="loading">
			<view class="loading-spinner"></view>
			<text class="loading-text">加载中...</text>
		</view>
		
		<view class="profile-content" v-else>
			<view class="avatar-section">
				<image class="avatar" :src="userStore.avatar" mode="aspectFill"></image>
				<text class="nickname">{{ userStore.nickname }}</text>
			</view>
			
			<view class="info-list">
				<view class="info-item">
					<text class="info-label">用户ID</text>
					<text class="info-value">{{ userInfo.id || '-' }}</text>
				</view>
				<view class="info-item">
					<text class="info-label">昵称</text>
					<text class="info-value">{{ userInfo.nickname || '-' }}</text>
				</view>
				<view class="info-item">
					<text class="info-label">注册时间</text>
					<text class="info-value">{{ formatTime(userInfo.createdAt) }}</text>
				</view>
			</view>
			
			<view class="logout-section">
				<button class="logout-btn" @click="handleLogout">
					<text>退出登录</text>
				</button>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref } from 'vue';
import { onLoad } from '@dcloudio/uni-app';
import { useUserStore } from '@/stores/user';

const userStore = useUserStore();
const loading = ref(false);
const userInfo = ref({});

onLoad(() => {
	// 检查登录状态
	if (!userStore.checkLogin()) {
		return;
	}
	
	// 加载用户信息
	loadUserInfo();
});

const loadUserInfo = () => {
	loading.value = true;
	
	// 从 store 获取用户信息
	userInfo.value = userStore.userInfo || {};
	
	loading.value = false;
};

const formatTime = (time) => {
	if (!time) return '-';
	
	try {
		const date = new Date(time);
		const year = date.getFullYear();
		const month = String(date.getMonth() + 1).padStart(2, '0');
		const day = String(date.getDate()).padStart(2, '0');
		const hour = String(date.getHours()).padStart(2, '0');
		const minute = String(date.getMinutes()).padStart(2, '0');
		return `${year}-${month}-${day} ${hour}:${minute}`;
	} catch (error) {
		return '-';
	}
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
		text-align: center;
		padding: 40rpx 0;
		margin-bottom: 30rpx;
}

.title {
		font-size: 40rpx;
		font-weight: bold;
		color: #333;
}

.loading-container {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		padding: 200rpx 0;
}

.loading-spinner {
		width: 60rpx;
		height: 60rpx;
		border: 4rpx solid #e0e0e0;
		border-top-color: #007AFF;
		border-radius: 50%;
		animation: spin 0.8s linear infinite;
		margin-bottom: 30rpx;
}

@keyframes spin {
		to {
				transform: rotate(360deg);
		}
}

.loading-text {
		font-size: 28rpx;
		color: #999;
}

.profile-content {
		display: flex;
		flex-direction: column;
}

.avatar-section {
		background: #fff;
		border-radius: 20rpx;
		padding: 60rpx 40rpx;
		display: flex;
		flex-direction: column;
		align-items: center;
		margin-bottom: 30rpx;
		box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.08);
}

.avatar {
		width: 160rpx;
		height: 160rpx;
		border-radius: 80rpx;
		border: 4rpx solid #f0f0f0;
		margin-bottom: 30rpx;
		background: #f5f5f5;
}

.nickname {
		font-size: 36rpx;
		font-weight: bold;
		color: #333;
}

.info-list {
		background: #fff;
		border-radius: 20rpx;
		overflow: hidden;
		margin-bottom: 40rpx;
		box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.08);
}

.info-item {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 35rpx 30rpx;
		border-bottom: 1rpx solid #f0f0f0;
}

.info-item:last-child {
		border-bottom: none;
}

.info-label {
		font-size: 30rpx;
		color: #999;
}

.info-value {
		font-size: 30rpx;
		color: #333;
		font-weight: 500;
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

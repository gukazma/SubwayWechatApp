<template>
	<view class="container">
		<view class="header">
			<text class="title">站点列表</text>
			<text class="subtitle">选择需要支援的站点</text>
		</view>
		
		<view class="loading-container" v-if="loading">
			<view class="loading-spinner"></view>
			<text class="loading-text">加载中...</text>
		</view>
		
		<view class="error-container" v-else-if="error">
			<image class="error-icon" src="/static/logo.png" mode="aspectFit"></image>
			<text class="error-text">{{ error }}</text>
			<button class="retry-btn" @click="loadStations">重新加载</button>
		</view>
		
		<view class="stations-list" v-else>
			<view 
				class="station-card" 
				v-for="station in stations" 
				:key="station._id"
				@click="goToDetail(station._id)"
			>
				<view class="station-info">
					<text class="station-name">{{ station.name }}</text>
					<text class="station-line">{{ station.line }}</text>
				</view>
				<view class="station-status">
					<text class="entrance-count">{{ station.entranceCount }}个出入口</text>
					<text class="arrow">›</text>
				</view>
			</view>
		</view>
	</view>
</template>

<!-- Force rebuild -->
<script setup>
import { ref } from 'vue';
import { onLoad } from '@dcloudio/uni-app';
import { useUserStore } from '@/stores/user';

const userStore = useUserStore();
const stations = ref([]);
const loading = ref(false);
const error = ref('');

onLoad(async (options) => {
	// 检查登录状态
	if (!userStore.checkLogin()) {
		return;
	}
	
	await loadStations();
});

const loadStations = async () => {
	loading.value = true;
	error.value = '';
	
	try {
		const res = await uni.request({
			url: 'http://localhost:3000/api/stations',
			method: 'GET',
			header: {
				'Authorization': `Bearer ${userStore.token}`
			}
		});
		
		if (res.data.success && res.data.data) {
			stations.value = res.data.data;
		} else {
			error.value = res.data.message || '加载站点列表失败';
		}
	} catch (err) {
		console.error('加载站点列表失败:', err);
		error.value = '网络错误，请检查连接后重试';
	} finally {
		loading.value = false;
	}
};

const goToDetail = (stationId) => {
	uni.navigateTo({
		url: `/pages/stations/detail?id=${stationId}`
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
		margin-bottom: 40rpx;
}

.title {
		display: block;
		font-size: 48rpx;
		font-weight: bold;
		color: #333;
		margin-bottom: 10rpx;
}

.subtitle {
		display: block;
		font-size: 28rpx;
		color: #999;
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

.error-container {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		padding: 100rpx 0;
}

.error-icon {
		width: 200rpx;
		height: 200rpx;
		opacity: 0.3;
		margin-bottom: 30rpx;
}

.error-text {
		font-size: 28rpx;
		color: #999;
		margin-bottom: 40rpx;
		display: block;
		text-align: center;
}

.retry-btn {
		padding: 20rpx 60rpx;
		background: #007AFF;
		color: #fff;
		border-radius: 40rpx;
		font-size: 28rpx;
		border: none;
}

.stations-list {
		display: flex;
		flex-direction: column;
		gap: 20rpx;
}

.station-card {
		background: #fff;
		border-radius: 20rpx;
		padding: 30rpx;
		display: flex;
		justify-content: space-between;
		align-items: center;
		box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.08);
		transition: all 0.3s;
}

.station-card:active {
		transform: scale(0.98);
		background: #f8f8f8;
}

.station-info {
		flex: 1;
}

.station-name {
		display: block;
		font-size: 32rpx;
		font-weight: bold;
		color: #333;
		margin-bottom: 10rpx;
}

.station-line {
		display: block;
		font-size: 26rpx;
		color: #007AFF;
}

.station-status {
		display: flex;
		align-items: center;
}

.entrance-count {
		font-size: 24rpx;
		color: #999;
		margin-right: 20rpx;
}

.arrow {
		font-size: 48rpx;
		color: #ccc;
		font-weight: bold;
}
</style>

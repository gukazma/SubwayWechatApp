<template>
	<view class="container">
		<view class="loading-container" v-if="loading">
			<view class="loading-spinner"></view>
			<text class="loading-text">加载中...</text>
		</view>
		
		<view class="error-container" v-else-if="error">
			<image class="error-icon" src="/static/logo.png" mode="aspectFit"></image>
			<text class="error-text">{{ error }}</text>
			<button class="retry-btn" @click="loadStationDetail">重新加载</button>
		</view>
		
		<view class="station-detail" v-else>
			<view class="station-header">
				<text class="station-name">{{ station.name }}</text>
				<text class="station-line">{{ station.line }}</text>
			</view>
			
			<view class="entrances-section">
				<text class="section-title">出入口列表</text>
				
				<view class="entrances-list">
					<view 
						class="entrance-card" 
						v-for="entrance in entrances" 
						:key="entrance._id"
						@click="goToEntranceList(entrance._id)"
					>
						<view class="entrance-info">
							<text class="entrance-name">{{ entrance.name }}</text>
							<view class="entrance-status">
								<text class="staff-count">当前: {{ entrance.currentStaff }}人</text>
								<text class="staff-need">需要: {{ entrance.neededStaff }}人</text>
							</view>
						</view>
						<view class="entrance-action">
							<view class="status-badge" :class="entrance.status">
								<text v-if="entrance.status === 'short'">紧缺</text>
								<text v-else-if="entrance.status === 'normal'">正常</text>
								<text v-else>充足</text>
							</view>
							<text class="arrow">›</text>
						</view>
					</view>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref } from 'vue';
import { onLoad } from '@dcloudio/uni-app';
import { useUserStore } from '@/stores/user';

const userStore = useUserStore();
const stationId = ref('');
const station = ref({});
const entrances = ref([]);
const loading = ref(true);
const error = ref('');

onLoad(async (options) => {
	// 检查登录状态
	if (!userStore.checkLogin()) {
		return;
	}
	
	// 获取站点ID
	stationId.value = options.id || '';
	
	if (!stationId.value) {
		error.value = '站点ID不能为空';
		loading.value = false;
		return;
	}
	
	await loadStationDetail();
});

const loadStationDetail = async () => {
	loading.value = true;
	error.value = '';
	
	try {
		// 并行加载站点信息和出入口列表
		const [stationRes, entrancesRes] = await Promise.all([
			uni.request({
				url: `http://localhost:3000/api/stations/${stationId.value}`,
				method: 'GET',
				header: {
					'Authorization': `Bearer ${userStore.token}`
				}
			}),
			uni.request({
				url: `http://localhost:3000/api/stations/${stationId.value}/entrances`,
				method: 'GET',
				header: {
					'Authorization': `Bearer ${userStore.token}`
				}
			})
		]);
		
		// 处理站点信息
		if (stationRes.data.success && stationRes.data.data) {
			station.value = stationRes.data.data;
		} else {
			error.value = stationRes.data.message || '加载站点信息失败';
			loading.value = false;
			return;
		}
		
		// 处理出入口列表
		if (entrancesRes.data.success && entrancesRes.data.data) {
			entrances.value = entrancesRes.data.data;
		} else {
			entrances.value = [];
		}
		
	} catch (err) {
		console.error('加载站点详情失败:', err);
		error.value = '网络错误，请检查连接后重试';
	} finally {
		loading.value = false;
	}
};

const goToEntranceList = (entranceId) => {
	const entrance = entrances.value.find(e => e._id === entranceId);
	
	uni.navigateTo({
		url: `/pages/entrances/list?stationId=${stationId.value}&stationName=${station.value.name}&entranceId=${entranceId}&entranceName=${entrance?.name || ''}&entranceStatus=${entrance?.status || 'normal'}`
	});
};
</script>

<style scoped>
.container {
		min-height: 100vh;
		background: #f5f5f5;
		padding: 30rpx;
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

.station-detail {
		display: flex;
		flex-direction: column;
}

.station-header {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		border-radius: 20rpx;
		padding: 50rpx 40rpx;
		margin-bottom: 30rpx;
		box-shadow: 0 10rpx 30rpx rgba(102, 126, 234, 0.3);
}

.station-name {
		display: block;
		font-size: 48rpx;
		font-weight: bold;
		color: #fff;
		margin-bottom: 15rpx;
}

.station-line {
		display: block;
		font-size: 28rpx;
		color: rgba(255, 255, 255, 0.9);
}

.entrances-section {
		display: flex;
		flex-direction: column;
}

.section-title {
		font-size: 32rpx;
		font-weight: bold;
		color: #333;
		margin-bottom: 20rpx;
		display: block;
}

.entrances-list {
		display: flex;
		flex-direction: column;
		gap: 20rpx;
}

.entrance-card {
		background: #fff;
		border-radius: 20rpx;
		padding: 30rpx;
		display: flex;
		justify-content: space-between;
		align-items: center;
		box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.08);
		transition: all 0.3s;
}

.entrance-card:active {
		transform: scale(0.98);
		background: #f8f8f8;
}

.entrance-info {
		flex: 1;
}

.entrance-name {
		display: block;
		font-size: 32rpx;
		font-weight: bold;
		color: #333;
		margin-bottom: 15rpx;
}

.entrance-status {
		display: flex;
		flex-direction: column;
		gap: 8rpx;
}

.staff-count {
		font-size: 24rpx;
		color: #666;
		display: block;
}

.staff-need {
		font-size: 24rpx;
		color: #999;
		display: block;
}

.entrance-action {
		display: flex;
		align-items: center;
}

.status-badge {
		padding: 10rpx 25rpx;
		border-radius: 20rpx;
		font-size: 24rpx;
		font-weight: bold;
		margin-right: 20rpx;
}

.status-badge.short {
		background: #ff4d4f;
		color: #fff;
}

.status-badge.normal {
		background: #ffc107;
		color: #333;
}

.status-badge.full {
		background: #52c41a;
		color: #fff;
}

.arrow {
		font-size: 48rpx;
		color: #ccc;
		font-weight: bold;
}
</style>

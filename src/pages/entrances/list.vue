<template>
	<view class="container">
		<view class="header">
			<text class="title">{{ entranceName }}</text>
			<text class="subtitle">{{ stationName }}</text>
		</view>
		
		<view class="status-card">
			<view class="status-info">
				<text class="status-label">当前状态</text>
				<view class="status-badge" :class="entranceStatus">
					<text v-if="entranceStatus === 'short'">人员紧缺</text>
					<text v-else-if="entranceStatus === 'normal'">人员正常</text>
					<text v-else>人员充足</text>
				</view>
			</view>
			<view class="tips">
				<text class="tips-text">该出入口需要支援人员协助工作</text>
			</view>
		</view>
		
		<view class="action-section">
			<button 
				class="booking-btn" 
				@click="goToBooking"
				:disabled="entranceStatus === 'full'"
			>
				<text>{{ entranceStatus === 'full' ? '人员充足，暂不需要支援' : '立即报名支援' }}</text>
			</button>
		</view>
		
		<view class="info-section">
			<view class="info-card">
				<text class="info-title">支援说明</text>
				<text class="info-text">1. 报名成功后，请准时到达指定出入口</text>
				<text class="info-text">2. 支援期间请听从现场工作人员安排</text>
				<text class="info-text">3. 如需取消报名，请在"我的支援记录"中操作</text>
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
const stationName = ref('');
const entranceId = ref('');
const entranceName = ref('');
const entranceStatus = ref('normal');

onLoad((options) => {
	// 检查登录状态
	if (!userStore.checkLogin()) {
		return;
	}
	
	// 获取参数
	stationId.value = options.stationId || '';
	stationName.value = options.stationName || '';
	entranceId.value = options.entranceId || '';
	entranceName.value = options.entranceName || '';
	entranceStatus.value = options.entranceStatus || 'normal';
	
	// 验证参数
	if (!stationId.value || !entranceId.value) {
		uni.showToast({
			title: '参数错误',
			icon: 'none'
		});
		setTimeout(() => {
			uni.navigateBack();
		}, 1500);
	}
});

const goToBooking = () => {
	if (entranceStatus.value === 'full') {
		uni.showToast({
			title: '该出入口人员充足，暂不需要支援',
			icon: 'none'
		});
		return;
	}
	
	uni.navigateTo({
		url: `/pages/booking/confirm?stationId=${stationId.value}&stationName=${stationName.value}&entranceId=${entranceId.value}&entranceName=${entranceName.value}&entranceStatus=${entranceStatus.value}`
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

.status-card {
		background: #fff;
		border-radius: 20rpx;
		padding: 40rpx;
		margin-bottom: 30rpx;
		box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.08);
}

.status-info {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 20rpx;
}

.status-label {
		font-size: 32rpx;
		font-weight: bold;
		color: #333;
}

.status-badge {
		padding: 15rpx 40rpx;
		border-radius: 30rpx;
		font-size: 28rpx;
		font-weight: bold;
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

.tips {
		padding-top: 20rpx;
		border-top: 1rpx solid #f0f0f0;
}

.tips-text {
		font-size: 26rpx;
		color: #999;
		line-height: 1.6;
		display: block;
}

.action-section {
		margin-bottom: 30rpx;
}

.booking-btn {
		width: 100%;
		height: 100rpx;
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		color: #fff;
		border-radius: 50rpx;
		font-size: 32rpx;
		font-weight: bold;
		border: none;
		box-shadow: 0 10rpx 30rpx rgba(102, 126, 234, 0.3);
}

.booking-btn:active {
		transform: scale(0.98);
}

.booking-btn[disabled] {
		background: #ccc;
		box-shadow: none;
}

.info-section {
		margin-bottom: 30rpx;
}

.info-card {
		background: #fff;
		border-radius: 20rpx;
		padding: 30rpx;
		box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.08);
}

.info-title {
		display: block;
		font-size: 30rpx;
		font-weight: bold;
		color: #333;
		margin-bottom: 20rpx;
}

.info-text {
		display: block;
		font-size: 26rpx;
		color: #666;
		line-height: 1.8;
		margin-bottom: 15rpx;
}

.info-text:last-child {
		margin-bottom: 0;
}
</style>

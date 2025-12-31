<template>
	<view class="container">
		<view class="header">
			<text class="title">我的支援记录</text>
		</view>
		
		<view class="supports-list" v-if="supports.length > 0">
			<view 
					class="support-card"
					v-for="support in supports"
					:key="support._id"
			>
					<view class="support-info">
							<view class="support-header">
									<text class="station-name">{{ support.stationName }}</text>
									<view class="status-badge" :class="support.status">
											<text v-if="support.status === 'pending'">待确认</text>
											<text v-else-if="support.status === 'confirmed'">已确认</text>
											<text v-else-if="support.status === 'completed'">已完成</text>
											<text v-else-if="support.status === 'cancelled'">已取消</text>
									</view>
							</view>
							<text class="entrance-name">{{ support.entranceName }}</text>
							<text class="support-date">{{ formatDate(support.supportDate) }}</text>
							<text class="support-time">{{ support.startTime }} - {{ support.endTime }}</text>
					</view>
					<view class="support-action">
							<button 
									v-if="support.status === 'pending'"
									class="cancel-btn"
									@click="handleCancel(support._id)"
							>
									<text>取消报名</text>
							</button>
					</view>
			</view>
		</view>
		
		<view class="empty-state" v-else>
			<image class="empty-icon" src="/static/logo.png" mode="aspectFit"></image>
			<text class="empty-text">暂无支援记录</text>
		</view>
	</view>
</template>

<script setup>
import { ref } from 'vue';
import { onLoad } from '@dcloudio/uni-app';
import { useUserStore } from '@/stores/user';

const userStore = useUserStore();
const supports = ref([]);

onLoad(async (options) => {
	await loadSupports();
});

const loadSupports = async () => {
	try {
		const res = await uni.request({
			url: 'http://localhost:3000/api/supports',
			method: 'GET',
			header: {
				'Authorization': `Bearer ${userStore.token}`
			}
		});
		
		if (res.data.success) {
			supports.value = res.data.data;
		} else {
			uni.showToast({
				title: '加载支援记录失败',
				icon: 'none'
			});
		}
	} catch (error) {
		console.error('加载支援记录失败:', error);
		uni.showToast({
			title: '加载支援记录失败',
			icon: 'none'
		});
	}
};

const handleCancel = async (supportId) => {
	uni.showModal({
		title: '确认取消',
		content: '确定要取消这次支援报名吗？',
		success: async (res) => {
			if (res.confirm) {
				try {
					const cancelRes = await uni.request({
						url: `http://localhost:3000/api/supports/${supportId}/cancel`,
						method: 'POST',
						header: {
							'Authorization': `Bearer ${userStore.token}`
						}
					});
					
					if (cancelRes.data.success) {
						uni.showToast({
							title: '已取消报名',
							icon: 'success'
						});
						await loadSupports();
					} else {
						uni.showToast({
							title: cancelRes.data.message || '取消失败',
							icon: 'none'
						});
					}
				} catch (error) {
					console.error('取消报名失败:', error);
					uni.showToast({
						title: '取消失败，请重试',
						icon: 'none'
					});
				}
			}
		}
	});
};

const formatDate = (date) => {
	if (!date) return '';
	const d = new Date(date);
	const year = d.getFullYear();
	const month = String(d.getMonth() + 1).padStart(2, '0');
	const day = String(d.getDate()).padStart(2, '0');
	return `${year}-${month}-${day}`;
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

.supports-list {
		display: flex;
		flex-direction: column;
		gap: 20rpx;
}

.support-card {
		background: #fff;
		border-radius: 20rpx;
		padding: 30rpx;
		display: flex;
		justify-content: space-between;
		align-items: center;
		box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.08);
}

.support-info {
		flex: 1;
}

.support-header {
		display: flex;
		align-items: center;
		margin-bottom: 15rpx;
}

.station-name {
		font-size: 32rpx;
		font-weight: bold;
		color: #333;
		margin-right: 20rpx;
}

.status-badge {
		padding: 8rpx 20rpx;
		border-radius: 20rpx;
		font-size: 24rpx;
		font-weight: bold;
}

.status-badge.pending {
		background: #ffc107;
		color: #333;
}

.status-badge.confirmed {
		background: #007AFF;
		color: #fff;
}

.status-badge.completed {
		background: #52c41a;
		color: #fff;
}

.status-badge.cancelled {
		background: #999;
		color: #fff;
}

.entrance-name {
		font-size: 26rpx;
		color: #666;
		display: block;
		margin-bottom: 5rpx;
}

.support-date {
		font-size: 26rpx;
		color: #999;
		display: block;
		margin-bottom: 5rpx;
}

.support-time {
		font-size: 26rpx;
		color: #666;
		display: block;
}

.support-action {
		display: flex;
		align-items: center;
}

.cancel-btn {
		padding: 15rpx 30rpx;
		background: #ff4d4f;
		color: #fff;
		border-radius: 30rpx;
		font-size: 26rpx;
		border: none;
}

.empty-state {
		text-align: center;
		padding: 100rpx 0;
}

.empty-icon {
		width: 200rpx;
		height: 200rpx;
		opacity: 0.3;
		margin-bottom: 30rpx;
}

.empty-text {
		font-size: 28rpx;
		color: #999;
		display: block;
}
</style>

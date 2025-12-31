<template>
	<view class="container">
		<view class="header">
			<text class="title">确认支援报名</text>
		</view>
		
		<view class="booking-info" v-if="!loading">
			<view class="info-card">
				<text class="label">站点</text>
				<text class="value">{{ stationName }}</text>
			</view>
			<view class="info-card">
				<text class="label">出入口</text>
				<text class="value">{{ entranceName }}</text>
			</view>
			<view class="info-card">
				<text class="label">当前状态</text>
				<view class="status-badge" :class="entranceStatus">
					<text v-if="entranceStatus === 'short'">人员紧缺</text>
					<text v-else-if="entranceStatus === 'normal'">人员正常</text>
					<text v-else>人员充足</text>
				</view>
			</view>
		</view>
		
		<view class="form-section">
			<view class="form-item">
				<text class="form-label">选择日期</text>
				<picker
					mode="date"
					:value="formData.supportDate"
					:start="minDate"
					:end="maxDate"
					@change="onDateChange"
					style="width: 100%; max-width: 400rpx; flex: 1;"
				>
					<view class="picker-value">
						<text :class="{ placeholder: !formData.supportDate }">
							{{ formData.supportDate || '请选择日期' }}
						</text>
						<text class="arrow">›</text>
					</view>
				</picker>
			</view>
			
			<view class="form-item">
				<text class="form-label">开始时间</text>
				<picker
					mode="time"
					:value="formData.startTime"
					@change="onStartTimeChange"
					style="width: 100%; max-width: 400rpx; flex: 1;"
				>
					<view class="picker-value">
						<text :class="{ placeholder: !formData.startTime }">
							{{ formData.startTime || '请选择开始时间' }}
						</text>
						<text class="arrow">›</text>
					</view>
				</picker>
			</view>
			
			<view class="form-item">
				<text class="form-label">结束时间</text>
				<picker
					mode="time"
					:value="formData.endTime"
					@change="onEndTimeChange"
					style="width: 100%; max-width: 400rpx; flex: 1;"
				>
					<view class="picker-value">
						<text :class="{ placeholder: !formData.endTime }">
							{{ formData.endTime || '请选择结束时间' }}
						</text>
						<text class="arrow">›</text>
					</view>
				</picker>
			</view>
		</view>
		
		<view class="tips">
			<text class="tips-text">提示：报名成功后，请准时到达指定出入口支援</text>
		</view>
		
		<view class="submit-section">
			<button 
				class="submit-btn" 
				@click="handleSubmit"
				:disabled="submitting || !isFormValid"
			>
				<text>{{ submitting ? '提交中...' : '确认报名' }}</text>
			</button>
		</view>
	</view>
</template>

<script setup>
import { ref, computed } from 'vue';
import { onLoad } from '@dcloudio/uni-app';
import { useUserStore } from '@/stores/user';

const userStore = useUserStore();
const loading = ref(true);
const submitting = ref(false);

const stationId = ref('');
const entranceId = ref('');
const stationName = ref('');
const entranceName = ref('');
const entranceStatus = ref('');

const formData = ref({
	supportDate: '',
	startTime: '',
	endTime: ''
});

// 日期范围
const minDate = computed(() => {
	const today = new Date();
	return formatDate(today);
});

const maxDate = computed(() => {
	const max = new Date();
	max.setDate(max.getDate() + 30);
	return formatDate(max);
});

// 表单验证
const isFormValid = computed(() => {
	return formData.value.supportDate && 
	       formData.value.startTime && 
	       formData.value.endTime;
});

onLoad(async (options) => {
	// 检查登录状态
	if (!userStore.checkLogin()) {
		return;
	}
	
	// 获取参数
	stationId.value = options.stationId || '';
	entranceId.value = options.entranceId || '';
	stationName.value = options.stationName || '';
	entranceName.value = options.entranceName || '';
	entranceStatus.value = options.entranceStatus || 'normal';
	
	loading.value = false;
});

const onDateChange = (e) => {
	formData.value.supportDate = e.detail.value;
};

const onStartTimeChange = (e) => {
	formData.value.startTime = e.detail.value;
};

const onEndTimeChange = (e) => {
	formData.value.endTime = e.detail.value;
};

const handleSubmit = async () => {
	// 验证表单
	if (!isFormValid.value) {
		uni.showToast({
			title: '请填写完整信息',
			icon: 'none'
		});
		return;
	}
	
	// 验证时间
	if (formData.value.startTime >= formData.value.endTime) {
		uni.showToast({
			title: '结束时间必须大于开始时间',
			icon: 'none'
		});
		return;
	}
	
	submitting.value = true;
	
	try {
		const res = await uni.request({
			url: 'http://localhost:3000/api/supports',
			method: 'POST',
			header: {
				'Authorization': `Bearer ${userStore.token}`,
				'Content-Type': 'application/json'
			},
			data: {
				stationId: stationId.value,
				entranceId: entranceId.value,
				supportDate: formData.value.supportDate,
				startTime: formData.value.startTime,
				endTime: formData.value.endTime
			}
		});
		
		if (res.data.success) {
			uni.showToast({
				title: '报名成功',
				icon: 'success',
				duration: 1500
			});
			
			// 延迟跳转到我的支援记录
			setTimeout(() => {
				uni.redirectTo({
					url: '/pages/mine/supports'
				});
			}, 1500);
		} else {
			uni.showToast({
				title: res.data.message || '报名失败',
				icon: 'none'
			});
		}
	} catch (error) {
		console.error('报名失败:', error);
		uni.showToast({
			title: '网络错误，请重试',
			icon: 'none'
		});
	} finally {
		submitting.value = false;
	}
};

const formatDate = (date) => {
	const year = date.getFullYear();
	const month = String(date.getMonth() + 1).padStart(2, '0');
	const day = String(date.getDate()).padStart(2, '0');
	return `${year}-${month}-${day}`;
};
</script>

<style scoped>
.container {
		min-height: 100vh;
		background: #f5f5f5;
		padding: 30rpx;
		box-sizing: border-box;
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

.booking-info {
		display: flex;
		flex-direction: column;
		gap: 20rpx;
		margin-bottom: 40rpx;
}

.info-card {
		background: #fff;
		border-radius: 20rpx;
		padding: 30rpx;
		display: flex;
		justify-content: space-between;
		align-items: center;
		box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.08);
}

.label {
		font-size: 28rpx;
		color: #999;
}

.value {
		font-size: 32rpx;
		font-weight: bold;
		color: #333;
}

.status-badge {
		padding: 10rpx 30rpx;
		border-radius: 20rpx;
		font-size: 26rpx;
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

.form-section {
		background: #fff;
		border-radius: 20rpx;
		padding: 30rpx;
		margin-bottom: 30rpx;
		box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.08);
}

.form-item {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 20rpx 0;
		border-bottom: 1rpx solid #f0f0f0;
		width: 100%;
		box-sizing: border-box;
	}

.form-item:last-child {
		border-bottom: none;
}

.form-label {
		font-size: 30rpx;
		color: #333;
}

.picker-value {
		display: flex;
		align-items: center;
		min-width: 300rpx;
		justify-content: flex-end;
		width: 100%;
		max-width: 400rpx;
	}

.picker-value text:first-child {
		font-size: 30rpx;
		color: #333;
}

.picker-value text.placeholder {
		color: #ccc;
}

.arrow {
		font-size: 48rpx;
		color: #ccc;
		font-weight: bold;
		margin-left: 20rpx;
}

.tips {
		padding: 0 30rpx;
		margin-bottom: 40rpx;
}

.tips-text {
		font-size: 24rpx;
		color: #999;
		line-height: 1.6;
		display: block;
}

.submit-section {
		padding: 0 30rpx;
}

.submit-btn {
		width: 100%;
		height: 100rpx;
		background: #007AFF;
		color: #fff;
		border-radius: 50rpx;
		font-size: 32rpx;
		font-weight: bold;
		border: none;
		box-shadow: 0 10rpx 30rpx rgba(0, 122, 255, 0.3);
}

.submit-btn:active {
		transform: scale(0.98);
}

.submit-btn[disabled] {
		background: #ccc;
		box-shadow: none;
}
</style>

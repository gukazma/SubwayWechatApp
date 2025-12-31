<template>
	<view class="login-container">
		<view class="login-header">
			<image class="logo" src="/static/logo.png" mode="aspectFit"></image>
			<text class="app-name">地铁支援系统</text>
			<text class="app-desc">地铁站点人员支援管理平台</text>
		</view>
		
		<view class="login-content">
			<view class="loading-overlay" v-if="loading">
				<text class="loading-text">登录中...</text>
			</view>
			
			<button 
				class="login-btn" 
				@click="handleWechatLogin"
				:disabled="loading"
			>
				<text class="btn-text">{{ loading ? '登录中...' : '微信授权登录' }}</text>
			</button>
			
			<text class="tips">点击登录即表示同意《用户协议》和《隐私政策》</text>
		</view>
	</view>
</template>

<script setup>
import { ref } from 'vue';
import { onLoad } from '@dcloudio/uni-app';
import { useUserStore } from '@/stores/user';

const userStore = useUserStore();
const loading = ref(false);

onLoad((options) => {
	// 检查是否已登录
	if (userStore.isLoggedIn) {
		// 已登录，跳转到首页
		uni.reLaunch({
			url: '/pages/index/index'
		});
	}
});

const handleWechatLogin = async () => {
	loading.value = true;
	
	try {
		// H5环境使用模拟code
		// 微信小程序环境使用 uni.login()
		let code = '';
		
		// #ifdef H5
		// H5环境使用模拟code
		code = 'mock_h5_code_' + Date.now();
		// #endif
		
		// #ifdef MP-WEIXIN
		// 微信小程序环境
		const loginRes = await uni.login({
			provider: 'weixin'
		});
		code = loginRes.code;
		// #endif
		
		if (!code) {
			uni.showToast({
				title: '获取授权码失败',
				icon: 'none'
			});
			return;
		}
		
		// 直接使用 uni.request 调用后端登录接口
		const res = await uni.request({
			url: 'http://localhost:3000/api/auth/login',
			method: 'POST',
			header: {
				'Content-Type': 'application/json'
			},
			data: {
				code: code
			}
		});
		
		if (res.data.success && res.data.data) {
			// 保存 token 和用户信息
			userStore.setToken(res.data.data.token);
			userStore.setUserInfo(res.data.data.user);
			
			uni.showToast({
				title: '登录成功',
				icon: 'success',
				duration: 1500
			});
			
			// 延迟跳转到首页
			setTimeout(() => {
				uni.reLaunch({
					url: '/pages/index/index'
				});
			}, 1500);
		} else {
			uni.showToast({
				title: res.data.message || '登录失败',
				icon: 'none',
				duration: 2000
			});
		}
	} catch (error) {
		console.error('登录失败:', error);
		uni.showToast({
			title: error.message || '登录失败，请重试',
			icon: 'none',
			duration: 2000
		});
	} finally {
		loading.value = false;
	}
};
</script>

<style scoped>
.login-container {
		min-height: 100vh;
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		display: flex;
		flex-direction: column;
		padding: 100rpx 60rpx;
}

.login-header {
		text-align: center;
		margin-bottom: 120rpx;
}

.logo {
		width: 160rpx;
		height: 160rpx;
		margin-bottom: 40rpx;
}

.app-name {
		display: block;
		font-size: 48rpx;
		font-weight: bold;
		color: #fff;
		margin-bottom: 20rpx;
}

.app-desc {
		display: block;
		font-size: 28rpx;
		color: rgba(255, 255, 255, 0.8);
}

.login-content {
		position: relative;
		display: flex;
		flex-direction: column;
		align-items: center;
}

.loading-overlay {
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background: rgba(255, 255, 255, 0.3);
		display: flex;
		align-items: center;
		justify-content: center;
		border-radius: 20rpx;
}

.loading-text {
		color: #fff;
		font-size: 32rpx;
		font-weight: bold;
}

.login-btn {
		width: 100%;
		height: 100rpx;
		background: #fff;
		border-radius: 50rpx;
		display: flex;
		align-items: center;
		justify-content: center;
		box-shadow: 0 10rpx 30rpx rgba(0, 0, 0, 0.2);
		border: none;
		margin-bottom: 40rpx;
}

.login-btn:active {
		transform: scale(0.98);
}

.login-btn[disabled] {
		opacity: 0.7;
}

.btn-text {
		font-size: 32rpx;
		font-weight: bold;
		color: #667eea;
}

.tips {
		font-size: 24rpx;
		color: rgba(255, 255, 255, 0.7);
		text-align: center;
		line-height: 1.6;
}
</style>

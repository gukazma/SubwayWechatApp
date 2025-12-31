import { defineStore } from 'pinia';

export const useUserStore = defineStore('user', {
	state: () => ({
		token: '',
		userInfo: null,
		isLoggedIn: false,
		loading: false,
		error: null
	}),

	getters: {
		// 获取用户昵称
		nickname: (state) => {
			return state.userInfo?.nickname || '未登录';
		},
		// 获取用户头像
		avatar: (state) => {
			return state.userInfo?.avatarUrl || '/static/logo.png';
		}
	},

	actions: {
		// 设置 token
		setToken(token) {
			this.token = token;
			this.isLoggedIn = !!token;
			// 持久化到本地存储
			if (token) {
				uni.setStorageSync('token', token);
			} else {
				uni.removeStorageSync('token');
			}
		},

		// 设置用户信息
		setUserInfo(userInfo) {
			this.userInfo = userInfo;
			// 持久化到本地存储
			if (userInfo) {
				uni.setStorageSync('userInfo', userInfo);
			} else {
				uni.removeStorageSync('userInfo');
			}
		},

		// 设置加载状态
		setLoading(loading) {
			this.loading = loading;
		},

		// 设置错误信息
		setError(error) {
			this.error = error;
		},

		// 恢复登录状态
		restoreLoginState() {
			try {
				const token = uni.getStorageSync('token');
				const userInfo = uni.getStorageSync('userInfo');
				
				if (token && userInfo) {
					this.token = token;
					this.userInfo = userInfo;
					this.isLoggedIn = true;
					console.log('登录状态已恢复');
				} else {
					this.logout();
				}
			} catch (error) {
				console.error('恢复登录状态失败:', error);
				this.logout();
			}
		},

		// 微信登录
		async wechatLogin(code) {
			this.setLoading(true);
			this.setError(null);
			
			try {
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
					this.setToken(res.data.data.token);
					this.setUserInfo(res.data.data.user);
					return { success: true, data: res.data.data };
				} else {
					this.setError(res.data.message || '登录失败');
					return { success: false, message: res.data.message || '登录失败' };
				}
			} catch (error) {
				console.error('微信登录失败:', error);
				this.setError(error.message || '登录失败，请重试');
				return { success: false, message: error.message || '登录失败，请重试' };
			} finally {
				this.setLoading(false);
			}
		},

		// 登出
		logout() {
			this.token = '';
			this.userInfo = null;
			this.isLoggedIn = false;
			this.error = null;
			
			// 清除本地存储
			uni.removeStorageSync('token');
			uni.removeStorageSync('userInfo');
			
			console.log('用户已登出');
		},

		// 检查登录状态
		checkLogin() {
			if (!this.isLoggedIn || !this.token) {
				uni.showToast({
					title: '请先登录',
					icon: 'none',
					duration: 2000
				});
				
				// 跳转到登录页
				setTimeout(() => {
					uni.reLaunch({
						url: '/pages/login/index'
					});
				}, 500);
				
				return false;
			}
			return true;
		}
	}
});

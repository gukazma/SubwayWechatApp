<script>
export default {
  onLaunch: function () {
    console.log('App Launch')
  },
  onShow: function () {
    console.log('App Show')
  },
  onHide: function () {
    console.log('App Hide')
  },
}
</script>

<style>
/*每个页面公共css */
page {
	box-sizing: border-box;
}

/* Fix picker popup overflow issue in H5 mode - move entire popup to fit screen */
.uni-picker-container {
	max-width: 100vw !important;
	overflow: hidden !important;
	position: fixed !important;
	left: 0 !important;
	right: 0 !important;
	transform: translateX(0) !important;
}

.uni-picker-mask {
	max-width: 100vw !important;
}

.uni-picker-content {
	max-width: 100vw !important;
	overflow: hidden !important;
}

/* Ensure all picker popups stay within viewport */
.uni-picker-view {
	max-width: 100vw !important;
}

/* Fix picker modal positioning */
.uni-picker-view-mask {
	max-width: 100vw !important;
}

.uni-picker-view-indicator {
	max-width: 100vw !important;
}

/* Ensure picker popup doesn't overflow */
.uni-picker {
	max-width: 100vw !important;
	left: 0 !important;
	right: 0 !important;
	transform: none !important;
}

/* Fix picker header and footer positioning */
.uni-picker-header {
	max-width: 100vw !important;
	box-sizing: border-box !important;
	left: 0 !important;
	right: 0 !important;
}

.uni-picker-footer {
	max-width: 100vw !important;
	box-sizing: border-box !important;
	position: relative !important;
	left: 0 !important;
	right: 0 !important;
}

/* Fix picker action buttons (Done/Cancel buttons) */
.uni-picker-action {
	max-width: 100vw !important;
	padding: 0 30rpx !important;
	box-sizing: border-box !important;
}

/* Restore default button positioning */
.uni-picker-action .uni-picker-action-confirm {
	/* Reset to default positioning */
}

.uni-picker-action .uni-picker-action-cancel {
	/* Reset to default positioning */
}

/* Additional fix for picker popup positioning */
.uni-picker-wrapper {
	max-width: 100vw !important;
	left: 0 !important;
	right: 0 !important;
}

/* Fix for picker modal */
.uni-picker-modal {
	max-width: 100vw !important;
	left: 0 !important;
	right: 0 !important;
	transform: translateX(0) !important;
}
</style>

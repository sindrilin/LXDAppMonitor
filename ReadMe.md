**LXDAppMonitor**
====
`LXDAppMonitor`是一套轻量级的应用性能管理组件。

为了实现高效率，项目中对`LXDDispatchQueue`多线程组件有比较强的依赖关系。`LXDAppMonitor`目前能够完成以下的监控任务：

- `LXDAppFluencyMonitor` 应用卡顿检测

		[FLUENCYMONITOR startMonitoring];
- `LXDFPSMonitor` FPS监控器

		[FPS_MONITOR startMonitoring];
- `LXDDNSInterceptor` DNS解析器
	 重新实现`canonicalRequestForRequest`完成请求的重定向
- `LXDResourceMonitor` 系统资源监控器

		[RESOURCE_MONITOR startMonitoring];
		
- `LXDCrashMonitor` 异常监控

		[LXDCrashMonitor startMonitoring];

**演示效果**
====
![](http://upload-images.jianshu.io/upload_images/783864-3adef6f9d8cabc88.gif?imageMogr2/auto-orient/strip)

**性能**
====
采用`YYDispatchQueuePool`的相同多线程封装技术，对关键数据采集异步处理。所有监控数据展示器采用异步文本渲染方式，对性能几乎无影响。数据展示控件只在`DEBUG`模式下生效。

**警告**
====
当前`demo`由于笔者公司不实现服务器数据收集业务，部分功能仅能在开发阶段使用。提交商店审核前需删除`DNS`劫持部分代码或者移除此功能


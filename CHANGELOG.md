## 0.1.1

* README 拆分为中英双语（`README.md` 为英文主文档，`README.zh-CN.md` 为中文版），顶部提供语言切换。
* 安装章节改用 pub.dev 依赖写法。

## 0.1.0

* Initial release.
* 系统代理抓包能力，支持 Android / iOS / macOS / Windows。
* 对外 API：
  * `DebugProxy.enableFromSystem()` — 启动时读一次系统代理，若有则安装 `HttpOverrides.global`，所有 `dart:io` HTTP/WebSocket 自动走代理。
  * `DebugProxy.isActive` — 代理态查询（供 STOMP 等模块判断用）。

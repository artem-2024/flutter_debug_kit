## 0.1.0

* Initial release.
* 系统代理抓包能力，支持 Android / iOS / macOS / Windows。
* 对外 API：
  * `DebugProxy.enableFromSystem()` — 启动时读一次系统代理，若有则安装 `HttpOverrides.global`，所有 `dart:io` HTTP/WebSocket 自动走代理。
  * `DebugProxy.isActive` — 代理态查询（供 STOMP 等模块判断用）。

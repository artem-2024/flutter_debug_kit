## 0.1.2

* 新增 `DebugProxy.normalizeWsUrl(url)`：走代理时把未显式带端口的 ws/wss URL 补上默认端口（ws→80，wss→443），避免 HTTP 代理收到 `CONNECT host:0` 导致 bind 失败。直连路径不受影响。
* 典型用法（stomp_dart_client 等走 `WebSocket.connect` 的场景）：`stomp.connect(url: DebugProxy.normalizeWsUrl(url));`。

## 0.1.1

* README 拆分为中英双语（`README.md` 为英文主文档，`README.zh-CN.md` 为中文版），顶部提供语言切换。
* 安装章节改用 pub.dev 依赖写法。

## 0.1.0

* Initial release.
* 系统代理抓包能力，支持 Android / iOS / macOS / Windows。
* 对外 API：
  * `DebugProxy.enableFromSystem()` — 启动时读一次系统代理，若有则安装 `HttpOverrides.global`，所有 `dart:io` HTTP/WebSocket 自动走代理。
  * `DebugProxy.isActive` — 代理态查询（供 STOMP 等模块判断用）。

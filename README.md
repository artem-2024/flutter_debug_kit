# flutter_debug_kit

Flutter 多端调试工具包。首版提供**系统代理抓包**能力：启动时读一次当前系统代理，若有就挂 `HttpOverrides.global`，让进程内所有 `dart:io` HTTP/WebSocket 自动走代理，方便 Charles 等工具抓包。

支持平台：Android / iOS / macOS / Windows。

## 原理

- Android：`System.getProperty("http.proxyHost/port")`
- iOS / macOS：`CFNetworkCopySystemProxySettings`
- Windows：`WinHttpGetIEProxyConfigForCurrentUser`
- 读到代理 → `HttpClient.findProxy = 'PROXY host:port'`，并开 `badCertificateCallback` 容忍 Charles 自签证书
- 读不到代理 → 不安装 overrides，行为等同未调用（零副作用）

**必须冷启动生效**：插件只在 `enableFromSystem()` 被调用的那一刻读一次代理，不监听后续变化。

## 安装

`pubspec.yaml`：

```yaml
dependencies:
  flutter_debug_kit:
    git:
      url: https://github.com/<org>/flutter_debug_kit.git
      ref: main
```

## 使用

```dart
import 'package:flutter_debug_kit/flutter_debug_kit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DebugProxy.enableFromSystem();   // 建议只在 TEST / 调试入口调用
  runApp(const MyApp());
}
```

状态查询（供 STOMP 等模块判断是否在代理态）：

```dart
if (DebugProxy.isActive) { /* ... */ }
```

UAT / PROD 入口**不要**调用 `enableFromSystem()`，插件就完全不介入。

## Android 宿主额外配置（必须）

Android 默认不信任用户安装的 CA 证书，也不允许 cleartext。抓包时必须在**宿主 App 侧**补这两处配置。插件不会自动改你的 manifest。

### 1. `android/app/src/main/res/xml/network_security_config.xml`

新建：

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system"/>
            <certificates src="user"/>
        </trust-anchors>
    </base-config>
</network-security-config>
```

### 2. `android/app/src/main/AndroidManifest.xml`

`<application>` 节点加两个属性：

```xml
<application
    android:usesCleartextTraffic="true"
    android:networkSecurityConfig="@xml/network_security_config"
    ... >
```

> **安全提示**：信任用户 CA 会降低 App 的 TLS 安全等级。建议只在 debug / test 构建里启用（用 `src/debug/` 或 flavor-specific manifest 覆盖 release manifest），正式包不要带。

## 四端抓包操作速查

详见 Charles / Fiddler 等工具文档。关键点：

- **Android 真机**：手机 Wi-Fi 设代理 + 安装用户 CA，冷启动 App
- **iOS 真机**：Wi-Fi 设代理 + 安装描述文件并在"证书信任设置"里打开开关，冷启动 App
- **iOS 模拟器 / macOS**：在 Charles 开 "macOS Proxy"，Mac 上信任 CA，冷启动 App
- **Windows**：Charles 开 "Windows Proxy"，装 CA 到"受信任的根证书颁发机构"，冷启动 App

## 已知限制

- STOMP 协议本身走自定义帧，不是标准 HTTPS，因此抓包工具里看到的仍是 TCP；这不是本插件的问题
- 插件作为服务端接收的入站请求抓不到（本机没发起请求）

# flutter_debug_kit

[English](README.md) | [简体中文](README.zh-CN.md)

Flutter multi-platform debugging toolkit. The first capability it ships is **system-proxy packet capture**: at app launch, read the current system HTTP proxy, and if one is configured, install `HttpOverrides.global` so that **every** `dart:io` HTTP / WebSocket client (including Dio) routes through it — making Charles / Fiddler capture work with zero code changes in your networking layer.

Supported platforms: **Android / iOS / macOS / Windows**.

## How it works

- Android: `System.getProperty("http.proxyHost/port")`
- iOS / macOS: `CFNetworkCopySystemProxySettings`
- Windows: `WinHttpGetIEProxyConfigForCurrentUser`
- Proxy detected → `HttpClient.findProxy = 'PROXY host:port'` + `badCertificateCallback` returns `true` so Charles's self-signed CA is accepted
- No proxy detected → nothing is installed; behavior is identical to not calling the plugin (zero cost)

**Cold-start required**: the plugin reads the proxy exactly once, when `enableFromSystem()` is called. Changing the system proxy at runtime has no effect until the app is fully restarted.

## Install

```yaml
dependencies:
  flutter_debug_kit: ^0.1.0
```

## Usage

```dart
import 'package:flutter_debug_kit/flutter_debug_kit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DebugProxy.enableFromSystem();   // only call in debug / test entry points
  runApp(const MyApp());
}
```

Query proxy state (useful for modules like STOMP that may need to react):

```dart
if (DebugProxy.isActive) { /* ... */ }
```

**Do not** call `enableFromSystem()` in your UAT / PROD entry points. Skipping the call means the plugin is fully inert.

## Android host app configuration (required)

Android does not trust user-installed CAs by default, nor does it allow cleartext traffic. Packet capture requires both to be enabled **in your host app** — the plugin cannot (and should not) modify your manifest for you.

### 1. `android/app/src/main/res/xml/network_security_config.xml`

Create the file:

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

Add these two attributes to `<application>`:

```xml
<application
    android:usesCleartextTraffic="true"
    android:networkSecurityConfig="@xml/network_security_config"
    ... >
```

> **Security note**: trusting user CAs lowers your app's TLS security. Apply this config to **debug / test builds only** (e.g. use `src/debug/AndroidManifest.xml` or a dedicated flavor manifest so your release build is unaffected).

## Platform capture cheat sheet

See the Charles / Fiddler manuals for full details. Key points:

- **Android real device**: set the Wi-Fi HTTP proxy to your Charles host, install the Charles user CA, cold-start the app.
- **iOS real device**: set the Wi-Fi HTTP proxy, install the profile, **and flip the switch under Settings → General → About → Certificate Trust Settings**, cold-start the app.
- **iOS simulator / macOS**: enable "macOS Proxy" in Charles, trust the Charles root cert on your Mac, cold-start the app.
- **Windows**: enable "Windows Proxy" in Charles, install the CA into "Trusted Root Certification Authorities", cold-start the app.

## Known limitations

- STOMP runs over its own framing layer on top of TCP, not standard HTTPS. Capture tools will see the raw TCP bytes but will not decode STOMP frames — this is not a plugin limitation.
- Inbound requests received by the device (the device acting as server) cannot be captured — the local process did not originate them.

## License

[MIT](LICENSE)

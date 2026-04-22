import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('dev.flutter_debug_kit/system_proxy');

/// 系统代理抓包能力。启动时调 [enableFromSystem] 一次即可。
///
/// - 读到系统代理 → 安装 [HttpOverrides.global]，进程内所有 dart:io
///   HttpClient（含 Dio、WebSocket 握手等）自动走代理。
/// - 读不到代理 / 调用失败 → 无副作用，行为等同未调用。
///
/// 建议只在 TEST / 调试入口调用，UAT / PROD 入口不调。
class DebugProxy {
  DebugProxy._();

  /// 是否处于代理态。其他模块（如 STOMP）需兼容处理可读它。
  static bool get isActive => HttpOverrides.current is _DebugProxyHttpOverrides;

  /// 启动时调一次。读一次系统代理；有值就装 [HttpOverrides.global]。
  static Future<void> enableFromSystem() async {
    String? proxy;
    try {
      proxy = await _channel.invokeMethod<String>('readSystemProxy');
    } catch (_) {
      proxy = null;
    }
    if (proxy != null) {
      HttpOverrides.global = _DebugProxyHttpOverrides(proxy);
      debugPrint('[flutter_debug_kit] 系统代理生效，HTTP/WebSocket 走 $proxy');
    } else {
      debugPrint('[flutter_debug_kit] 未检测到系统代理，直连');
    }
  }

  /// 当 [isActive] 为 true、URL 是 ws/wss 且未显式指定端口时，补上默认端口
  /// （ws→80，wss→443）；其它情况原样返回。
  ///
  /// 为什么需要这个：Dart 的 [Uri] 不为 ws/wss 定义默认端口，走 HTTP 代理握手时
  /// 代理会收到 `CONNECT host:0`，bind 失败。直连路径由 dart:io 底层 socket 兜底
  /// 不受影响，因此仅在代理态下需要补端口。
  ///
  /// 典型用法（stomp_dart_client 等走 [WebSocket.connect] 的场景）：
  /// ```dart
  /// stomp.connect(url: DebugProxy.normalizeWsUrl(url));
  /// ```
  static String normalizeWsUrl(String url) {
    if (!isActive) return url;
    final uri = Uri.parse(url);
    if (uri.hasPort) return url;
    if (uri.scheme != 'ws' && uri.scheme != 'wss') return url;
    final port = uri.scheme == 'wss' ? 443 : 80;
    return uri.replace(port: port).toString();
  }
}

class _DebugProxyHttpOverrides extends HttpOverrides {
  _DebugProxyHttpOverrides(this.proxy);
  final String proxy;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = (_) => 'PROXY $proxy';
    client.badCertificateCallback = (_, __, ___) => true;
    return client;
  }
}

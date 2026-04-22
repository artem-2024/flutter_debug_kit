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

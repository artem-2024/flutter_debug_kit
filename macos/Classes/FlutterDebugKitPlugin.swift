import Cocoa
import FlutterMacOS

public class FlutterDebugKitPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "dev.flutter_debug_kit/system_proxy",
      binaryMessenger: registrar.messenger
    )
    let instance = FlutterDebugKitPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "readSystemProxy":
      result(SystemProxyReader.read())
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

enum SystemProxyReader {
  static func read() -> String? {
    guard let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue()
            as? [String: Any] else { return nil }
    if let enabled = settings["HTTPSEnable"] as? Int, enabled == 1,
       let host = settings["HTTPSProxy"] as? String,
       let port = settings["HTTPSPort"] as? Int {
      return "\(host):\(port)"
    }
    if let enabled = settings["HTTPEnable"] as? Int, enabled == 1,
       let host = settings["HTTPProxy"] as? String,
       let port = settings["HTTPPort"] as? Int {
      return "\(host):\(port)"
    }
    return nil
  }
}

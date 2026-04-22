#ifndef FLUTTER_PLUGIN_FLUTTER_DEBUG_KIT_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_DEBUG_KIT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_debug_kit {

class FlutterDebugKitPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterDebugKitPlugin();

  virtual ~FlutterDebugKitPlugin();

  // Disallow copy and assign.
  FlutterDebugKitPlugin(const FlutterDebugKitPlugin&) = delete;
  FlutterDebugKitPlugin& operator=(const FlutterDebugKitPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_debug_kit

#endif  // FLUTTER_PLUGIN_FLUTTER_DEBUG_KIT_PLUGIN_H_

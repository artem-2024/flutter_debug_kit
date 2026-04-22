#include "flutter_debug_kit_plugin.h"

#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>

#include "system_proxy_reader.h"

namespace flutter_debug_kit {

// static
void FlutterDebugKitPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "dev.flutter_debug_kit/system_proxy",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FlutterDebugKitPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FlutterDebugKitPlugin::FlutterDebugKitPlugin() {}

FlutterDebugKitPlugin::~FlutterDebugKitPlugin() {}

void FlutterDebugKitPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("readSystemProxy") == 0) {
    std::string proxy = ReadSystemProxy();
    if (proxy.empty()) {
      result->Success(flutter::EncodableValue(std::monostate{}));
    } else {
      result->Success(flutter::EncodableValue(proxy));
    }
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_debug_kit

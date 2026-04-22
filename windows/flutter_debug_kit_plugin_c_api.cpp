#include "include/flutter_debug_kit/flutter_debug_kit_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_debug_kit_plugin.h"

void FlutterDebugKitPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_debug_kit::FlutterDebugKitPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

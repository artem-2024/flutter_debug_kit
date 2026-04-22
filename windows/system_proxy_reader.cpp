#include "system_proxy_reader.h"

#include <windows.h>
#include <winhttp.h>

#include <string>

#pragma comment(lib, "winhttp.lib")

namespace flutter_debug_kit {

namespace {

std::string WideToUtf8(const wchar_t* w) {
  if (w == nullptr || *w == L'\0') return {};
  int size = WideCharToMultiByte(CP_UTF8, 0, w, -1, nullptr, 0, nullptr, nullptr);
  if (size <= 1) return {};
  std::string s(size - 1, '\0');
  WideCharToMultiByte(CP_UTF8, 0, w, -1, s.data(), size, nullptr, nullptr);
  return s;
}

// IE 代理字符串可能是：
//   "host:port"                    —— 所有协议通用
//   "http=host:port;https=host:port;..."  —— 分协议
// 优先 https，退回通用。
std::string PickFromProxyString(const std::string& raw) {
  if (raw.empty()) return {};
  if (raw.find('=') == std::string::npos) {
    return raw;
  }
  std::string https_val;
  std::string http_val;
  size_t start = 0;
  while (start < raw.size()) {
    size_t end = raw.find(';', start);
    if (end == std::string::npos) end = raw.size();
    std::string token = raw.substr(start, end - start);
    size_t eq = token.find('=');
    if (eq != std::string::npos) {
      std::string key = token.substr(0, eq);
      std::string val = token.substr(eq + 1);
      if (key == "https") https_val = val;
      else if (key == "http") http_val = val;
    }
    start = end + 1;
  }
  if (!https_val.empty()) return https_val;
  if (!http_val.empty()) return http_val;
  return {};
}

}  // namespace

std::string ReadSystemProxy() {
  WINHTTP_CURRENT_USER_IE_PROXY_CONFIG cfg = {};
  if (!WinHttpGetIEProxyConfigForCurrentUser(&cfg)) {
    return {};
  }
  std::string result;
  if (cfg.lpszProxy != nullptr) {
    result = PickFromProxyString(WideToUtf8(cfg.lpszProxy));
  }
  if (cfg.lpszProxy) GlobalFree(cfg.lpszProxy);
  if (cfg.lpszProxyBypass) GlobalFree(cfg.lpszProxyBypass);
  if (cfg.lpszAutoConfigUrl) GlobalFree(cfg.lpszAutoConfigUrl);
  return result;
}

}  // namespace flutter_debug_kit

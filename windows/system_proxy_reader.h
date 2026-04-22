#pragma once

#include <string>

namespace flutter_debug_kit {

// 返回 "host:port"，没有代理返回空字符串。
std::string ReadSystemProxy();

}  // namespace flutter_debug_kit

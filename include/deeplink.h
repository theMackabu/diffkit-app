#pragma once

#include <optional>
#include <string>
#include <string_view>

namespace deeplink {
  std::optional<std::string> url_for(std::string_view raw_url);
}

#include "deeplink.h"

#include <algorithm>

namespace {
  constexpr std::string_view kScheme = "diffkit://";
  constexpr std::string_view kBaseUrl = "https://diff-kit.com/";

  bool starts_with_scheme(std::string_view value) {
    if (value.size() < kScheme.size()) return false;
    
    for (std::size_t i = 0; i < kScheme.size(); ++i) {
      const char actual = value[i];
      const char expected = kScheme[i];
      if (actual == expected) continue;
      if (expected >= 'a' && expected <= 'z' && actual == expected - ('a' - 'A')) continue;      
      return false;
    }
    
    return true;
  }

  std::string_view strip_query_and_fragment(std::string_view value) {
    const auto end = value.find_first_of("?#");
    return value.substr(0, end);
  }

  bool is_valid_component(std::string_view value) {
    if (value.empty()) return false;
    
    return std::ranges::all_of(value, [](const char ch) {
      return 
        (ch >= 'a' && ch <= 'z') ||
        (ch >= 'A' && ch <= 'Z') ||
        (ch >= '0' && ch <= '9') ||
        ch == '_' ||
        ch == '-' ||
        ch == '.';
    });
  }
}

namespace deeplink {
  std::optional<std::string> url_for(std::string_view raw_url) {
    if (!starts_with_scheme(raw_url)) {
      return std::nullopt;
    }
    
    auto path = strip_query_and_fragment(raw_url.substr(kScheme.size()));
    const auto slash = path.find('/');
    if (slash == std::string_view::npos || slash == 0 || slash == path.size() - 1) {
      return std::nullopt;
    }
    
    const auto owner = path.substr(0, slash);
    const auto repo = path.substr(slash + 1);
    if (repo.contains('/') || !is_valid_component(owner) || !is_valid_component(repo)) {
      return std::nullopt;
    }
    
    auto url = std::string{kBaseUrl};
    url.append(owner);
    url.push_back('/');
    url.append(repo);
    
    return url;
  }
}

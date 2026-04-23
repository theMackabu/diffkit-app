#include "deeplink.h"
#include "window.h"
#include "scripts.h"

#include <saucer/smartview.hpp>
#include <saucer/serializers/serializer.hpp>

namespace {
  std::string initial_url(int argc, char **argv) {
    for (int i = 1; i < argc; ++i) 
      if (auto url = deeplink::url_for(argv[i])) return *url;
    return "https://diff-kit.com";
  }
}

coco::stray start(saucer::application *app, std::string url) {
  auto window  = saucer::window::create(app).value();
  auto webview = saucer::smartview::create({.window = window});

  window->set_min_size({800, 600});
  window->set_size({1300, 800});
  window::update_decorations(window);

  webview->inject({
    .code = titlebar_script,
    .run_at = saucer::script::time::creation
  });
  
  webview->set_dev_tools(false);
  webview->set_url(url);

  window->show();
  window->focus();

  window::reposition_traffic_lights(window);
  window::register_deep_link_handler(*webview);
  window::activate(window);
  
  co_await app->finish();
}

int main(int argc, char **argv) {
  auto url = initial_url(argc, argv);
  return saucer::application::create({.id = "diffkit", .argc = argc, .argv = argv})
    ->run([url = std::move(url)](saucer::application *app) mutable {
      return start(app, std::move(url));
    });
}

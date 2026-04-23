#include "window.h"
#include "scripts.h"

#include <saucer/smartview.hpp>
#include <saucer/serializers/serializer.hpp>

coco::stray start(saucer::application *app) {
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
  webview->set_url("https://diff-kit.com");

  window->show();
  window->focus();

  window::reposition_traffic_lights(window);
  window::activate(window);
  
  co_await app->finish();
}

int main() {
  return saucer::application::create({.id = "diffkit"})->run(start);
}

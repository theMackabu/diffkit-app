#include "window.h"

#if !defined(__APPLE__)
namespace window {
    void activate(std::shared_ptr<saucer::window> window) {}
    void update_decorations(std::shared_ptr<saucer::window> window) {}
    void reposition_traffic_lights(std::shared_ptr<saucer::window> window) {}
    void register_deep_link_handler(saucer::smartview &webview) {}
}
#endif

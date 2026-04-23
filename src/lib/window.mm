#include "window.h"
#include "deeplink.h"

#import <Cocoa/Cocoa.h>
#include <saucer/modules/stable/webkit.hpp>

namespace {
  saucer::smartview *deep_link_webview = nullptr;

  void open_deep_link(NSString *raw_url) {
    if (!raw_url) return;
    
    auto target_url = deeplink::url_for([raw_url UTF8String]);
    if (!target_url) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if (deep_link_webview) deep_link_webview->set_url(*target_url);
    });
  }
}

@interface DiffKitURLHandler : NSObject
- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event
        withReplyEvent:(NSAppleEventDescriptor *)replyEvent;
@end

@implementation DiffKitURLHandler
- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event
        withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
  (void)replyEvent;
  open_deep_link([event paramDescriptorForKeyword:keyDirectObject].stringValue);
}
@end

namespace window {
  static DiffKitURLHandler *url_handler = nil;

  void activate(std::shared_ptr<saucer::window> window) {
    auto native = window->native();
    [NSApp activateIgnoringOtherApps:YES];
    [native.window makeKeyAndOrderFront:nil];
  }
    
  void update_decorations(std::shared_ptr<saucer::window> window) {
    auto native = window->native();
      
    NSWindow *nsWindow = native.window;
    nsWindow.titlebarAppearsTransparent = YES;
    nsWindow.titleVisibility = NSWindowTitleHidden;
    nsWindow.styleMask |= NSWindowStyleMaskFullSizeContentView;
    nsWindow.collectionBehavior = (nsWindow.collectionBehavior & ~NSWindowCollectionBehaviorFullScreenPrimary)
                                | NSWindowCollectionBehaviorFullScreenNone;
    [nsWindow setFrameAutosaveName:@"MainWindow"];
  }
    
  static void apply_traffic_light_offset(NSWindow *nsWindow) {
    NSButton *close = [nsWindow standardWindowButton:NSWindowCloseButton];
    NSButton *mini  = [nsWindow standardWindowButton:NSWindowMiniaturizeButton];
    NSButton *zoom  = [nsWindow standardWindowButton:NSWindowZoomButton];
    
    CGFloat offsetX = 6, offsetY = -6;
    CGFloat baseX[] = { 7, 27, 47 };
    CGFloat baseY = close.frame.origin.y + offsetY;
    
    int i = 0;
    for (NSView *btn in @[close, mini, zoom]) {
      [btn setFrameOrigin:NSMakePoint(baseX[i] + offsetX, baseY)];
      i++;
    }
  }

  void reposition_traffic_lights(std::shared_ptr<saucer::window> window) {
    auto native = window->native();
    NSWindow *nsWindow = native.window;
      
    dispatch_async(dispatch_get_main_queue(), ^{
      apply_traffic_light_offset(nsWindow);
    });
    
    [[NSNotificationCenter defaultCenter]
      addObserverForName:NSWindowDidResizeNotification
      object:nsWindow
      queue:[NSOperationQueue mainQueue]
      usingBlock:^(NSNotification *) {
        apply_traffic_light_offset(nsWindow);
      }];
    
    [[NSNotificationCenter defaultCenter]
      addObserverForName:NSWindowDidExitFullScreenNotification
      object:nsWindow
      queue:[NSOperationQueue mainQueue]
      usingBlock:^(NSNotification *) {
        apply_traffic_light_offset(nsWindow);
      }];
  }

  void register_deep_link_handler(saucer::smartview &webview) {
    deep_link_webview = &webview;
    if (!url_handler) {
      url_handler = [DiffKitURLHandler new];
      [[NSAppleEventManager sharedAppleEventManager]
        setEventHandler:url_handler
        andSelector:@selector(handleGetURLEvent:withReplyEvent:)
        forEventClass:kInternetEventClass
        andEventID:kAEGetURL];
    }
  }
}

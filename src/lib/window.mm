#include "window.h"

#import <Cocoa/Cocoa.h>
#include <saucer/modules/stable/webkit.hpp>

namespace window {
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
}
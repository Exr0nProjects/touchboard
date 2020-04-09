//
//  AppDelegate.m
//  touchboard
//
//  Created by Exr0n on 4/8/20.
//  Copyright © 2020 exr0n. All rights reserved.
//

#import "AppDelegate.h"
#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#include <Carbon/Carbon.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

CGEventRef myCGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    NSLog(@"In the callback");
    if (CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode) == kVK_ANSI_F) {
        NSLog(@"event matched");
            [[NSHapticFeedbackManager defaultPerformer] performFeedbackPattern:NSHapticFeedbackPatternGeneric performanceTime:NSHapticFeedbackPerformanceTimeNow]; // yoinked from https://github.com/lapfelix/ForceTouchVibrationCLI/blob/master/vibrate/main.m
    }

    return event;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
  NSLog(@"Hello?");
  CFRunLoopSourceRef runLoopSource;

  CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, kCGEventMaskForAllEvents, myCGEventCallback, NULL);

  if (!eventTap) {
      NSLog(@"Couldn't create event tap!");
      exit(1);
  }

  runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);

  CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);

  CGEventTapEnable(eventTap, true);

  CFRunLoopRun();

  CFRelease(eventTap);
  CFRelease(runLoopSource);

  NSLog(@"goodbye");
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}


@end

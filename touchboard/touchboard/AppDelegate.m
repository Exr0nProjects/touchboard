//
//  AppDelegate.m
//  touchboard
//
//  Created by Exr0n on 4/8/20.
//  Copyright © 2020 exr0n. All rights reserved.
//

#import "AppDelegate.h"
#import "MultiTouch.h"
#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#include <Carbon/Carbon.h>

@interface AppDelegate ()

    @property (weak) IBOutlet NSWindow *window;

    // yoinked from pedia of daniel
    @property (nonatomic, strong) NSStatusBarButton* statusBarButton;
    @property (nonatomic, strong) NSMenu *menuItem;

    @end

    @implementation AppDelegate

    static BOOL shouldTransformClick = NO;
    static CFMachPortRef eventTap;
    static MTDeviceRef device;

-(void)awakeFromNib
{
	[super awakeFromNib];
	self.menuItem = [[NSMenu alloc] initWithTitle:@"menuItemContents"];
	self.statusBarButton = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] button];
  [self.statusBarButton setTitle:@"touchboard"];
	[self.statusBarButton setMenu:self.menuItem];
	
	[self startMonitoring];
}

-(void)startMonitoring
{
    NSLog(@"startMonitoring");

    CFRunLoopSourceRef runLoopSource;
    eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, kCGEventMaskForAllEvents, myCGEventHandler, NULL);

    if (!eventTap) {
        NSLog(@"Couldn't create event tap... try regranting permissions in System Preferences!");
        exit(1);
    }

    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);

    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);

    CGEventTapEnable(eventTap, true);

    CFRunLoopRun();

    CFRelease(eventTap);
    CFRelease(runLoopSource);

    [self.menuItem removeAllItems];
    [self.menuItem addItemWithTitle:@"Disable" action:@selector(stopMonitoring) keyEquivalent:@""];

    [self.menuItem addItem:[NSMenuItem separatorItem]];
    [self.menuItem addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
}

-(void)stopMonitoring
{
    NSLog(@"stopMonitoring");

    [self.menuItem removeAllItems];
    [self.menuItem addItemWithTitle:@"Enable" action:@selector(startMonitoring) keyEquivalent:@""];
    [self.menuItem addItem:[NSMenuItem separatorItem]];
    [self.menuItem addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
}

void touchCallback(MTDeviceRef device, MTTouch touches[], size_t numTouches, double timestamp, size_t frame)
{
    // yoinked from https://encyclopediaofdaniel.com/blog/making-the-magic-trackpad-work/
    shouldTransformClick = NO;
    if(numTouches == 1)
    {
        MTTouch* touch = &touches[0];
        float x = touch->normalizedVector.position.x;
        if(x >= 0.5)
        {
            shouldTransformClick = YES;
        }
    }
}

CGEventRef myCGEventHandler(CGEventTapProxy proxy, CGEventType type, CGEventRef eventRef, void *refcon) {
    NSLog(@"In the callback");

    if(shouldTransformClick == NO)
    {
        return eventRef;
    }
    if(type != kCGEventLeftMouseUp && type != kCGEventLeftMouseDown)
    { // only transform leftup and leftdown events
        return eventRef;
    }
    NSEvent* event = [NSEvent eventWithCGEvent:eventRef];
    if(!event) // don't try to dereference a nullptr
        return eventRef;

    // create a event source to create a related event... https://developer.apple.com/documentation/coregraphics/cgeventsourceref?language=objc
    CGEventSourceRef sourceRef = CGEventCreateSourceFromEvent(eventRef);
    CGPoint point = CGEventGetLocation(eventRef);
    CGEventRef newRef;
    if(type == kCGEventLeftMouseDown)
    { // make a right mouse down if the event is a left mouse down
        newRef = CGEventCreateMouseEvent(sourceRef, kCGEventRightMouseDown, point, kCGMouseButtonRight);
    }
    else
    { // make a right mouse up
        newRef = CGEventCreateMouseEvent(sourceRef, kCGEventRightMouseUp, point, kCGMouseButtonRight);
    }

    return newRef;
    // [[NSHapticFeedbackManager defaultPerformer] performFeedbackPattern:NSHapticFeedbackPatternGeneric performanceTime:NSHapticFeedbackPerformanceTimeNow]; // yoinked from https://github.com/lapfelix/ForceTouchVibrationCLI/blob/master/vibrate/main.m
}

@end

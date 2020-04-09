#include <Foundation/Foundation.h>
#define case_print(a) case a: printf("%s - %d\n",#a,a); break;

CGEventRef eventOccurred(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void* refcon) {
    int subType =  CGEventGetIntegerValueField(event, kCGMouseEventSubtype);
    if (type == NSEventTypeGesture || subType == NX_SUBTYPE_MOUSE_TOUCH) {
        printf("touchpad\n");

        switch(type) {
            case_print(kCGEventNull)
            case_print(kCGEventLeftMouseDown)
            case_print(kCGEventLeftMouseUp)
            case_print(kCGEventRightMouseDown)
            case_print(kCGEventRightMouseUp)
            case_print(kCGEventMouseMoved)
            case_print(kCGEventLeftMouseDragged)
            case_print(kCGEventRightMouseDragged)
            case_print(kCGEventScrollWheel)
            case_print(kCGEventOtherMouseDown)
            case_print(kCGEventOtherMouseUp)
            case_print(kCGEventOtherMouseDragged)
            case_print(kCGEventTapDisabledByTimeout)
            case_print(kCGEventTapDisabledByUserInput)
            case_print(NSEventTypeGesture)
            case_print(NSEventTypeMagnify)
            case_print(NSEventTypeSwipe)
            case_print(NSEventTypeRotate)
            case_print(NSEventTypeBeginGesture)
            case_print(NSEventTypeEndGesture)
            default:
                printf("default: %d\n",type);
                break;
        }

        event = NULL;
    }  else {
        if (type == kCGEventMouseMoved) {  // (A)
            printf("discarding mouse event");
            event = NULL;
        }
    }

    return event;
}


CFMachPortRef createEventTap() {  
    CGEventMask eventMask = NSAnyEventMask;

    if (!AXAPIEnabled() && !AXIsProcessTrusted()) { 
        printf("axapi not enabled");
    } 

    return CGEventTapCreate(kCGHIDEventTap, 
            kCGHeadInsertEventTap, 
            kCGEventTapOptionDefault, 
            eventMask, 
            eventOccurred, 
            NULL); 
}

int main (int argc, const char * argv[]) {

    NSBeep();


    CFMachPortRef tap = createEventTap();

    if (tap) {
        CFRunLoopSourceRef rl = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0);
        CFRunLoopAddSource(CFRunLoopGetMain(), rl, kCFRunLoopCommonModes);
        CGEventTapEnable(tap, true);
        CFRunLoopRun();

        printf("Tap created.\n");
        sleep(-1);
    } else {
        printf("failed!\n");
    }

    return 0;
}


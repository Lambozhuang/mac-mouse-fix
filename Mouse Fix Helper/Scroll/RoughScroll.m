//
// --------------------------------------------------------------------------
// RoughScroll.m
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2020
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import "RoughScroll.h"
#import "ScrollControl.h"
#import "TouchSimulator.h"
#import "ScrollUtility.h"
#import "ConfigFileInterface_HelperApp.h"

@implementation RoughScroll

#pragma mark - Globals

+ (void)start {
}

+ (void)stop {
}

+ (CGEventRef)updateInternalParamsAndReinsertEventIfWise:(CGEventRef _Nonnull)event {
    BOOL mouseMoved = [ScrollUtility mouseDidMove];
    BOOL frontMostAppChanged = NO;
    if (!mouseMoved) {
        frontMostAppChanged = [ScrollUtility frontMostAppDidChange];
        // Only need to check this if mouse didn't move, because of OR in (mouseMoved || frontMostAppChanged). For optimization. Not sure if significant.
    }
    if (mouseMoved || frontMostAppChanged) {
        // set app overrides
        BOOL paramsDidChange = [ConfigFileInterface_HelperApp updateInternalParameters];
        if (paramsDidChange) {
            return [ScrollControl reinsertScrollEvent:event];
        }
    }
    return nil;
}

+ (CGEventRef)handleInput:(CGEventRef)event info:(NSDictionary *)info {
    
    // TODO: Optimize this using mouseMoved and other techniques from SmoothScroll.m
    // (Probably best to move the calculation of stuff that both SmoothScroll and RoughScroll use to ScrollControl, and then pass the stuff as parameters to the respective `handleInput:` functions)
    
//    if (mouseMoved == TRUE) {
//        setConfigVariablesForActiveApp();
//    }
    
    [ScrollUtility updateConsecutiveScrollTickCounterWithTickOccuringNow];
    int consecutiveScrollTicks = ScrollUtility.consecutiveScrollTickCounter;
    if (consecutiveScrollTicks == 0) {
        CGEventRef reevaluatedEvent = [self updateInternalParamsAndReinsertEventIfWise:event];
        if (reevaluatedEvent) {
            return reevaluatedEvent;
        }
    }
    
    
    if (ScrollControl.scrollDirection == -1) { // TODO: Use kMFInvertedScrollDirection instead of -1
        event = [ScrollUtility invertScrollEvent:event direction:ScrollControl.scrollDirection];
    }
    if (ScrollControl.magnificationScrolling) { //TODO: TODO: Consider acitvating displayLink to send magnification events instead (After sorting out activity states of SmoothScroll.m)
        [TouchSimulator postEventWithMagnification:CGEventGetIntegerValueField(event, kCGScrollWheelEventDeltaAxis1)/50.0 phase:kIOHIDEventPhaseChanged];
        return nil;
    } else {
        if (ScrollControl.horizontalScrolling) {
            [ScrollUtility makeScrollEventHorizontal:event];
        }
//        [ScrollUtility logScrollEvent:event];
        return event;
    }
}

@end

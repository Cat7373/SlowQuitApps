@import Carbon;
#import "SQACmdQStream.h"

@interface SQACmdQStream() {
@private
    dispatch_source_t timer;
}
@end

@implementation SQACmdQStream
@synthesize observer;

- (id)init {
    self = [super init];
    if (!self) return self;

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (!timer) {
        return nil;
    }

    const NSUInteger interval = 15 * NSEC_PER_MSEC;
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 0), interval, 0);
    dispatch_source_set_event_handler(timer, ^ { [self tick]; });
    return self;
}

- (void)open {
    dispatch_resume(timer);
}

- (void)close {
    if (timer) {
        dispatch_source_cancel(timer);
        timer = nil;
    }
}

- (void)tick {
    const BOOL cmdPressed = keyCmdIsPressed();
    const BOOL qPressed = keyQIsPressed();
    const BOOL pressed = cmdPressed && qPressed;
    dispatch_async(dispatch_get_main_queue(), ^{
        observer(pressed);
    });
}

BOOL keyCmdIsPressed() {
    return CGEventSourceKeyState(kCGEventSourceStateHIDSystemState, kVK_Command);
}

BOOL keyQIsPressed() {
    return CGEventSourceKeyState(kCGEventSourceStateHIDSystemState, kVK_ANSI_Q);
}

@end

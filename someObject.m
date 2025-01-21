The solution involves using a weak reference to the delegate in `someObject.h` and `someObject.m`. This prevents `someObject` from retaining a strong reference to the view controller, allowing it to deallocate normally.  The `weak` keyword ensures that the delegate property is not retained.

```objectivec
// someObject.h
#import <Foundation/Foundation.h>

@protocol SomeObjectDelegate; //Declare protocol

@interface SomeObject : NSObject
@property (nonatomic, weak) id <SomeObjectDelegate> delegate;
- (void)performLongTask;
@end

// someObject.m
#import "someObject.h"
@implementation SomeObject
- (void)performLongTask {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // Simulate long task
        if (self.delegate) { //Check for nil before sending message
            [self.delegate someObjectDidFinish:self];
        }
    });
}
@end
```
Additionally, checking for `nil` before sending a message to the delegate adds an extra layer of safety.
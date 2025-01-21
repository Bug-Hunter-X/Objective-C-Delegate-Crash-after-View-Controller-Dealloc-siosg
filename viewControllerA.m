In Objective-C, a common yet subtle issue arises when dealing with memory management and object lifecycles, especially when using delegates or blocks.  Consider the scenario where a view controller (viewControllerA) sets itself as the delegate of another object (someObject). If viewControllerA is deallocated before someObject finishes using the delegate,  it can lead to crashes due to sending messages to a deallocated object. This is because someObject might still hold a reference to viewControllerA's delegate, attempting to access it after it's been released from memory. 

```objectivec
// viewControllerA.h
#import <UIKit/UIKit.h>

@protocol SomeObjectDelegate <NSObject>
- (void)someObjectDidFinish:(SomeObject *)someObject;
@end

@interface ViewControllerA : UIViewController <SomeObjectDelegate>
@property (strong, nonatomic) SomeObject *someObject;
@end

// viewControllerA.m
#import "viewControllerA.h"

@implementation ViewControllerA
- (void)viewDidLoad {
    [super viewDidLoad];
    self.someObject = [[SomeObject alloc] init];
    self.someObject.delegate = self; // Setting self as the delegate
    [self.someObject performLongTask];
}

- (void)someObjectDidFinish:(SomeObject *)someObject {
    NSLog(@"Some object finished");
}

- (void)dealloc {
    NSLog(@"viewControllerA deallocated");
}
@end

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
        [self.delegate someObjectDidFinish:self];
    });
}
@end
```

#import <Foundation/Foundation.h>
#if TARGET_OS_IOS || TARGET_OS_TV
#import "NSTask.h"
#endif
#define FM [NSFileManager defaultManager]

@interface KBTaskManager: NSObject
@property (nonatomic, strong) NSString *prefixPath;
@property (readwrite, assign) BOOL usePrefixes;
+ (id)sharedManager;
+ (NSString *)kb_task_environmentPath;
+ (NSDictionary *)kb_task_executableEnvironment;
+ (NSString *)kb_task_returnForProcess:(NSString *)format, ...;
@end

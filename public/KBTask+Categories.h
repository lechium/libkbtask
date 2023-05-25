
#import <Foundation/Foundation.h>
#if TARGET_OS_IOS || TARGET_OS_TV
#import "NSTask.h"

@interface NSTask (KBTask)
- (void) waitUntilExit;
@end
#endif

@interface NSArray (KBTask)
- (NSArray *)kb_task_sanitizedArray:(BOOL)sanitizeAll forced:(BOOL)forced;
- (NSArray *)kb_task_sanitizedArray:(BOOL)sanitizeAll;
- (NSArray *)kb_task_sanitizedArray;
@end

@interface NSString (KBTask)
- (NSString *)kbT_runPathForSearchPath:(NSString *)path;
- (NSString *)kb_task_whitespaceTrimmedString;
- (NSArray *)kb_task_spaceDelimitedArray;
- (NSString *)kb_task_pathAppendingPrefix;
- (NSString *)kb_task_sanitizedString;
- (NSString *)kb_task_sanitizedString:(BOOL)sanitizeAll;
- (NSString *)kb_task_sanitizedString:(BOOL)sanitizeAll forced:(BOOL)forced;
@end

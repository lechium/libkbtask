
#import "KBTask+Categories.h"
#import "KBTaskManager.h"
#if TARGET_OS_IOS || TARGET_OS_TV
#import "NSTask.h"

@implementation NSTask (KBTask)

- (void) waitUntilExit {
    
    NSTimer    *timer = nil;
    while ([self isRunning]) {
        NSDate    *limit = nil;
        
        limit = [[NSDate alloc] initWithTimeIntervalSinceNow: 0.1];
        if (timer == nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
            timer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                     target: nil
                                                   selector: @selector(class)
                                                   userInfo: nil
                                                    repeats: YES];
#pragma clang diagnostic pop
        }
        [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode
                                 beforeDate: limit];
    }
    [timer invalidate];
}

@end

#endif
@implementation NSArray (KBTask)

- (NSArray *)kb_task_sanitizedArray:(BOOL)sanitizeAll forced:(BOOL)forced {
    if ([[KBTaskManager sharedManager] usePrefixes] || forced) {
        __block NSMutableArray *args = [self mutableCopy];
        if (sanitizeAll) {
            [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj containsString:@"/"] && [obj length] > 1 && ![obj containsString:@"*"] && (![FM fileExistsAtPath:obj] || forced)) {
                    NSString *newObject = [obj kb_task_pathAppendingPrefix];
                    if ([FM fileExistsAtPath:newObject] || forced){
                        //NSLog(@"replacing %@ with %@ at %lu", obj, newObject, idx);
                        [args replaceObjectAtIndex:idx withObject:newObject];
                    }
                }
            }];
            return [args copy];
        } else {
            NSString *first = [args firstObject];
            if ([first containsString:@"/"] && first.length > 1 && ![first containsString:@"*"] && (![FM fileExistsAtPath:first] || forced)){
                if (![FM fileExistsAtPath:first] || forced){
                    //NSLog(@"trying to run a command at a path that might not exist: %@", first);
                    NSString *newFirst = [first kb_task_pathAppendingPrefix];
                    if ([FM fileExistsAtPath:newFirst] || forced){
                        //NSLog(@"does exist: %@", newFirst);
                        [args replaceObjectAtIndex:0 withObject:newFirst];
                        //NSLog(@"updated arguments: %@", args);
                        return [args copy];
                    }
                }
            }
        }
    }
    return self;
}

- (NSArray *)kb_task_sanitizedArray:(BOOL)sanitizeAll {
    return [self kb_task_sanitizedArray:sanitizeAll forced:false];
}

- (NSArray *)kb_task_sanitizedArray {
    return [self kb_task_sanitizedArray:false forced:false];
}

@end

@implementation NSString (KBTask)

- (NSString *)kbT_generatedLaunchPathForSearchPath:(NSString *)path {
    if ([[KBTaskManager sharedManager] usePrefixes]) {
        if (![FM fileExistsAtPath:self]){
            //NSLog(@"[KBTask] launch path doesnt exist: %@", self);
            NSString *newLp = [self kb_task_pathAppendingPrefix];
            //NSLog(@"[KBTask] looking for new lp: %@", newLp);
            if ([FM fileExistsAtPath:newLp]){
                //NSLog(@"[KBTask] Substituting %@ for %@", newLp, self);
                return newLp;
            } else {
                newLp = [self kbT_runPathForSearchPath:path];
                if ([FM fileExistsAtPath:newLp]){
                    return newLp;
                }
            }
        }
    } else {
        if (![FM fileExistsAtPath:self]){
            NSString *newLp = [self kbT_runPathForSearchPath:path];
            if ([FM fileExistsAtPath:newLp]){
                return newLp;
            }
        }
    }
    return self;
}

- (NSString *)kbT_runPathForSearchPath:(NSString *)path {
    NSArray *paths = [path componentsSeparatedByString:@":"];
    __block NSString *_finalPath = nil;
    [paths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *pathTest = [obj stringByAppendingPathComponent:[self lastPathComponent]];
        //NSLog(@"[KBTask] testing path: %@", pathTest);
        if ([FM fileExistsAtPath:pathTest]) {
            //NSLog(@"[KBTask] found path: %@", pathTest);
            _finalPath = pathTest;
            *stop = true;
        }
    }];
    return _finalPath;
}

- (NSString *)kb_task_whitespaceTrimmedString {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


- (NSArray *)kb_task_spaceDelimitedArray {
    NSCharacterSet *whitespaceAndCharSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSScanner *stringScanner = [[NSScanner alloc] initWithString:self];
    stringScanner.charactersToBeSkipped = whitespaceAndCharSet;
    NSString *rawValue = nil;
    NSMutableArray *lineObjects = [NSMutableArray new];
    while ([stringScanner scanUpToCharactersFromSet:whitespaceAndCharSet intoString:&rawValue]) {
        [lineObjects addObject:[rawValue kb_task_whitespaceTrimmedString]];
    }
    return lineObjects;
}

- (NSString *)kb_task_pathAppendingPrefix {
    return [[[KBTaskManager sharedManager] prefixPath] stringByAppendingPathComponent:self];
}

- (NSString *)kb_task_sanitizedString {
    return [self kb_task_sanitizedString:false];
}

- (NSString *)kb_task_sanitizedString:(BOOL)sanitizeAll {
    return [self kb_task_sanitizedString:sanitizeAll forced:false];
}

- (NSString *)kb_task_sanitizedString:(BOOL)sanitizeAll forced:(BOOL)forced {
    if ([[KBTaskManager sharedManager] usePrefixes] || forced) {
        return [[[self kb_task_spaceDelimitedArray] kb_task_sanitizedArray:sanitizeAll forced:forced] componentsJoinedByString:@" "];
    }
    return self;
}


@end

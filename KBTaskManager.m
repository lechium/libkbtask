
#import "KBTaskManager.h"
#import "KBTask.h"
#import "KBTask+Categories.h"

static NSString *prefixPath = @"/fs/jb";

@implementation KBTaskManager

+ (NSString *)kb_task_environmentPath {
    return [NSString stringWithFormat:@"PATH:%@/usr/bin:%@/usr/libexec:%@/usr/sbin:%@/bin:%@/usr/local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/binpack/usr/bin:/binpack/usr/sbin:/binpack/bin:/binpack/sbin", prefixPath, prefixPath, prefixPath, prefixPath, prefixPath];
}

+ (NSDictionary *)kb_task_executableEnvironment {
    if ([self _determineUsePrefixes]){
        return @{@"APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE": @(true),
                 @"SHELL": @"/binpack/bin/bash",
                 @"PATH": [self kb_task_environmentPath]
        };
    }
    return @{@"APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE": @(true),
             @"PATH":
                 @"PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games"
    };
}

+ (BOOL)_determineUsePrefixes {
    return ([FM contentsOfDirectoryAtPath:prefixPath error:nil].count > 0);
}

+ (id)sharedManager {
    static dispatch_once_t onceToken;
    static KBTaskManager *shared = nil;
    if(shared == nil) {
        dispatch_once(&onceToken, ^{
            shared = [[KBTaskManager alloc] init];
            shared.usePrefixes = [self _determineUsePrefixes];
            if (shared.usePrefixes) {
                shared.prefixPath = prefixPath;
            }
        });
    }
    return shared;
}

+ (NSString *)kb_task_returnForProcess:(NSString *)process {
    
    NSArray *rawProcessArgumentArray = [process kb_task_spaceDelimitedArray];
    NSString *taskBinary = [[rawProcessArgumentArray firstObject] kb_task_sanitizedString];
    NSArray *taskArguments = [rawProcessArgumentArray subarrayWithRange:NSMakeRange(1, rawProcessArgumentArray.count-1)];
    KBTask *task = [[KBTask alloc] init];
    NSPipe *pipe = [[NSPipe alloc] init];
    NSFileHandle *handle = [pipe fileHandleForReading];
    [task setEnvironment:[self kb_task_executableEnvironment]];
    [task setLaunchPath:taskBinary];
    [task setArguments:[taskArguments kb_task_sanitizedArray]];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    [task launch];
    
    NSData *outData = nil;
    NSString *temp = nil;
    while((outData = [handle readDataToEndOfFile]) && [outData length]) {
        temp = [[NSString alloc] initWithData:outData encoding:NSASCIIStringEncoding];
    }
    [handle closeFile];
    task = nil;
    return temp;
}

@end

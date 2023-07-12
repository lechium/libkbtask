#import "KBTask.h"
#import "KBTaskManager.h"
#import "KBTask+Categories.h"

#define DEFAULT_PATH @"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games"

@interface KBTask()

@property (nonatomic, strong) NSTask *task;

@end

@implementation KBTask

+ (NSTask *)launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments {
    if ([[KBTaskManager sharedManager] usePrefixes]) {
        NSString *searchPath = [KBTaskManager kb_task_environmentPath];
        NSString *lp = [path kbT_generatedLaunchPathForSearchPath:searchPath];
        if (lp){
            return [NSTask launchedTaskWithLaunchPath:lp arguments:[arguments kb_task_sanitizedArray:true]];
        } else {
            NSLog(@"[KBTask:ERROR] couldn't find launch path for: %@", path);
            return nil;
        }
    }
    NSString *searchPath = DEFAULT_PATH;
    NSString *lp = [path kbT_generatedLaunchPathForSearchPath:searchPath];
    if (lp){
        return [NSTask launchedTaskWithLaunchPath:lp arguments:[arguments kb_task_sanitizedArray:true]];
    }
    NSLog(@"[KBTask:ERROR] couldn't find launch path for: %@", path);
    return nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _task = [NSTask new];
    }
    return self;
}

- (NSArray *)sanitizedArguments {
    return [self.arguments kb_task_sanitizedArray:true];
}

- (NSString *)_environmentLaunchPath {
    NSDictionary *env = [self environment];
    if (env) {
        return  [self.task.launchPath kbT_runPathForSearchPath:env[@"PATH"]];
    }
    return nil;
}

- (void)launch {
    if ([[KBTaskManager sharedManager] usePrefixes]) {
        //NSLog(@"[KBTask] use prefixes: %@", [self launchPath]);
        NSString *lp = [self launchPath];
        if (![FM fileExistsAtPath:lp]){
            //NSLog(@"[KBTask] launch path doesnt exist: %@", lp);
            NSString *newLp = [lp kb_task_pathAppendingPrefix];
            //NSLog(@"[KBTask] looking for new lp: %@", newLp);
            if ([FM fileExistsAtPath:newLp]){
                //NSLog(@"[KBTask] Substituting %@ for %@", newLp, lp);
                self.launchPath = newLp;
                self.task.launchPath = newLp;
            }
        }
        self.arguments = [self sanitizedArguments];
        self.task.arguments = self.arguments;
        //NSLog(@"[KBTask] arguments: %@", [self.arguments componentsJoinedByString:@" "]);
        if (![FM fileExistsAtPath:self.task.launchPath]){
            NSLog(@"[KBTask] potential exception!! launch path doesnt exist: %@ attempting search path try", self.task.launchPath);
            NSString *tmpLaunchPath = [self _environmentLaunchPath];
            //NSLog(@"[KBTask] _environmentLaunchPath: %@", tmpLaunchPath);
            
            if (![FM fileExistsAtPath:tmpLaunchPath] || tmpLaunchPath == nil){
                NSLog(@"[KBTask] last try failed: %@", self.task.launchPath);
                return;
            } else {
                self.task.launchPath = tmpLaunchPath;
            }
        }
        [self.task launch];
        return;
    }
    if (![FM fileExistsAtPath:self.task.launchPath]){
        
        NSLog(@"[KBTask] potential exception!! launch path doesnt exist: %@ attempting search path try", self.task.launchPath);
        self.task.launchPath = [self _environmentLaunchPath];
        //NSLog(@"[KBTask] _environmentLaunchPath: %@", self.task.launchPath);
        if (![FM fileExistsAtPath:self.task.launchPath] || self.task.launchPath == nil){
            NSLog(@"[KBTask] last try failed: %@", self.task.launchPath);
            return;
        }
    }
    [self.task launch];
}



- (void)waitUntilExit {
    [self.task waitUntilExit];
}

- (long long)terminationReason {
    return self.task.terminationReason;
}

- (int)terminationStatus {
    return self.task.terminationStatus;
}

- (id)standardInput {
    return self.task.standardInput;
}

- (id)standardOutput {
    return self.task.standardOutput;
}

- (id)standardError {
    return self.task.standardError;
}

- (void)interrupt {
    [self.task interrupt];
}

- (void)terminate {
    [self.task terminate];
}

- (BOOL)suspend {
    return self.task.suspend;
}

- (BOOL)resume {
    return self.task.resume;
}

- (int)processIdentifier {
    return self.task.processIdentifier;
}

- (BOOL)isRunning {
    return self.task.isRunning;
}

- (void)setCurrentDirectoryPath:(NSString *)path {
    self.task.currentDirectoryPath = path;
}

- (void)setStandardInput:(id)input {
    self.task.standardInput = input;
}

- (void)setStandardOutput:(id)output {
    self.task.standardOutput = output;
}

- (void)setStandardError:(id)error {
    self.task.standardError = error;
}

- (void)setLaunchPath:(NSString *)path {
    if (path) {
        self.task.launchPath = path;
    }
}

- (NSString *)launchPath {
    return self.task.launchPath;
}

- (NSString *)currentDirectoryPath {
    return self.task.currentDirectoryPath;
}

- (NSDictionary *)environment {
    return self.task.environment;
}

- (void)setEnvironment:(NSDictionary *)dict {
    [self.task setEnvironment:dict];
}

- (void)setArguments:(NSArray *)arguments {
    [self.task setArguments:arguments];
}

- (NSArray *)arguments {
    return self.task.arguments;
}

@end

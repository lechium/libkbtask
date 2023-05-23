#import "KBTask.h"
#import "KBTaskManager.h"
#import "KBTask+Categories.h"

@interface KBTask()

@property (nonatomic, strong) NSTask *task;

@end

@implementation KBTask

+ (NSTask *)launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments {
    if ([[KBTaskManager sharedManager] usePrefixes]) {
        return [NSTask launchedTaskWithLaunchPath:[path kb_task_pathAppendingPrefix] arguments:[arguments kb_task_sanitizedArray:true]];
    }
    return [NSTask launchedTaskWithLaunchPath:path arguments:arguments];
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

- (void)launch {
    if ([[KBTaskManager sharedManager] usePrefixes]) {
        //NSLog(@"use prefixes: %@", [self launchPath]);
        NSString *lp = [self launchPath];
        if (![FM fileExistsAtPath:lp]){
            //NSLog(@"launch path doesnt exist: %@", lp);
            NSString *newLp = [lp kb_task_pathAppendingPrefix];
            //NSLog(@"looking for new lp: %@", newLp);
            if ([FM fileExistsAtPath:newLp]){
                //NSLog(@"Substituting %@ for %@", newLp, lp);
                self.launchPath = newLp;
                self.task.launchPath = newLp;
            }
        }
        self.arguments = [self sanitizedArguments];
        self.task.arguments = self.arguments;
        //NSLog(@"arguments: %@", [self.arguments componentsJoinedByString:@" "]);
        if (![FM fileExistsAtPath:self.task.launchPath]){
            NSLog(@"potential exception!! launch path doesnt exist: %@", self.task.launchPath);
            return;
        }
        [self.task launch];
        return;
    }
    if (![FM fileExistsAtPath:self.task.launchPath]){
        NSLog(@"potential exception!! launch path doesnt exist: %@", self.task.launchPath);
        return;
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
    self.task.launchPath = path;
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
//
//  NeatoHTTPSessionManager.m
//  NeatoHTTP
//
//  Created by Yari D'areglia on 12/05/16.
//  2016 Neato Robotics.
//

#import "NeatoHTTPSessionManager.h"
#import "NeatoHTTPTaskDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface NeatoHTTPSessionManager()
@property (nonatomic, strong) NSMutableDictionary *taskDelegates;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary *headers;
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation NeatoHTTPSessionManager

#pragma mark - Public -

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration*)configuration baseURL:(NSURL*)base{
    self = [super init];
    if (self) {
        self.taskDelegates = [NSMutableDictionary new];
        self.baseURL = base;
        self.sessionConfiguration = configuration;
        self.headers = [NSMutableDictionary new];
        self.operationQueue = [NSOperationQueue new];
        self.operationQueue.maxConcurrentOperationCount = 1;
        self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.operationQueue];
    }
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)base{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    return [self initWithConfiguration:config baseURL:base];
}

- (void)setValue:(NSString* _Nullable)value forHTTPHeaderField:(NSString *)field{
    self.headers[field] = value;
}

- (NSString * _Nullable)valueForHTTPHeaderField:(NSString *)field {
    return self.headers[field];
}

- (NSURLSessionDataTask * _Nullable)GET:(NSString *)URLString parameters:(id _Nullable)parameters
                    progress:(void (^ _Nullable)(NSProgress * _Nullable))downloadProgress
                     success:(void (^ _Nullable)(NSURLSessionDataTask * , id _Nullable))success
                     failure:(void (^ _Nullable)(NSURLSessionDataTask * _Nullable,NSError * ))failure{
    
    return [self dataTaskWithHTTPMethod:@"GET" URLString:URLString parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask * _Nullable)POST:(NSString *)URLString
                              parameters:(id _Nullable)parameters
                                progress:(void (^ _Nullable)(NSProgress * _Nonnull))uploadProgress
                                 success:(void (^ _Nullable)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                                 failure:(void (^ _Nullable)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure{
    
    return [self dataTaskWithHTTPMethod:@"POST" URLString:URLString parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask * _Nullable)PUT:(NSString *)URLString
                              parameters:(id _Nullable)parameters
                                progress:(void (^ _Nullable)(NSProgress * _Nonnull))uploadProgress
                                 success:(void (^ _Nullable)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                                 failure:(void (^ _Nullable)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure{
    
    return [self dataTaskWithHTTPMethod:@"PUT" URLString:URLString parameters:parameters success:success failure:failure];
}

#pragma mark - Private -

- (NSURLSessionDataTask *_Nullable)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(NSDictionary * _Nullable)parameters
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError *))failure
{
    NSURLRequest *request = [self buildRequestWithURLString:URLString HTTPMethod:method parameters:parameters];
    if (!request) {
        failure(nil, [NSError errorWithDomain:@"HTTP.wrong.params" code:0 userInfo:parameters]);
        return nil;
    }else{
        
        __block NSURLSessionDataTask *dataTask = nil;
        dataTask = [self registerTaskWithRequest:request
                               completionHandler:^(NSHTTPURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (error) {
                if (failure) {
                    failure(dataTask, error);
                }
            } else {
                if (success) {
                    success(dataTask, responseObject);
                }
            }
        }];
        
        [dataTask resume];
        return dataTask;
    }
}

- (NSURLSessionDataTask *) registerTaskWithRequest:(NSURLRequest*)request
                    completionHandler:(NeatoHTTPTaskCompletionCallback) completion{
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    NeatoHTTPTaskDelegate *taskDelegate = [[NeatoHTTPTaskDelegate alloc]initWithCompletion:completion];
    
    self.taskDelegates[@(dataTask.taskIdentifier)] = taskDelegate;
    return dataTask;
}

- (NSURLRequest *_Nullable)buildRequestWithURLString:(NSString *)url HTTPMethod:(NSString *)method parameters:(NSDictionary * _Nullable)parameters{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url relativeToURL:self.baseURL]];
    [request setHTTPMethod:method];
    NSError *error = nil;
    NSData *jsonData = nil;
    
    if (parameters){
        jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                       options:(NSJSONWritingOptions)0
                                                        error:&error];
    }
    if (error){
        return nil;
    }else{
        [self.headers enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            if (![request valueForHTTPHeaderField:field]) {
                [request setValue:value forHTTPHeaderField:field];
            }
        }];
        [request setHTTPBody:jsonData];
        return request;
    }
}


#pragma mark - URLSession Delegate -

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
   
    NeatoHTTPTaskDelegate *taskDelegate = self.taskDelegates[@(task.taskIdentifier)];
    if(taskDelegate){
        if(!error){
            [taskDelegate didCompleteWithResponse:(NSHTTPURLResponse*)task.response Error:nil];
        }else{
            [taskDelegate didCompleteWithResponse:nil Error:error];
        }
    }else{
        NSLog(@"TASK DELEGATE NOT FOUND");
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    
    NeatoHTTPTaskDelegate *taskDelegate = self.taskDelegates[@(dataTask.taskIdentifier)];
    if (taskDelegate){
        [taskDelegate didReceiveData:data];
    }else{
        NSLog(@"TASK DELEGATE NOT FOUND");
    }
}

@end

NS_ASSUME_NONNULL_END

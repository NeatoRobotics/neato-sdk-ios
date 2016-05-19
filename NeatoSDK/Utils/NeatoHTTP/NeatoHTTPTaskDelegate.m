//
//  NeatoHTTPTaskDelegate.m
//  NeatoHTTP
//
//  Created by Yari D'areglia on 12/05/16.
//  2016 Neato Robotics.
//

#import "NeatoHTTPTaskDelegate.h"

static dispatch_queue_t url_session_manager_processing_queue() {
    static dispatch_queue_t neato_url_session_manager_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        neato_url_session_manager_processing_queue = dispatch_queue_create("com.neato.networking.session.manager.processing", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return neato_url_session_manager_processing_queue;
}

@interface NeatoHTTPTaskDelegate()
@property(nonatomic, strong) NSMutableData *mutableData;
@property(nonatomic, copy) NeatoHTTPTaskCompletionCallback completion;
@end

@implementation NeatoHTTPTaskDelegate

- (instancetype)initWithCompletion:(NeatoHTTPTaskCompletionCallback)completion{

    self = [super init];
    if (self) {
        self.completion = completion;
        self.mutableData = [NSMutableData data];
    }
    return self;
}

- (void)didReceiveData:(NSData *)data{
    [self.mutableData appendData:data];
}

- (void)didCompleteWithResponse:(NSHTTPURLResponse*)response Error:(NSError*)error{
    
    dispatch_async(url_session_manager_processing_queue(), ^{
        if(error){
            self.completion(nil, nil, error);
        }else{
            __block NSError * _Nullable responseError = [self serializeErrorWithResponse:response];
            __block id responseObject = [self serializeResponseObjectWithResponse:response];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completion(response, responseObject, responseError);
            });
        }
    });
}

- (NSError* _Nullable)serializeErrorWithResponse:(NSHTTPURLResponse *)response{
    if (response.statusCode > 299){
        NSError *error = [NSError errorWithDomain:@"NeatoHTTP.Error" code:response.statusCode userInfo:nil];
        return error;
    }
    /*
    if ([response.MIMEType isEqualToString:@"application/json"]){
        NSError *error = [NSError errorWithDomain:@"NeatoHTTP.Error" code:0 userInfo:nil];
        return error;
    }*/
    
    return nil;
}

- (id)serializeResponseObjectWithResponse:(NSHTTPURLResponse *)response{
    
    id responseObject = nil;
    NSError *serializationError = nil;
    
    BOOL isSpace = [self.mutableData isEqualToData:[NSData dataWithBytes:" " length:1]];
    
    if (self.mutableData.length > 0 && !isSpace) {
        responseObject = [NSJSONSerialization JSONObjectWithData:self.mutableData options:0 error:&serializationError];
        
        if(serializationError){
            return nil;
        }
    } else {
        return nil;
    }
    
    return responseObject;
}

@end

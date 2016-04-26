//
//  NeatoNucleoClient.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 26/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoNucleoClient.h"
#import "NeatoHTTPSessionManager.h"
#import "NSDate+Neato.h"
#import "NSString+Neato.h"

static NSString *kNeatoNucleoMessagesPath = @"/vendors/neato/robots/%@/messages";

@interface NeatoNucleoClient ()

@end

@implementation NeatoNucleoClient

- (instancetype) initInstance
{
    return [super init];
}

+ (instancetype) sharedInstance
{
    static NeatoNucleoClient *nucleoClient;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        nucleoClient = [[super alloc]initInstance];
    });
    
    return nucleoClient;
}

- (void) sendCommand:(NSString *)command
     withParamenters:(id)parameters
         robotSerial:(NSString *)robotSerial
            robotKey:(NSString *)secretKey
            complete:(void (^)(id _Nullable, NSError * _Nullable))completionHandler{
    
    NSError *jsonSerializeError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&jsonSerializeError];
    
    if (!jsonData){
        completionHandler(nil, [NSError errorWithDomain:@"Network.InvalidParams" code:1 userInfo:nil]);
    }else{
        NSString *payload = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        NSString *unsignedString = [NSString stringWithFormat:@"%@\n%@\n%@\n",
                                    robotSerial.lowercaseString,
                                    [NSDate date].rfc1123String,
                                    payload];
        
        NSString *signedString = [unsignedString SHA256:secretKey];

        NeatoHTTPSessionManager *manager = [NeatoHTTPSessionManager setupInstanceWithNucleoAuthorization:signedString];
        
        [manager POST:@"path" parameters:parameters
         
             progress:^(NSProgress * _Nonnull uploadProgress) {}
         
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  completionHandler(responseObject, nil);
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  completionHandler(nil, error);
        }];
    }

}
@end

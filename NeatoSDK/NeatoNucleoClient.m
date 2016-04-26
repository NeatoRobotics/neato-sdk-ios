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
    
    NSMutableDictionary *payloadData = @{@"reqId":@"1", @"cmd":command};
    if (parameters){
        [payloadData setObject:parameters forKey:@"parameters"];
    }
    
    NSError *jsonSerializeError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payloadData options:0 error:&jsonSerializeError];
    NSString *payloadString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSString *dateStr = [NSDate date].rfc1123String;
    NSString *unsignedString = [NSString stringWithFormat:@"%@\n%@\n%@",
                                robotSerial.lowercaseString,
                                dateStr,
                                payloadString];
    NSLog(@"%@", unsignedString);
    NSString *signedString = [unsignedString SHA256:secretKey];
    NSLog(@"%@", signedString);
    NSLog(@"secret %@", secretKey);
    NeatoHTTPSessionManager *manager = [NeatoHTTPSessionManager managerWithNucleoAuthorization:signedString date:dateStr];
    
    NSString *path = [NSString stringWithFormat:kNeatoNucleoMessagesPath,robotSerial];
    
    [manager POST:path parameters:payloadData
     
         progress:^(NSProgress * _Nonnull uploadProgress) {}
     
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              completionHandler(responseObject, nil);
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"%@", task.originalRequest.allHTTPHeaderFields);
              completionHandler(nil, error);
    }];
}
@end

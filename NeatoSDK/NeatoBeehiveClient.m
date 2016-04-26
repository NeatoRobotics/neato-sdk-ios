//
//  NeatoBeehiveClient.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 23/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoBeehiveClient.h"
#import "NeatoAuthentication.h"
#import "NeatoHTTPSessionManager.h"

static NSString * const kNeatoBeehiveRobotsPath = @"/users/me/robots";

@implementation NeatoBeehiveClient

- (instancetype) initInstance
{
    return [super init];
}

+ (instancetype) sharedInstance
{
    static NeatoBeehiveClient *beehiveClient;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        beehiveClient = [[super alloc]initInstance];
    });
    
    return beehiveClient;
}

- (void)robots:(void (^)( NSArray* _Nullable robots, NSError *error))completionHandler {
    
    NeatoHTTPSessionManager *manager = [NeatoHTTPSessionManager authenticatedInstance];
    
    if (manager != nil){
        [manager GET:kNeatoBeehiveRobotsPath
          parameters:nil
            progress:^(NSProgress * _Nonnull downloadProgress) {}
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 
                 if ([responseObject isKindOfClass:[NSArray class]]){
                     completionHandler(responseObject, nil);
                 }else{
                     completionHandler(nil, [NSError errorWithDomain:@"Beehive.Robots" code:1 userInfo:nil]);
                 }
             }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 completionHandler(nil, error);
        }];
    }
}

@end

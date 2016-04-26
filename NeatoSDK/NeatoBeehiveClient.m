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

static NSString * const kNeatoBeehiveUserRobotsPath = @"/users/me/robots";
static NSString * const kNeatoBeehiveRobotPath = @"/robot";

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

- (void)robots:(void (^)( NSArray* _Nullable robots, NSError* _Nullable error))completionHandler {
    
    NeatoHTTPSessionManager *manager = [NeatoHTTPSessionManager authenticatedBeehiveInstance];
    
    if (manager != nil){
        [manager GET:kNeatoBeehiveUserRobotsPath
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
    }else{
        completionHandler(nil, [NSError errorWithDomain:@"OAuth" code:1 userInfo:nil]);
    }
}


@end

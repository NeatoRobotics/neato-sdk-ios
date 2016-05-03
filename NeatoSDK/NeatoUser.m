//
//  NeatoUser.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 28/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoUser.h"
#import "NeatoAuthentication.h"
#import "NeatoHTTPSessionManager.h"

static NSString * const kNeatoBeehiveUserRobotsPath = @"/users/me/robots";
static NSString * const kNeatoBeehiveUserInfoPath = @"/users/me";

@implementation NeatoUser

#pragma mark - Public -

- (BOOL)isAuthenticated{
    return [[NeatoAuthentication sharedInstance] isAuthenticated];
}

- (void) getRobotsWithCompletion:(void(^)(NSArray<NeatoRobot*> *robots, NSError * _Nullable error))completionHandler{
    NeatoHTTPSessionManager *manager = [NeatoHTTPSessionManager authenticatedBeehiveManager];
    
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

- (void) getUserInfo:(void(^)(NSDictionary* userinfo, NSError * _Nullable error))completionHandler{
    NeatoHTTPSessionManager *manager = [NeatoHTTPSessionManager authenticatedBeehiveManager];
    
    if (manager != nil){
        [manager GET:kNeatoBeehiveUserInfoPath
          parameters:nil
            progress:^(NSProgress * _Nonnull downloadProgress) {}
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 completionHandler(responseObject, nil);
             }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 completionHandler(nil, error);
             }];
    }else{
        completionHandler(nil, [NSError errorWithDomain:@"OAuth" code:1 userInfo:nil]);
    }
}

@end

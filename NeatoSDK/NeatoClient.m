//
//  NeatoClient.m
//  iossdk
//
//  Created by Yari D'areglia
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoClient.h"
#import "NeatoAuthentication.h"
#import "NeatoHTTPSessionManager.h"
#import "NeatoBeehiveClient.h"
#import "NeatoNucleoClient.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NeatoClient

- (instancetype)initInstance{
    return [super init];
}

+ (instancetype)sharedInstance{
    static NeatoClient *neatoClient;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        neatoClient = [[super alloc]initInstance];
    });
    
    return neatoClient;
}

#pragma mark - NeatoAuthentication Bridge

+ (void)configureWithClientID:(NSString *)clientID scopes:(NSArray<NSString *> *)scopes redirectURI:(NSString *)redirectURI{
    [NeatoAuthentication configureWithClientID:clientID
                                        scopes:scopes
                                   redirectURI:redirectURI];
}

- (void)openLoginInBrowserWithCompletion:(void (^)(NSError * _Nonnull))completionHandler{
    [[NeatoAuthentication sharedInstance] openLoginInBrowserWithCompletion:^(NSError * _Nullable error) {
        completionHandler(error);
    }];
}

- (void)handleURL:(NSURL*)url{
    [[NeatoAuthentication sharedInstance]handleURL:url];
}

- (BOOL)isAuthenticated{
    return [[NeatoAuthentication sharedInstance]isAuthenticated];
}

- (void)logoutWithCompletion:(void (^)(NSError * _Nonnull))completionHandler{
    [[NeatoAuthentication sharedInstance]logoutWithCompletion:completionHandler];
}

#pragma mark - NeatoBeehiveClient Bridge

- (void) robotsWithCompletion:(void (^)(NSArray* _Nullable robots, NSError *error))completionHandler{
    [[NeatoBeehiveClient sharedInstance] robotsWithCompletion:^(NSArray * _Nullable robots, NSError * _Nonnull error) {
        completionHandler(robots, error);
    }];
}

@end

NS_ASSUME_NONNULL_END

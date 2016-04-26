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

@interface NeatoClient()
@end

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

- (void)openLoginInBrowser:(void (^)(NSError * _Nonnull))completionHandler{
    [[NeatoAuthentication sharedInstance] openLoginInBrowser:^(NSError * _Nullable error) {
        completionHandler(error);
    }];
}

- (void)handleURL:(NSURL*)url{
    [[NeatoAuthentication sharedInstance]handleURL:url];
}

- (BOOL)isAuthenticated{
    return [[NeatoAuthentication sharedInstance]isAuthenticated];
}

- (void)logout:(void (^)(NSError * _Nonnull))completionHandler{
    [[NeatoAuthentication sharedInstance]logout:completionHandler];
}

#pragma mark - NeatoBeehiveClient Bridge

- (void) robots:(void (^)(NSArray* _Nullable robots, NSError *error))completionHandler{
    [[NeatoBeehiveClient sharedInstance] robots:^(NSArray * _Nullable robots, NSError * _Nonnull error) {
        completionHandler(robots, error);
    }];
}

#pragma mark - NeatoNucleClient Bridge

- (void) getRobotState:(NSString *)robotSerial robotSecretKey:(NSString*)robotSecretKey complete:(void (^)(id _Nullable robotState, NSError *error))completionHandler{
    
    [[NeatoNucleoClient sharedInstance] sendCommand:@"getRobotState" withParamenters:nil
                                        robotSerial:robotSerial robotKey:robotSecretKey
                                           complete:^(id _Nullable robotState, NSError * _Nullable error) {
                                               NSLog(@"ERROR %@", error);
                                               NSLog(@"STATE %@", robotState);
                                               
    }];
}

@end

NS_ASSUME_NONNULL_END

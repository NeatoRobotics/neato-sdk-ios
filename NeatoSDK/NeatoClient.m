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

- (void)sendCommand:(NSString*)command toRobot:(NSString *)robotSerial secretKey:(NSString *)robotSecretKey parameters:(NSDictionary* _Nullable) parameters complete:(void (^)(id _Nullable response, NSError *error))completionHandler;

- (void)sendStateCommand:(NSString*)command toRobot:(NSString *)robotSerial secretKey:(NSString *)robotSecretKey parameters:(NSDictionary* _Nullable) parameters complete:(void (^)(id _Nullable robotState, bool online, NSError *error))completionHandler;

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

- (void)sendCommand:(NSString*)command toRobot:(NSString *)robotSerial secretKey:(NSString *)robotSecretKey parameters:(NSDictionary* _Nullable) parameters complete:(void (^)(id _Nullable response, NSError *error))completionHandler{
    
    [[NeatoNucleoClient sharedInstance] sendCommand:command withParamenters:parameters
                                        robotSerial:robotSerial robotKey:robotSecretKey
                                           complete:^(id _Nullable response, NSError * _Nullable error) {
                                               
                                               completionHandler(response, error);
                                           }];
    
}

- (void)sendStateCommand:(NSString*)command toRobot:(NSString *)robotSerial secretKey:(NSString *)robotSecretKey parameters:(NSDictionary* _Nullable) parameters complete:(void (^)(id _Nullable robotState, bool online, NSError *error))completionHandler{

    [[NeatoNucleoClient sharedInstance] sendCommand:command withParamenters:parameters
                                        robotSerial:robotSerial robotKey:robotSecretKey
                                           complete:^(id _Nullable robotState, NSError * _Nullable error) {
                                               
                                               completionHandler(robotState, (error == nil), error);
                                           }];
}

- (void) getRobotState:(NSString *)robotSerial robotSecretKey:(NSString*)robotSecretKey complete:(void (^)(id _Nullable robotState, bool online, NSError *error))completionHandler{
    
    [self sendStateCommand:@"getRobotState" toRobot:robotSerial secretKey:robotSecretKey parameters:nil complete:^(id  _Nullable robotState, bool online, NSError * _Nonnull error) {
        completionHandler(robotState, online, error);
    }];
}

- (void) getRobotInfo:(NSString *)robotSerial robotSecretKey:(NSString*)robotSecretKey complete:(void (^)(id _Nullable robotInfo, NSError *error))completionHandler{
   
    [self sendCommand:@"getRobotInfo" toRobot:robotSerial secretKey:robotSecretKey parameters:nil complete:^(id  _Nullable response, NSError * _Nonnull error) {
        completionHandler(response, error);
    }];
}

- (void) startCleaning:(NSString *)robotSerial robotSecretKey:(NSString*)robotSecretKey parameters:(NSDictionary *)parameters complete:(void (^)(id _Nullable robotState, bool online, NSError *error))completionHandler{
    
    [self sendStateCommand:@"startCleaning" toRobot:robotSerial secretKey:robotSecretKey parameters:parameters complete:^(id  _Nullable robotState, bool online, NSError * _Nonnull error) {
        completionHandler(robotState, online, error);
    }];
}

- (void) pauseCleaning:(NSString *)robotSerial robotSecretKey:(NSString*)robotSecretKey complete:(void (^)(id _Nullable robotState, bool online, NSError *error))completionHandler{
    
    [self sendStateCommand:@"pauseCleaning" toRobot:robotSerial secretKey:robotSecretKey parameters:nil complete:^(id  _Nullable robotState, bool online, NSError * _Nonnull error) {
        completionHandler(robotState, online, error);
    }];
}

- (void) stopCleaning:(NSString *)robotSerial robotSecretKey:(NSString*)robotSecretKey complete:(void (^)(id _Nullable robotState, bool online, NSError *error))completionHandler{
    
    [self sendStateCommand:@"stopCleaning" toRobot:robotSerial secretKey:robotSecretKey parameters:nil complete:^(id  _Nullable robotState, bool online, NSError * _Nonnull error) {
        completionHandler(robotState, online, error);
    }];
}

- (void) enableSchedule:(NSString *)robotSerial robotSecretKey:(NSString*)robotSecretKey complete:(void (^)(id _Nullable robotInfo, NSError *error))completionHandler{
    
    [self sendCommand:@"enableSchedule" toRobot:robotSerial secretKey:robotSecretKey parameters:nil complete:^(id  _Nullable response, NSError * _Nonnull error) {
        completionHandler(response, error);
    }];
}

- (void) disableSchedule:(NSString *)robotSerial robotSecretKey:(NSString*)robotSecretKey complete:(void (^)(id _Nullable robotInfo, NSError *error))completionHandler{
    
    [self sendCommand:@"disableSchedule" toRobot:robotSerial secretKey:robotSecretKey parameters:nil complete:^(id  _Nullable response, NSError * _Nonnull error) {
        completionHandler(response, error);
    }];
}

@end

NS_ASSUME_NONNULL_END

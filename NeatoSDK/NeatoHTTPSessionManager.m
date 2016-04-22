//
//  NeatoHTTPSessionManager.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 31/03/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoHTTPSessionManager.h"

@import AFNetworking;

NSString * const kNeatoAPIBaseURLPath = @"https://beehive-playground.neatocloud.com/";

@implementation NeatoHTTPSessionManager

+ (instancetype) sharedInstance {
    static NeatoHTTPSessionManager *_sharedInstance= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NeatoHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kNeatoAPIBaseURLPath]];
    });
    
    return _sharedInstance;
}

+ (instancetype) setupInstanceWithAccessToken:(NSString*)token {
    NeatoHTTPSessionManager *manager = [NeatoHTTPSessionManager sharedInstance];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *value = [NSString stringWithFormat:@"Bearer %@", token];
    [manager.requestSerializer setValue:value forHTTPHeaderField:@"Authorization"];
    return manager;
}

@end

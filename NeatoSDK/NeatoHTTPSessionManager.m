//
//  NeatoHTTPSessionManager.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 31/03/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoHTTPSessionManager.h"
#import "NeatoAuthentication.h"

@import AFNetworking;

NSString * const kBeehiveBaseURLPath = @"https://beehive-playground.neatocloud.com/";
NSString * const kNucleoBaseURLPath = @"https://nucleo.neatocloud.com:4443/";

@interface NeatoHTTPSessionManager()
+ (instancetype) managerWithAuthorization:(NSString *)key value:(NSString *)value baseURL:(NSString*)url;
@end

@implementation NeatoHTTPSessionManager

+ (_Nullable instancetype) authenticatedBeehiveManager{
    if ([NeatoAuthentication sharedInstance].isAuthenticated){
        return [self managerWithBeehiveAuthorization:[NeatoAuthentication sharedInstance].accessToken];
    }else{
        return nil;
    }
}

+ (instancetype) managerWithBeehiveAuthorization:(NSString*)token {
    return [self managerWithAuthorization:@"Bearer" value:token baseURL:kBeehiveBaseURLPath];
}

+ (instancetype) managerWithNucleoAuthorization:(NSString*)signedString{
    return [self managerWithAuthorization:@"NEATOAPP" value:signedString baseURL:kNucleoBaseURLPath];
}

+ (instancetype) managerWithAuthorization:(NSString *)key value:(NSString *)value baseURL:(NSString*)url{
    
    NeatoHTTPSessionManager *manager = [[self alloc]initWithBaseURL:[NSURL URLWithString:url]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *authValue = [NSString stringWithFormat:@"%@ %@", key, value];
    [manager.requestSerializer setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    return manager;
}

@end

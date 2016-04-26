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
+ (instancetype) setupInstanceWithAuthorization:(NSString *)key value:(NSString *)value baseURL:(NSString*)url;
@end

@implementation NeatoHTTPSessionManager

+ (_Nullable instancetype) authenticatedBeehiveInstance{
    if ([NeatoAuthentication sharedInstance].isAuthenticated){
        return [self setupInstanceWithBeehiveAuthorization:[NeatoAuthentication sharedInstance].accessToken];
    }else{
        return nil;
    }
}

+ (instancetype) setupInstanceWithBeehiveAuthorization:(NSString*)token {
    return [self setupInstanceWithAuthorization:@"Bearer" value:token baseURL:kBeehiveBaseURLPath];
}

+ (instancetype) setupInstanceWithNucleoAuthorization:(NSString*)signedString{
    return [self setupInstanceWithAuthorization:@"NEATOAPP" value:signedString baseURL:kNucleoBaseURLPath];
}

+ (instancetype) setupInstanceWithAuthorization:(NSString *)key value:(NSString *)value baseURL:(NSString*)url{
    
    NeatoHTTPSessionManager *manager = [[self alloc]initWithBaseURL:[NSURL URLWithString:url]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *authValue = [NSString stringWithFormat:@"%@ %@", key, value];
    [manager.requestSerializer setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    return manager;
}

@end

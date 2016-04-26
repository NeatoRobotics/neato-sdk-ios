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
NSString * const kNucleoBaseURLPath = @"https://nucleo-playground.neatocloud.com:4443/";

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

+ (instancetype) managerWithNucleoAuthorization:(NSString*)signedString date:(NSString*)date{
    
    NeatoHTTPSessionManager *manager = [[self alloc]initWithBaseURL:[NSURL URLWithString:kNucleoBaseURLPath]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *authValue = [NSString stringWithFormat:@"NEATOAPP %@", signedString];
    [manager.requestSerializer setValue:authValue forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/vnd.neato.nucleo.v1" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:date forHTTPHeaderField:@"Date"];
    [manager.requestSerializer setValue:@"iOS-SDK" forHTTPHeaderField:@"X-Agent"];
    
    return manager;
}

+ (instancetype) managerWithAuthorization:(NSString *)key value:(NSString *)value baseURL:(NSString*)url{
    
    NeatoHTTPSessionManager *manager = [[self alloc]initWithBaseURL:[NSURL URLWithString:url]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *authValue = [NSString stringWithFormat:@"%@ %@", key, value];
    [manager.requestSerializer setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    return manager;
}

@end

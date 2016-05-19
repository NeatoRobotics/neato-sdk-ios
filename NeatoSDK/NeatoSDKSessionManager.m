//
//  NeatoHTTPSessionManager.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 31/03/16.
//  2016 Neato Robotics.
//

#import "NeatoSDKSessionManager.h"
#import "NeatoAuthentication.h"

NSString * const kBeehiveBaseURLPath = @"https://beehive.neatocloud.com/";
NSString * const kNucleoBaseURLPath = @"https://nucleo.neatocloud.com:4443/";

@interface NeatoSDKSessionManager()
+ (instancetype) managerWithAuthorization:(NSString *)key value:(NSString *)value baseURL:(NSString*)url;
@end

@implementation NeatoSDKSessionManager

+ (_Nullable instancetype) authenticatedBeehiveManager{
    if ([NeatoAuthentication sharedInstance].isAuthenticated){
        return [self managerWithBeehiveAuthorization:[[[NeatoAuthentication sharedInstance] tokenStore] readStoredAccessToken]];
    }else{        
        return nil;
    }
}

+ (instancetype) managerWithBeehiveAuthorization:(NSString*)token {
    return [self managerWithAuthorization:@"Bearer" value:token baseURL:kBeehiveBaseURLPath];
}

+ (instancetype) managerWithNucleoAuthorization:(NSString*)signedString date:(NSString*)date{
    
    NeatoSDKSessionManager *manager = [[self alloc]initWithBaseURL:[NSURL URLWithString:kNucleoBaseURLPath]];
    NSString *authValue = [NSString stringWithFormat:@"NEATOAPP %@", signedString];
    [manager setValue:authValue forHTTPHeaderField:@"Authorization"];
    [manager setValue:@"application/vnd.neato.nucleo.v1" forHTTPHeaderField:@"Accept"];
    [manager setValue:date forHTTPHeaderField:@"Date"];
    [manager setValue:@"iOS-SDK" forHTTPHeaderField:@"X-Agent"];
    
    return manager;
}

+ (instancetype) managerWithAuthorization:(NSString *)key value:(NSString *)value baseURL:(NSString*)url{
    
    NeatoSDKSessionManager *manager = [[self alloc]initWithBaseURL:[NSURL URLWithString:url]];
    NSString *authValue = [NSString stringWithFormat:@"%@ %@", key, value];
    [manager setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    return manager;
}

@end

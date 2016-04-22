//
//  NeatoTokenStore.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 29/03/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoTokenUserDefaultStore.h"

#pragma mark - Constants and Typedef

NSString * const kNeatoOAuthAccessTokenStoreKey = @"kNeatoOAuthTokenValue";
NSString * const kNeatoOAuthAccessTokenExpirationStoreKey = @"kNeatoOAuthTokenExpirationDate";

#pragma mark - NeatoTokenUserDefaultStore Class Implementation

@implementation NeatoTokenUserDefaultStore

#pragma mark - Public Methods

- (void) storeAccessToken:(NSString *) tokenValue expirationDate:(NSDate*)expirationDate{
    NSUserDefaults *uDefault = [NSUserDefaults standardUserDefaults];
    
    if(tokenValue != nil){
        [uDefault setObject:tokenValue forKey:kNeatoOAuthAccessTokenStoreKey];
    }
    
    if(expirationDate != nil){
        [uDefault setObject:expirationDate forKey:kNeatoOAuthAccessTokenExpirationStoreKey];
        [uDefault synchronize];
    }
    
    [uDefault synchronize];
}

- (NSString*) readStoredAccessToken{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kNeatoOAuthAccessTokenStoreKey];
}

- (NSDate*) readStoredAccessTokenExpirationDate{
    id dateObj = [[NSUserDefaults standardUserDefaults] objectForKey:kNeatoOAuthAccessTokenExpirationStoreKey];
    if ([dateObj isKindOfClass:[NSDate class]]){
        return (NSDate*)dateObj;
    }else{
        return nil;
    }
}

- (void) reset{
    NSUserDefaults *uDefault = [NSUserDefaults standardUserDefaults];
    [uDefault removeObjectForKey:kNeatoOAuthAccessTokenStoreKey];
    [uDefault removeObjectForKey:kNeatoOAuthAccessTokenExpirationStoreKey];
}

@end

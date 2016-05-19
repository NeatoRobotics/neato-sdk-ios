//
//  TestHelpers.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 27/04/16.
//  2016 Neato Robotics.
//

#import <Foundation/Foundation.h>
#import "MockNeatoTokenStore.h"

@import NeatoSDK;

//Sign in with custom token storer
void signInUser(){
    [NeatoAuthentication sharedInstance].tokenStore = [[MockNeatoTokenStore alloc]init];
    [[NeatoAuthentication sharedInstance].tokenStore storeAccessToken:@"a_valid_access_token"
                                                       expirationDate:[NSDate dateWithTimeIntervalSinceNow:10000]];
}

// Sign in with userDefault token storer
void signInUserDefault(){
    [NeatoAuthentication sharedInstance].tokenStore = [NeatoTokenUserDefaultStore new];
    [[NeatoAuthentication sharedInstance].tokenStore storeAccessToken:@"a_valid_access_token"
                                                       expirationDate:[NSDate dateWithTimeIntervalSinceNow:10000]];
}

void logoutUserDefault(){
    [NeatoAuthentication sharedInstance].tokenStore = [NeatoTokenUserDefaultStore new];
    [[NeatoAuthentication sharedInstance].tokenStore storeAccessToken:@"an_expired_access_token"
                                                       expirationDate:[NSDate dateWithTimeIntervalSinceNow:-10000]];
}
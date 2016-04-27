//
//  TestHelpers.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 27/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MockNeatoTokenStore.h"

@import NeatoSDK;

void signInUser(){
    [NeatoAuthentication sharedInstance].tokenStore = [[MockNeatoTokenStore alloc]init];
    [[NeatoAuthentication sharedInstance].tokenStore storeAccessToken:@"a_valid_access_token"
                                                       expirationDate:[NSDate dateWithTimeIntervalSinceNow:10000]];
}
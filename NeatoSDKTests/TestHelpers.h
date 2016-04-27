#ifndef TestHelpers_h
#define TestHelpers_h

#import "MockNeatoTokenStore.h"

@import NeatoSDK;

void signInUser(){
    [NeatoAuthentication sharedInstance].tokenStore = [[MockNeatoTokenStore alloc]init];
    [[NeatoAuthentication sharedInstance].tokenStore storeAccessToken:@"a_valid_access_token"
                                                       expirationDate:[NSDate dateWithTimeIntervalSinceNow:10000]];
}


#endif /* TestHelpers_h */

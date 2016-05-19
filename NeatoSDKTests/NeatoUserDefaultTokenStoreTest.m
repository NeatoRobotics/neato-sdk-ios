//
//  NeatoUserDefaultTokenStoreTest.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 29/03/16.
//  2016 Neato Robotics.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import "NeatoTokenUserDefaultStore.h"

@import NeatoSDK;

SpecBegin(NeatoUserDefaultTokenStore)

describe(@"NeatoUserDefaultTokenStore", ^{
    __block NeatoTokenUserDefaultStore* userDefaultStore;
    
    describe(@"Store", ^{
    
        beforeAll(^{
            userDefaultStore = [[NeatoTokenUserDefaultStore alloc]init];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNeatoOAuthAccessTokenStoreKey];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNeatoOAuthAccessTokenExpirationStoreKey];
        });
        
        context(@"when a valid token value is received", ^{
            before(^{
                [userDefaultStore storeAccessToken:@"the_token" expirationDate:[NSDate dateWithTimeIntervalSinceNow:1000]];
            });
            
            it(@"stores the token", ^{
                expect([[NSUserDefaults standardUserDefaults] stringForKey:kNeatoOAuthAccessTokenStoreKey]).to.equal(@"the_token");
            });
        });
        
        context(@"when token data is cleared", ^{
            before(^{
                [userDefaultStore storeAccessToken:@"the_token_2" expirationDate:[NSDate dateWithTimeIntervalSinceNow:1000]];
                [userDefaultStore reset];
            });
            
            it(@"removes the token from the store", ^{
                expect([[NSUserDefaults standardUserDefaults] stringForKey:kNeatoOAuthAccessTokenStoreKey]).to.beNil;
                expect([[NSUserDefaults standardUserDefaults] stringForKey:kNeatoOAuthAccessTokenExpirationStoreKey]).to.beNil;
            });
        });

        context(@"when token info is requested", ^{
            before(^{
                [userDefaultStore storeAccessToken:@"the_token_3" expirationDate:[NSDate dateWithTimeIntervalSinceNow:1000]];
            });
            
            it(@"receives the token previously stored", ^{
                expect([[NSUserDefaults standardUserDefaults] stringForKey:kNeatoOAuthAccessTokenStoreKey]).to.equal([userDefaultStore readStoredAccessToken]);
                expect([[NSUserDefaults standardUserDefaults] objectForKey:kNeatoOAuthAccessTokenExpirationStoreKey]).to.equal([userDefaultStore readStoredAccessTokenExpirationDate]);
            });
        });
        
        context(@"when an object different by NSDate is stored for token expiration key", ^{ // unlikely to happen.
            before(^{
                [[NSUserDefaults standardUserDefaults] setObject:@"a wrong object" forKey:kNeatoOAuthAccessTokenExpirationStoreKey];
            });
            
            it(@"returns nil", ^{
                expect([userDefaultStore readStoredAccessTokenExpirationDate]).to.beNil;
            });
        });
    });
});

SpecEnd

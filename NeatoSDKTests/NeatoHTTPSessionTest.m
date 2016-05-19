#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import "NeatoSDKSessionManager.h"
#import "MockNeatoTokenStore.h"

@import NeatoSDK;

SpecBegin(NeatoHTTPSession)

describe(@"NeatoHTTPSessionManager", ^{
    
    describe(@"Nucleo manager", ^{
        
        context(@"when initialized", ^{
            
            it(@"has the right headers", ^{
                NeatoSDKSessionManager *manager = [NeatoSDKSessionManager managerWithNucleoAuthorization:@"a_string" date:@"a_date"];
                NSString *authHeader = [manager valueForHTTPHeaderField:@"Authorization"];
                NSString *dateHeader = [manager valueForHTTPHeaderField:@"Date"];
                expect(authHeader).to.equal(@"NEATOAPP a_string");
                expect(dateHeader).to.equal(@"a_date");
            });
        });
    });
    
    describe(@"Beehive manager", ^{
        context(@"when initialized", ^{
            it(@"has the right headers", ^{
                NeatoSDKSessionManager *manager = [NeatoSDKSessionManager managerWithBeehiveAuthorization:@"a_token"];
                NSString *authHeader = [manager valueForHTTPHeaderField:@"Authorization"];
                expect(authHeader).to.equal(@"Bearer a_token");
            });
        });
        
        describe(@"request authenticated manager", ^{
            context(@"when user is authorized", ^{
                
                before(^{
                    [NeatoAuthentication sharedInstance].tokenStore = [[MockNeatoTokenStore alloc]init];
                    [[NeatoAuthentication sharedInstance].tokenStore storeAccessToken:@"a_valid_access_token"
                                                                       expirationDate:[NSDate dateWithTimeIntervalSinceNow:10000]];
                });
                
                it(@"uses the current auth token", ^{
                    expect([[[NeatoAuthentication sharedInstance] tokenStore] readStoredAccessToken]).to.equal(@"a_valid_access_token");
                    NeatoSDKSessionManager *manager = [NeatoSDKSessionManager authenticatedBeehiveManager];
                    NSString *authHeader = [manager valueForHTTPHeaderField:@"Authorization"];
                    expect(authHeader).to.equal(@"Bearer a_valid_access_token");
                });
            });
            
            context(@"when user is not authorized", ^{
                before(^{
                    [NeatoAuthentication sharedInstance].tokenStore = [[MockNeatoTokenStore alloc]init];
                    [[NeatoAuthentication sharedInstance].tokenStore reset];
                });
                
                it(@"uses the current auth token", ^{
                    NeatoSDKSessionManager *manager = [NeatoSDKSessionManager authenticatedBeehiveManager];
                    expect(manager).to.beNil();
                });
            });

        });
    });
});

SpecEnd
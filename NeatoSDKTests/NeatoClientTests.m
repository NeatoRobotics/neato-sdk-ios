//
//  NeatoClientTests.m
//  iossdk
//
//  Created by Yari D'areglia on 21/03/16.
//

#import <AFNetworking/AFNetworking.h>
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import "MockNeatoTokenStore.h"

@import NeatoSDK;

SpecBegin(NeatoClient)

describe(@"NeatoClient", ^{
    
    describe(@"Singleton", ^{

        context(@"when is requested", ^{
            
            it(@"is expected to return an instance :)", ^{
                expect([NeatoClient sharedInstance]).toNot.beNil();
            });
        });
        
        describe(@"Configured", ^{
            before(^{
                [NeatoClient configureWithClientID:@"test-client"
                                            scopes:@[NeatoOAuthScopeControlRobots]
                                       redirectURI:@"test-url://redirect"];
            });

            it(@"has passed a clientID to NeatoAuthentication", ^{
                expect([NeatoAuthentication sharedInstance].clientID).to.equal(@"test-client");
            });
            
            it(@"has passed a redirect URL to NeatoAuthentication", ^{
                expect([NeatoAuthentication sharedInstance].redirectURI).to.equal(@"test-url://redirect");
            });
            
            it(@"has passed scopes to NeatoAuthentication", ^{
                expect([NeatoAuthentication sharedInstance].authScopes).to.equal(@[NeatoOAuthScopeControlRobots]);
            });
        });

        describe(@"HandleURL", ^{
            
            __block NSError *auth_error;
            
            beforeAll(^{
                [NeatoClient configureWithClientID:@"acliendid"
                                                    scopes:@[NeatoOAuthScopeControlRobots]
                                               redirectURI:@"test-app://neato"];
                
                [NeatoAuthentication sharedInstance].tokenStore = [[MockNeatoTokenStore alloc]init];
            });
            
            beforeEach(^{
                auth_error = nil;
            });
            
            context(@"when receives a valid url", ^{
                before(^{
                    [[NeatoClient sharedInstance] openLoginInBrowser:^(NSError *error) {
                        auth_error = error;
                    }];
                    
                    [[NeatoClient sharedInstance] handleURL:[NSURL URLWithString:@"redirect://url#access_token=this_is_the_token&expires_in=10000"]];
                });
                
                it(@"has setup the NeatoAuthentication with the token", ^{
                    expect([NeatoAuthentication sharedInstance].accessToken).to.equal(@"this_is_the_token");
                });
            });
        });
        
        
        describe(@"Request authentication state", ^{
            
            context(@"when a valid token is stored", ^{
                
                before(^{
                    [NeatoAuthentication sharedInstance].tokenStore = [[MockNeatoTokenStore alloc]init];
                    [[NeatoAuthentication sharedInstance].tokenStore storeAccessToken:@"a_valid_access_token"
                                                                       expirationDate:[NSDate dateWithTimeIntervalSinceNow:10000]];
                });
                
                it(@"receives true", ^{
                    expect([[NeatoClient sharedInstance] isAuthenticated]).to.equal(true);
                });
            });
            
            context(@"when an expired token is stored", ^{
                
                before(^{
                    [NeatoAuthentication sharedInstance].tokenStore = [[MockNeatoTokenStore alloc]init];
                    [[NeatoAuthentication sharedInstance].tokenStore storeAccessToken:@"an_old_access_token"
                                                                       expirationDate:[NSDate dateWithTimeIntervalSinceNow:-10000]];
                });
                
                it(@"receives false", ^{
                    expect([[NeatoClient sharedInstance] isAuthenticated]).to.equal(false);
                });
            });
        });
        
     });
    
});

SpecEnd

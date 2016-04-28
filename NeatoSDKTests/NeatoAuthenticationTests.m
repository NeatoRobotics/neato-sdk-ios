//
//  NeatoAuthenticationTests.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 25/03/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//


#import <AFNetworking/AFNetworking.h>
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHHTTPStubsResponse+JSON.h>
#import "MockNeatoTokenStore.h"

@import NeatoSDK;

SpecBegin(NeatoAuthentication)

describe(@"NeatoAuthentication", ^{
    
    describe(@"Singleton", ^{
        
        context(@"when is requested", ^{
            
            it(@"returns an instance :)", ^{
                expect([NeatoAuthentication sharedInstance]).toNot.beNil();
            });
        });
        
        describe(@"Configured", ^{
            
            [NeatoAuthentication configureWithClientID:@"test-client"
                                                scopes:@[NeatoOAuthScopeControlRobots]
                                           redirectURI:@"test-url://redirect"];
            
            it(@"has a clientID", ^{
                expect([NeatoAuthentication sharedInstance].clientID).to.equal(@"test-client");
            });
            
            it(@"has a redirect URL", ^{
                expect([NeatoAuthentication sharedInstance].redirectURI).to.equal(@"test-url://redirect");
            });
            
            it(@"has scopes", ^{
                expect([NeatoAuthentication sharedInstance].authScopes).to.equal(@[NeatoOAuthScopeControlRobots]);
            });
        });
    });
    
    describe(@"HandleURL", ^{
        
        __block NSString *auth_token_received;
        __block NSError *auth_error;
        
        beforeAll(^{
            [NeatoAuthentication configureWithClientID:@"acliendid"
                                                scopes:@[NeatoOAuthScopeControlRobots]
                                           redirectURI:@"test-app://neato"];
            
            [NeatoAuthentication sharedInstance].tokenStore = [[MockNeatoTokenStore alloc]init];
        });
        
        beforeEach(^{
            auth_error = nil;
        });
        
        context(@"when receives a valid url", ^{
            before(^{
                [[NeatoAuthentication sharedInstance] openLoginInBrowserWithCompletion:^(NSError *error) {
                    auth_error = error;
                }];
                
                [[NeatoAuthentication sharedInstance] handleURL:[NSURL URLWithString:@"redirect://url#access_token=this_is_the_token&expires_in=10000"]];
            });

            it(@"gets the access token", ^{
                expect([NeatoAuthentication sharedInstance].accessToken).to.equal(@"this_is_the_token");
            });
            
            it(@"gets the access token expiration date", ^{
                
                NSDate *from = [NSDate dateWithTimeInterval:9990 sinceDate: [NSDate date]];
                NSDate *to = [NSDate dateWithTimeInterval:10001 sinceDate: [NSDate date]];

                expect([NeatoAuthentication sharedInstance].accessTokenExpiration).to.beInTheRangeOf(from,to);
            });
            
            it(@"calls the completion callback without an error", ^{
                expect(auth_error).to.beNil;
            });
            
            it(@"stores the token value", ^{
                expect([[NeatoAuthentication sharedInstance].tokenStore readStoredAccessToken]).to.equal(@"this_is_the_token");
            });
            
            it(@"stores the token expiration date", ^{
                expect([[NeatoAuthentication sharedInstance].tokenStore readStoredAccessTokenExpirationDate]).to.equal([NeatoAuthentication sharedInstance].accessTokenExpiration);
            });
        });
        
        context(@"when receives an invalid url", ^{
            
            before(^{
                [[NeatoAuthentication sharedInstance] handleURL:[NSURL URLWithString:@"redirect://url#error=this_is_invalid"]];
            });
            
            it(@"doesn't have a token", ^{
                expect([NeatoAuthentication sharedInstance].accessToken).to.equal(NULL);
            });
            
            it(@"calls the completion callback with an error", ^{
                expect(auth_error).notTo.beNil;
                expect(auth_token_received).to.beNil;
                //expect(auth_error.domain).to.equal("denied.authentication.neato");
                expect(auth_error.code).to.equal(1);
            });
        });
    });
    
    describe(@"Authentication state", ^{
        
        context(@"when a valid token is stored", ^{
            
            before(^{
                [NeatoAuthentication sharedInstance].tokenStore = [[MockNeatoTokenStore alloc]init];
                [[NeatoAuthentication sharedInstance].tokenStore storeAccessToken:@"a_valid_access_token"
                                                                   expirationDate:[NSDate dateWithTimeIntervalSinceNow:10000]];
            });
            
            it(@"is authenticated", ^{
                expect([[NeatoAuthentication sharedInstance] isAuthenticated]).to.equal(true);
            });
        });
        
        context(@"when an expired token is stored", ^{
            
            before(^{
                [NeatoAuthentication sharedInstance].tokenStore = [[MockNeatoTokenStore alloc]init];
                [[NeatoAuthentication sharedInstance].tokenStore storeAccessToken:@"an_old_access_token"
                                                                   expirationDate:[NSDate dateWithTimeIntervalSinceNow:-10000]];
            });
            
            it(@"is not authenticated", ^{
                expect([[NeatoAuthentication sharedInstance] isAuthenticated]).to.equal(false);
            });
        });
    });
    
    describe(@"Logout", ^{
        
        beforeEach(^{
            [NeatoAuthentication configureWithClientID:@"acliendid"
                                                scopes:@[NeatoOAuthScopeControlRobots]
                                           redirectURI:@"test-app://neato"];
            
            [NeatoAuthentication sharedInstance].tokenStore = [[MockNeatoTokenStore alloc]init];
            [[NeatoAuthentication sharedInstance] handleURL:[NSURL URLWithString:@"redirect://url#access_token=this_is_the_token&expires_in=10000"]];
        });
        
        context(@"when a valid session is stored", ^{

            before(^{
                [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return [request.URL.path isEqualToString:@"/oauth2/revoke"];
                } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
                    NSDictionary* obj = @{ @"key1": @"value1", @"key2": @[@"value2A", @"value2B"] };
                    return [OHHTTPStubsResponse responseWithJSONObject:obj statusCode:200 headers:@{@"Content-Type": @"application/json"}];
                }].name = @"revoke";
            });
            
            after(^{
                [OHHTTPStubs removeAllStubs];
            });
            
            it(@"deletes the session", ^ {
                waitUntil(^(DoneCallback done) {
                    
                    [[NeatoAuthentication sharedInstance] logoutWithCompletion:^(NSError * _Nullable error) {
                        expect([NeatoAuthentication sharedInstance].isAuthenticated).to.equal(false);
                        done(); 
                    }];
                });
            });
        });
        
        context(@"when an error occured", ^{
            
            before(^{
                [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return [request.URL.path isEqualToString:@"/oauth2/revoke"];
                } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
                    NSDictionary* obj = @{};
                    return [OHHTTPStubsResponse responseWithJSONObject:obj statusCode:400 headers:@{@"Content-Type": @"application/json"}];
                }].name = @"revoke";
            });
            
            after(^{
                [OHHTTPStubs removeAllStubs];
            });
            
            it(@"keeps the session", ^ {
                waitUntil(^(DoneCallback done) {
                    
                    [[NeatoAuthentication sharedInstance] logoutWithCompletion:^(NSError * _Nullable error) {
                        expect([NeatoAuthentication sharedInstance].isAuthenticated).to.equal(true);
                        done();
                    }];
                });
            });
        });
    });
    
});

SpecEnd


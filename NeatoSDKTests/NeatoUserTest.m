//
//  NeatoBeehiveClientTest.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 26/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHHTTPStubsResponse+JSON.h>
#import <OHHTTPStubs/OHPathHelpers.h>
#import "OHHTTPStubs+Neato.h"
#import "TestHelpers.h"
#import "MockNeatoTokenStore.h"

@import NeatoSDK;

SpecBegin(NeatoUser)

describe(@"NeatoUser", ^{
    
    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });

    describe(@"Authenticated", ^{
        context(@"when user is authenticated", ^{
           
            before(^{
                signInUserDefault();
            });
            
            it(@"returns true",^{
                NeatoUser *user = [NeatoUser new];
                expect([user isAuthenticated]).to.equal(true);
            });
        });
        
        context(@"when user is logged out", ^{
            
            before(^{
                logoutUserDefault();
            });
            
            it(@"returns false",^{
                [[NeatoAuthentication sharedInstance]logoutWithCompletion:^(NSError * _Nullable error) {
                    NeatoUser *user = [NeatoUser new];
                    expect([user isAuthenticated]).to.equal(false);
                }];
            });
        });
    });
    
    describe(@"Get Robots", ^{
        
        context(@"when a robots is available", ^{
            
            before(^{
                signInUserDefault();
                [OHHTTPStubs stub:@"/users/me/robots"
                         withFile:@"beehive_users_me_robots_one.json"
                            code:200];
            });
            
            it(@"returns a robot", ^{
                waitUntil(^(DoneCallback done) {
                    NeatoUser *user = [NeatoUser new];
                    [user getRobotsWithCompletion:^(NSArray<NeatoRobot *> * _Nonnull robots, NSError * _Nullable error) {
                        expect(error).to.beNil();
                        expect(robots.count).to.equal(1);
                        done();
                    }];
                });
                
            });
        });
        
        context(@"when user is not signed in", ^{
            
            before(^{
                logoutUserDefault();
            });
            
            it(@"Raise an error", ^{
                
                waitUntil(^(DoneCallback done) {
                    NeatoUser *user = [NeatoUser new];
                    [user getRobotsWithCompletion:^(NSArray<NeatoRobot *> * _Nonnull robots, NSError * _Nullable error) {
                        expect(error).notTo.beNil();
                        expect(error.domain).to.equal(@"OAuth");
                        done();
                    }];
                });
            });
        });

        context(@"when response returns an invalid type", ^{
            
            before(^{
                signInUserDefault();
                [OHHTTPStubs stub:@"/users/me/robots"
                         withJSON:@"{\"something\":2}"
                             code:200];
            });
            
            it(@"it raises an error", ^{
                waitUntil(^(DoneCallback done) {
                    NeatoUser *user = [NeatoUser new];
                    [user getRobotsWithCompletion:^(NSArray<NeatoRobot *> * _Nonnull robots, NSError * _Nullable error) {
                        expect(error.domain).to.equal(@"Beehive.Robots");
                        done();
                    }];
                });
            });
        });
        
        context(@"when call fails", ^{
            
            before(^{
                signInUserDefault();
                [OHHTTPStubs stub:@"/users/me/robots" withFailure:400];
            });
            
            it(@"raises an error", ^{
                waitUntil(^(DoneCallback done) {
                    NeatoUser *user = [NeatoUser new];
                    [user getRobotsWithCompletion:^(NSArray<NeatoRobot *> * _Nonnull robots, NSError * _Nullable error) {
                        expect(error).notTo.beNil();
                        done();
                    }];
                });
                
            });
        });
    });
    
    
    describe(@"User Info", ^{
        
        context(@"when info is available", ^{
            
            before(^{
                signInUserDefault();
                [OHHTTPStubs stub:@"/users/me"
                         withFile:@"beehive_users_me.json"
                             code:200];
            });
            
            it(@"returns a robot", ^{
                waitUntil(^(DoneCallback done) {
                    NeatoUser *user = [NeatoUser new];
                    [user getUserInfo:^(NSDictionary* userinfo, NSError * _Nullable error) {
                        expect(error).to.beNil();
                        expect(userinfo[@"first_name"]).to.equal(@"Firstname");
                        expect(userinfo[@"last_name"]).to.equal(@"Lastname");
                        expect(userinfo[@"email"]).to.equal(@"test@example.com");
                        done();
                    }];

                });
                
            });
        });
        
        context(@"when user is not signed in", ^{
            
            before(^{
                logoutUserDefault();
            });
            
            it(@"Raise an error", ^{
                
                waitUntil(^(DoneCallback done) {
                    NeatoUser *user = [NeatoUser new];
                    [user getUserInfo:^(NSDictionary* userinfo, NSError * _Nullable error) {
                        expect(error).notTo.beNil();
                        expect(error.domain).to.equal(@"OAuth");
                        done();
                    }];
                });
            });
        });
        
        context(@"when call fails", ^{
            
            before(^{
                signInUserDefault();
                [OHHTTPStubs stub:@"/users/me/" withFailure:400];
            });
            
            it(@"raises an error", ^{
                waitUntil(^(DoneCallback done) {
                    NeatoUser *user = [NeatoUser new];
                    [user getUserInfo:^(NSDictionary* userinfo, NSError * _Nullable error) {
                        expect(error).notTo.beNil();
                        done();
                    }];
                });
                
            });
        });
    });
});

SpecEnd

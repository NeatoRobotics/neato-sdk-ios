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
#import "MockNeatoTokenStore.h"

@import NeatoSDK;

SpecBegin(NeatoBeehiveClient)

describe(@"NeatoBeehiveClient", ^{
    
    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
    
    describe(@"Singleton", ^{
        
        context(@"when is requested", ^{
            
            it(@"return an instance :)", ^{
                expect([NeatoBeehiveClient sharedInstance]).toNot.beNil();
            });
        });
    });
    
    
    describe(@"Get Robots", ^{
        
        context(@"when a robots is available", ^{
            
            before(^{

                [NeatoAuthentication sharedInstance].tokenStore = [[MockNeatoTokenStore alloc]init];
                [[NeatoAuthentication sharedInstance].tokenStore storeAccessToken:@"a_token"
                                                                       expirationDate:[NSDate dateWithTimeIntervalSinceNow:10000]];
                
                [OHHTTPStubs stub:@"/users/me/robots"
                         withFile:@"beehive_users_me_robots_one.json"
                            code:200];
            });
            
            it(@"returns a robot", ^{
                waitUntil(^(DoneCallback done) {
                    [[NeatoBeehiveClient sharedInstance] robotsWithCompletion:^(NSArray * _Nullable robots, NSError * _Nonnull error) {
                        expect(error).to.beNil();
                        expect(robots.count).to.equal(1);
                        done();
                    }];
                });
                
            });
        });
        
        context(@"when user is not signed in", ^{
            
            before(^{
                [NeatoAuthentication sharedInstance].tokenStore = [[MockNeatoTokenStore alloc]init];
                [[NeatoAuthentication sharedInstance].tokenStore storeAccessToken:@"expired_token"
                                                                   expirationDate:[NSDate dateWithTimeIntervalSinceNow:-10000]];
                
            });
            
            it(@"Raise an error", ^{
                
                waitUntil(^(DoneCallback done) {
                    [[NeatoBeehiveClient sharedInstance] robotsWithCompletion:^(NSArray * _Nullable robots, NSError * _Nonnull error) {
                        expect(error).notTo.beNil();
                        done();
                    }];
                });
            });
        });

        context(@"when response returns an invalid type", ^{
            
            before(^{
                [NeatoAuthentication sharedInstance].tokenStore = [[MockNeatoTokenStore alloc]init];
                [[NeatoAuthentication sharedInstance].tokenStore storeAccessToken:@"a_token"
                                                                       expirationDate:[NSDate dateWithTimeIntervalSinceNow:10000]];
                    
                
                
                [OHHTTPStubs stub:@"/users/me/robots"
                         withJSON:@"{\"something\":2}"
                             code:200];
            });
            
            it(@"it raises an error", ^{
                waitUntil(^(DoneCallback done) {
                    [[NeatoBeehiveClient sharedInstance] robotsWithCompletion:^(NSArray * _Nullable robots, NSError * _Nonnull error) {
                        expect(error.domain).to.equal(@"Beehive.Robots");
                        done();
                    }];
                });
            });
        });
        
        context(@"when call fails", ^{
            
            before(^{
                [OHHTTPStubs stub:@"/users/me/robots" withFailure:400];
            });
            
            it(@"raises an error", ^{
                waitUntil(^(DoneCallback done) {
                    [[NeatoBeehiveClient sharedInstance] robotsWithCompletion:^(NSArray * _Nullable robots, NSError * _Nonnull error) {
                        expect(error).notTo.beNil();
                        done();
                    }];
                });
                
            });
        });
    });
    
});

SpecEnd

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

@import NeatoSDK;

SpecBegin(NeatoBeehiveClient)

describe(@"NeatoBeehiveClient", ^{
    
    describe(@"Singleton", ^{
        
        context(@"when is requested", ^{
            
            it(@"is expected to return an instance :)", ^{
                expect([NeatoBeehiveClient sharedInstance]).toNot.beNil();
            });
        });
    });
    
    describe(@"Get Robots", ^{
        context(@"when a robots is available", ^{
            
            before(^{
                [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
                    NSString *json = @"[\
                    {\"serial\": \"robot1\",\
                    \"name\": \"Robot 1\",\
                    \"model\": \"botvac-85\",\
                    \"secret_key\": \"04a0fbe6b1f2572d\"}, \
                    ]";
                    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
                    id jsondata = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    return [OHHTTPStubsResponse responseWithJSONObject:jsondata statusCode:200 headers:@{@"Content-Type": @"application/json"}];
                    
                }].name = @"robots";

            });
            
            after(^{
                [OHHTTPStubs removeAllStubs];
            });
            
            it(@"is expected to list a robot", ^{
                waitUntil(^(DoneCallback done) {
                    [[NeatoBeehiveClient sharedInstance] robots:^(NSArray * _Nullable robots, NSError * _Nonnull error) {
                        expect(error).to.beNil;
                        expect(robots.count).to.equal(1);
                        done();
                    }];
                });
                
            });
        });
        
        context(@"when response return an invalid type", ^{
            
            before(^{
                [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
                    NSString *json = @"{\"something\":2}";
                    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
                    id jsondata = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    return [OHHTTPStubsResponse responseWithJSONObject:jsondata statusCode:200 headers:@{@"Content-Type": @"application/json"}];
                    
                }].name = @"robotsinv";
            });
            
            after(^{
                [OHHTTPStubs removeAllStubs];
            });
            
            it(@"is expected to return an error", ^{
                waitUntil(^(DoneCallback done) {
                    [[NeatoBeehiveClient sharedInstance] robots:^(NSArray * _Nullable robots, NSError * _Nonnull error) {
                        expect(error.domain).to.equal(@"Beehive.Robots");
                        done();
                    }];
                });
                
            });
        });
        
        context(@"when call fails", ^{
            
            before(^{
                [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
                    return [OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:400 headers:@{@"Content-Type": @"application/json"}];
                    
                }].name = @"robotsinv";
            });
            
            after(^{
                [OHHTTPStubs removeAllStubs];
            });
            
            it(@"is expected to return an error", ^{
                waitUntil(^(DoneCallback done) {
                    [[NeatoBeehiveClient sharedInstance] robots:^(NSArray * _Nullable robots, NSError * _Nonnull error) {
                        expect(error).notTo.beNil();
                        done();
                    }];
                });
                
            });
        });
    });
    
});

SpecEnd

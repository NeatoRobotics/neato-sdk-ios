//
//  NeatoNucleoClientTest.m
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

@import NeatoSDK;

SpecBegin(NeatoNucleoClient)

describe(@"NeatoNucleoClient", ^{
    
    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
    
    describe(@"Singleton", ^{
        
        context(@"when is requested", ^{
            
            it(@"returns an instance :)", ^{
                expect([NeatoNucleoClient sharedInstance]).toNot.beNil();
            });
        });
    });
    
    describe(@"Send messages", ^{
        
        context(@"when a valid message is sent", ^{
            before(^{
                signInUser();
                
                [OHHTTPStubs stub:@"/vendors/neato/robots/123456/messages"
                         withJSON:@"{\"state\":1}"
                             code:200];
            });
            
            it(@"receives the response", ^{
                waitUntil(^(DoneCallback done) {
                    [[NeatoNucleoClient sharedInstance]
                     sendCommand:@"getRobotState"
                     withParamenters:@{@"param":@(1)} robotSerial:@"123456"
                     robotKey:@"secretkey"
                     complete:^(id response, NSError * error) {
                        expect(response).to.equal(@{@"state":@(1)});
                        done();
                    }];
                });
            });
        });
        context(@"when invalid params", ^{
            before(^{
                signInUser();
                
                [OHHTTPStubs stub:@"/vendors/neato/robots/123456/messages"
                         withJSON:@"{\"state\":1}"
                             code:200];
            });
            
            it(@"reises an error", ^{
                waitUntil(^(DoneCallback done) {
                    [[NeatoNucleoClient sharedInstance]
                     sendCommand:@"getRobotState"
                     withParamenters:[NSDate date] robotSerial:@"123456"
                     robotKey:@"secretkey"
                     complete:^(id response, NSError * error) {
                         expect(error).notTo.beNil();
                         NSLog(@"\n\n\n\n\n\n\n%@", error.userInfo);
                         done();
                     }];
                });
            });
        });
        
        context(@"when the call fails", ^{
            before(^{
                signInUser();
                
                [OHHTTPStubs stub:@"/vendors/neato/robots/123456/messages"
                         withJSON:@"{}"
                             code:400];
            });
            
            it(@"reises an error", ^{
                waitUntil(^(DoneCallback done) {
                    [[NeatoNucleoClient sharedInstance]
                     sendCommand:@"getRobotState"
                     withParamenters:nil
                     robotSerial:@"123456"
                     robotKey:@"secretkey"
                     complete:^(id response, NSError * error) {
                         expect(error).notTo.beNil();
                         done();
                     }];
                });
            });
        });
    });
});

SpecEnd

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
#import "NeatoHTTPSessionManager.h"

@import NeatoSDK;

SpecBegin(NeatoHTTPSessionManager)

describe(@"NeatoHTTPSessionManager", ^{
    
    describe(@"Singleton", ^{
        
        context(@"when it is requested", ^{
            
            it(@"is expected to return an instance :)", ^{
                expect([NeatoHTTPSessionManager sharedInstance]).toNot.beNil();
            });
        });
        
        context(@"when it is setup with a token", ^{
            before(^{
                [NeatoHTTPSessionManager setupInstanceWithAccessToken:@"this_is_the_token"];
            });
            
            it(@"uses the token for Authorization", ^{
                expect([[NeatoHTTPSessionManager sharedInstance].requestSerializer valueForHTTPHeaderField:@"Authorization"]).to.equal(@"Bearer this_is_the_token");
            });
        });
    });
});
SpecEnd
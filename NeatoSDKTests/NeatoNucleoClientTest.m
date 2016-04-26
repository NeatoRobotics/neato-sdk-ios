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

@import NeatoSDK;

SpecBegin(NeatoNucleoClient)

describe(@"NeatoBeehiveClient", ^{
    
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
});

SpecEnd

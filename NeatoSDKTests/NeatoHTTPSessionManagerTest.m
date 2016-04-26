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
#import "NSDate+Neato.h"
#import "NSString+Neato.h"

@import NeatoSDK;

SpecBegin(NeatoHTTPSessionManager)

describe(@"NeatoHTTPSessionManager", ^{
    it(@"return a sha256 signed string", ^{
        NSString *unsignedString1 = [NSString stringWithFormat:@"%@\n%@\n%@\n",
                                    @"zzz99999-000000000003",
                                    @"Tue, 26 Apr 2016 19:34:05 GMT",
                                    @"{\"reqId\":\"1\",\"cmd\":\"getRobotState\"}"];
        NSString *unsignedString = @"value";
        
        NSString *signedString = [unsignedString SHA256:@"key"];
        
        expect(signedString).to.equal(@"90fbfcf15e74a36b89dbdb2a721d9aecffdfdddc5c83e27f7592594f71932481");
    });

    
});
SpecEnd
//
//  OHHTTPStubs+Neato.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 26/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "OHHTTPStubs+Neato.h"
#import <OHHTTPStubs/OHHTTPStubsResponse+JSON.h>
#import <OHHTTPStubs/OHPathHelpers.h>

@interface OHHTTPStubsNeatoHelper : NSObject
@end

@implementation OHHTTPStubsNeatoHelper
@end

@implementation OHHTTPStubs (Neato)

+ (void)stub:(NSString *)call withFile:(NSString *)filepath code:(int)code{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path isEqualToString:call];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSBundle *bundle = [NSBundle bundleForClass:[OHHTTPStubsNeatoHelper class]];
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(filepath, bundle)
                                                statusCode:code headers:@{@"Content-Type":@"application/json"}];
    }].name = call;
}

+ (void)stub:(NSString *)call withJSON:(NSString *)json code:(int)code{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path isEqualToString:call];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
        id jsondata = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        return [OHHTTPStubsResponse responseWithJSONObject:jsondata statusCode:code headers:@{@"Content-Type": @"application/json"}];
    }].name = call;
}

+ (void)stub:(NSString *)call withFailure:(int)code{
    [OHHTTPStubs stub:call withJSON:@"{}" code:code];
}

@end

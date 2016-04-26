//
//  NeatoNucleoClient.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 26/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoNucleoClient.h"
#import "NeatoHTTPSessionManager.h"

@interface NeatoNucleoClient ()

@end

@implementation NeatoNucleoClient

- (instancetype) initInstance
{
    return [super init];
}

+ (instancetype) sharedInstance
{
    static NeatoNucleoClient *nucleoClient;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        nucleoClient = [[super alloc]initInstance];
    });
    
    return nucleoClient;
}

- (void) sendCommand:(NSString *)command
     withParamenters:(id)parameters
             toRobot:(NSString *)robotSerial
            complete:(void (^)(id _Nullable, NSError * _Nullable))completionHandler{
    
    NeatoHTTPSessionManager *manager = [NeatoHTTPSessionManager sharedInstance];
    
}
@end

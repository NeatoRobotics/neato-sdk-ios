//
//  OHHTTPStubs+Neato.h
//  NeatoSDK
//
//  Created by Yari D'areglia on 26/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <OHHTTPStubs/OHHTTPStubs.h>

@interface OHHTTPStubs (Neato)
+ (void)stub:(NSString *)call withFile:(NSString*)filepath code:(int)code;
+ (void)stub:(NSString *)call withJSON:(NSString*)json  code:(int)code;
+ (void)stub:(NSString *)call withFailure:(int)code;
@end

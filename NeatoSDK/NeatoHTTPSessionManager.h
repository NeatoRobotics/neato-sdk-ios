//
//  NeatoHTTPSessionManager.h
//  NeatoSDK
//
//  Created by Yari D'areglia on 31/03/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AFNetworking;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kNeatoAPIBaseURLPath;

@interface NeatoHTTPSessionManager : AFHTTPSessionManager

+ (instancetype) sharedInstance;
+ (instancetype) setupInstanceWithAccessToken:(NSString*)token;
+ (_Nullable instancetype) authenticatedInstance;

+ (instancetype) setupInstanceWithNucleoAuthorization:(NSString*)signedString;

+ (instancetype) setupInstanceWithAuthorization:(NSString*)key value:(NSString*)value;
@end

NS_ASSUME_NONNULL_END
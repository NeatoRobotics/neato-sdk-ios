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

extern NSString * const kBeehiveBaseURLPath;
extern NSString * const kNucleoBaseURLPath;

@interface NeatoHTTPSessionManager : AFHTTPSessionManager

+ (_Nullable instancetype) authenticatedBeehiveManager;
+ (instancetype) managerWithNucleoAuthorization:(NSString*)signedString;
+ (instancetype) managerWithBeehiveAuthorization:(NSString*)token;

@end

NS_ASSUME_NONNULL_END
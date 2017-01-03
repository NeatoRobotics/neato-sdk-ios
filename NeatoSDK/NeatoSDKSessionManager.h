//
//  NeatoHTTPSessionManager.h
//  NeatoSDK
//
//  Created by Yari D'areglia on 31/03/16.
//  2016 Neato Robotics.
//

#import <Foundation/Foundation.h>
#import "NeatoHTTPSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kBeehiveBaseURLPath;
extern NSString * const kNucleoBaseURLPath;

@interface NeatoSDKSessionManager : NeatoHTTPSessionManager

+ (_Nullable instancetype) authenticatedBeehiveManager;
+ (instancetype) managerWithNucleoAuthorization:(NSString*)signedString date:(NSString*)date;
+ (instancetype) managerWithBeehiveAuthorization:(NSString*)token;

@end

NS_ASSUME_NONNULL_END

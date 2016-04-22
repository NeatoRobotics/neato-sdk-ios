//
//  NeatoTokenStore.h
//  NeatoSDK
//
//  Created by Yari D'areglia on 29/03/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NeatoTokenStore <NSObject>

/**
 *  Configure the shared instance.
 *  @param  tokenValue    .
 */
- (void) storeAccessToken:(nullable NSString *) tokenValue expirationDate:(nullable NSDate*)expirationDate;

/**
 *  Configure the shared instance.
 *  @return .
 */
- (nullable NSString*) readStoredAccessToken;

/**
 *  Configure the shared instance.
 *  @return  .
 */
- (nullable NSDate*) readStoredAccessTokenExpirationDate;

/**
 *  Configure the shared instance.
 *  @return  .
 */
- (void) reset;

@end

NS_ASSUME_NONNULL_END

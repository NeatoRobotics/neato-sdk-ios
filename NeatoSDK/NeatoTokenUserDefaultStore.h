//
//  NeatoTokenStore.h
//  NeatoSDK
//
//  Created by Yari D'areglia on 29/03/16.
//  2016 Neato Robotics.
//

#import <Foundation/Foundation.h>
#import "NeatoTokenStore.h"

#pragma mark - Constants and Typedef

extern NSString * const kNeatoOAuthAccessTokenStoreKey;
extern NSString * const kNeatoOAuthAccessTokenExpirationStoreKey;

#pragma mark - NeatoTokenUserDefaultStore Class

@interface NeatoTokenUserDefaultStore:NSObject <NeatoTokenStore>

@end

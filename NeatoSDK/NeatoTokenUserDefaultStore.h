//
//  NeatoTokenStore.h
//  NeatoSDK
//
//  Created by Yari D'areglia on 29/03/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NeatoTokenStore.h"

#pragma mark - Constants and Typedef

extern NSString * const kNeatoOAuthAccessTokenStoreKey;
extern NSString * const kNeatoOAuthAccessTokenExpirationStoreKey;

#pragma mark - NeatoTokenUserDefaultStore Class

@interface NeatoTokenUserDefaultStore:NSObject <NeatoTokenStore>

@end

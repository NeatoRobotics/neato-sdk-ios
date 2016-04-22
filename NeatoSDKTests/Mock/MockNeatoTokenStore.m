//
//  MockNeatoTokenStore.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 29/03/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "MockNeatoTokenStore.h"

@interface MockNeatoTokenStore()
@property (nonatomic, copy) NSString* storedToken;
@property (nonatomic, strong) NSDate* storedTokenExpirationDate;
@end

@implementation MockNeatoTokenStore

- (void) storeAccessToken:(NSString *) tokenValue expirationDate:(NSDate*)expirationDate{
    self.storedToken = tokenValue;
    self.storedTokenExpirationDate = expirationDate;
}

- (NSString*) readStoredAccessToken{
    return self.storedToken;
}

- (NSDate*) readStoredAccessTokenExpirationDate{
    return self.storedTokenExpirationDate;
}

- (void) reset {
    self.storedToken = nil;
    self.storedTokenExpirationDate = nil;
}

@end

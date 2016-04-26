//
//  NeatoBeehiveClient.h
//  NeatoSDK
//
//  Created by Yari D'areglia on 23/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NeatoBeehiveClient : NSObject

+ (instancetype) sharedInstance;

- (void) robots:(void (^)(NSArray* _Nullable robots, NSError *error))completionHandler;

@end

NS_ASSUME_NONNULL_END


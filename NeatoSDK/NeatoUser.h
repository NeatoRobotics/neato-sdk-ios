//
//  NeatoUser.h
//  NeatoSDK
//
//  Created by Yari D'areglia on 28/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NeatoRobot;

NS_ASSUME_NONNULL_BEGIN
@interface NeatoUser : NSObject

/**
 Verify if a not expired token is stored in the current device.
 Note: this function doesn't verify if the token is currently available on the server.
 
 **/
- (BOOL)isAuthenticated;

/**
 Get the list of robots for the current users.
 
 @param completion
 **/
- (void) getRobotsWithCompletion:(void(^)(NSArray<NeatoRobot*> *robots, NSError * _Nullable error))completion;

@end
NS_ASSUME_NONNULL_END

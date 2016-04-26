//
//  NeatoNucleoClient.h
//  NeatoSDK
//
//  Created by Yari D'areglia on 26/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NeatoNucleoClient : NSObject

+ (instancetype) sharedInstance;

- (void)sendCommand:(NSString*)command withParamenters:(id _Nullable)parameters toRobot:(NSString*)robotSerial complete:(void (^)(id _Nullable, NSError * _Nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END
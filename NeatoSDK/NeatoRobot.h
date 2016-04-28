//
//  NeatoRobot.h
//  NeatoSDK
//
//  Created by Yari D'areglia on 27/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RobotState) {
    RobotStateInvalid,
    RobotStateIdle,
    RobotStateBusy,
    RobotStatePaused,
    RobotStateError
};

typedef NS_ENUM(NSUInteger, RobotAction) {
    RobotActionInvalid,
    RobotActionHouseCleaning,
    RobotActionSpotCleaning,
    RobotActionManualCleaning,
    RobotActionDocking,
    RobotActionMenuActive,
    RobotActionSuspendedCleaning,
    RobotActionUpdating,
    RobotActionCopyLogs,
    RobotActionRecoveryLocation
};

NS_ASSUME_NONNULL_BEGIN

@interface NeatoRobot : NSObject

@property (nonatomic, copy) NSString* serial;
@property (nonatomic, copy) NSString* secretKey;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) RobotState state;
@property (nonatomic, assign) RobotAction action;
@property (nonatomic, assign) bool online;
@property (nonatomic, assign) int batteryLevel;
@property (nonatomic, assign) bool isCharging;

/**
 Initialize a new Robot instance.
 
 @param name: robot name
 @param serial: robot serial
 @param secretKey: robot secret key
 
 **/
- (instancetype)initWithName:(NSString*)name serial:(NSString *)serial secretKey:(NSString *)secretKey;

/**
 Update robot state asynchronously. When the update succeeded robot properties will be updated to the current robot state.
 
 @param success: Callback to handle call success.
 @param failure: Callback to handle call failure.
 
 **/
- (void)updateState:(void(^)())success failure:(void(^)(NSError * _Nullable error))failure;

/**
 Send StartCleaning command to the robot. After this call succeeded robot state will be automatically updated to the new robot state (i.e. state:busy action:house cleaning).
 
 @param parameters: Define the cleaning setup. Check Neato docs for all the available choices.
 @param success: Callback to handle call success.
 @param failure: Callback to handle call failure.
 
 **/
- (void)startCleaning:(NSDictionary *)parameters success:(void(^)())success failure:(void(^)(NSError * _Nullable error))failure;

/**
 Send pauseCleaning command to the robot. After this call succeeded robot state will be automatically updated to the new robot state (i.e state:paused action:house cleaning).
 
 @param success: Callback to handle call success.
 @param failure: Callback to handle call failure.
 
 **/
- (void)pauseCleaning:(void(^)())success failure:(void(^)(NSError * _Nullable error))failure;

/**
 Send stopCleaning command to the robot. After this call succeeded robot state will be automatically updated to the new robot state (i.e. state:idle action:ready to clean).
 
 @param success: Callback to handle call success.
 @param failure: Callback to handle call failure.
 
 **/
- (void)stopCleaning:(void(^)())success failure:(void(^)(NSError * _Nullable error))failure;

@end

NS_ASSUME_NONNULL_END

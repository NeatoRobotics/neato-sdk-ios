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

@property (nonatomic, copy, readonly) NSString* serial;
@property (nonatomic, copy, readonly) NSString* secretKey;
@property (nonatomic, copy, readonly) NSString* name;
@property (nonatomic, assign, readonly) RobotState state;
@property (nonatomic, assign, readonly) RobotAction action;
@property (nonatomic, assign, readonly) bool online;
@property (nonatomic, assign, readonly) int chargeLevel;
@property (nonatomic, assign, readonly) bool isCharging;
@property (nonatomic, assign, readonly) bool isDocked;
@property (nonatomic, assign, readonly) bool isScheduleEnabled;

/**
 Initialize a new Robot instance.
 
 @param name: robot name
 @param serial: robot serial
 @param secretKey: robot secret key
 
 **/
- (instancetype)initWithName:(NSString*)name serial:(NSString *)serial secretKey:(NSString *)secretKey;

- (void)sendCommand:(NSString*)command
         parameters:(NSDictionary* _Nullable) parameters
         completion:(void (^)(bool result, id _Nullable data, NSError *error))completionHandler;

/**
 Update robot state asynchronously. When the update succeeded robot properties will be updated to the current robot state.
 
 @param completion: Callback to handle call response.
 
 **/
- (void)updateStateWithCompletion:(void(^)(NSError * _Nullable error))completion;

/**
 Send StartCleaning command to the robot. After this call succeeded robot state will be automatically updated to the new robot state (i.e. state:busy action:house cleaning).
 
 @param parameters: Define the cleaning setup. Check Neato docs for all the available choices.
 @param completion: Callback to handle call response.

 **/
- (void)startCleaningWithParameters:(NSDictionary *)parameters completion:(void (^)(NSError * _Nullable error))completion;

/**
 Send pauseCleaning command to the robot. After this call succeeded robot state will be automatically updated to the new robot state (i.e state:paused action:house cleaning).
 
 @param completion: Callback to handle call response.
 **/
- (void)pauseCleaningWithCompletion:(void (^)(NSError * _Nullable error))completion;

/**
 Send stopCleaning command to the robot. After this call succeeded robot state will be automatically updated to the new robot state (i.e. state:idle action:ready to clean).
 
 @param completion: Callback to handle call response.
 
 **/
- (void)stopCleaningWithCompletion:(void (^)(NSError * _Nullable error))completion;

/**
 Send enableSchedule command to the robot. After this call succeeded robot state will be automatically updated to the new robot state (i.e state:paused action:house cleaning).
 
 @param completion: Callback to handle call response.
 **/
- (void)enableScheduleWithCompletion:(void (^)(NSError * _Nullable error))completion;

/**
 Send disableSchedule command to the robot. After this call succeeded robot state will be automatically updated to the new robot state (i.e state:paused action:house cleaning).
 
 @param completion: Callback to handle call response.
 **/
- (void)disableScheduleWithCompletion:(void (^)(NSError * _Nullable error))completion;

/**
 Force robot state and action. This function should be used for testing purpose only.
 **/
- (void)forceRobotState:(RobotState)state action:(RobotAction)action online:(BOOL)online;

@end

NS_ASSUME_NONNULL_END

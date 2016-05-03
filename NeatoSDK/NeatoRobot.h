//
//  NeatoRobot.h
//  NeatoSDK
//
//  Created by Yari D'areglia on 27/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @typedef RobotState
 @brief The state of the robot
 @constant RobotStateInvalid    An invalid state, not handled by the robot
 @constant RobotStateIdle       The robot is Idle
 @constant RobotStateBusy       The robot is working (i.e. he is cleaning or returning to base)
 @constant RobotStatePaused     The robot has paused its current action
 @constant RobotStateError      The robot encounters an error
 */
typedef NS_ENUM(NSUInteger, RobotState) {
    RobotStateInvalid,
    RobotStateIdle,
    RobotStateBusy,
    RobotStatePaused,
    RobotStateError
};

/**
 @typedef RobotAction
 @brief An action that specify why a robot is busy (or paused)
 @constant RobotActionInvalid               An invalid action
 @constant RobotActionHouseCleaning         Robot is in House Cleaning mode
 @constant RobotActionSpotCleaning          Robot is in Spot Cleaning mode
 @constant RobotActionManualCleaning        Robot is in Manual Cleaning mode
 @constant RobotActionMenuActive            Robot LCD UI is in use
 @constant RobotActionSuspendedCleaning     Robot cannot continue cleaning (i.e. battery its low)
 @constant RobotActionUpdating              Robot is performing a software update
 @constant RobotActionCopyLogs              Robot is sending logs
 @constant RobotActionRecoveryLocation      Robot is recovery location
 */
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

typedef NS_ENUM(NSUInteger, RobotCleaningCategory){
    RobotCleaningCategoryManual = 1,
    RobotCleaningCategoryHouse = 2,
    RobotCleaningCategorySpot = 3
};

typedef NS_ENUM(NSUInteger, RobotCleaningMode){
    RobotCleaningModeEco = 1,
    RobotCleaningModeTurbo = 2
};

typedef NS_ENUM(NSUInteger, RobotCleaningModifier){
    RobotCleaningModifierNormal = 1,
    RobotCleaningModifierDouble = 2
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
@property (nonatomic, strong, readonly) NSDictionary *availableServices;

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
 * Send pauseCleaning command to the robot. After this call succeeded robot state will be automatically updated to the new robot state (i.e state:paused action:house cleaning).
 *
 * @param completion: Callback to handle call response.
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
 Setup robot scheduling. 
 
 @param events: an array of cleaning events. The value needed to define an event are:
                - "day": The day of the week. 0 Sunday 1 Monday 2 Tuesday 3 Wednesday 4 Thursday 5 Friday 6 Saturday.
                - "mode": The cleaning mode for this event RobotCleaningModeTurbo or RobotCleaningModeEco
                - "startTime": The start time expressed in HH:MM.
                @{@"day":1,@"mode":@(RobotCleaningModeTurbo),@"starTime":@"22:11"}
 
 @warning required events parameters may vary depending on robot services support.
 
 **/
- (void)setScheduleWithCleaningEvent:(NSArray *)events completion:(void (^)(NSError * _Nullable error))completion;

/** 
 Request the schedule information to the robot.
 
 @param completion: a block that contains the schedule info returned or an error if the call fail.
 
 **/
- (void)getScheduleWithCompletion:(void (^)(NSDictionary * scheduleInfo, NSError * _Nullable error))completion;

/** 
 Return the version for the given service. It returns Nil if the service is not supported
 
 @param serviceName
 **/
- (NSString * _Nullable)supportedVersionForService:(NSString*)serviceName;

/**
 Force robot state and action. This function should be used for testing purpose only.
 **/
- (void)forceRobotState:(RobotState)state action:(RobotAction)action online:(BOOL)online;

@end

NS_ASSUME_NONNULL_END

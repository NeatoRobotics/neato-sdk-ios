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

- (instancetype)initWithName:(NSString*)name serial:(NSString *)serial secretKey:(NSString *)secretKey;

- (void)updateState:(void(^)())success failure:(void(^)(NSError * _Nullable error))failure;
- (void)startCleaning:(NSDictionary *)parameters success:(void(^)())success failure:(void(^)(NSError * _Nullable error))failure;
- (void)stopCleaning:(void(^)())success failure:(void(^)(NSError * _Nullable error))failure;

@end

NS_ASSUME_NONNULL_END

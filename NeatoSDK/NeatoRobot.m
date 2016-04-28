//
//  NeatoRobot.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 27/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoRobot.h"
#import "NeatoNucleoClient.h"
#import <objc/runtime.h> 

@implementation NeatoRobot

#pragma mark - Private -

/** 
 Send command to the robot then extract result, state and data from robot response.
 **/
- (void)sendCommand:(NSString*)command
         parameters:(NSDictionary* _Nullable) parameters
           completion:(void (^)(bool result, id _Nullable data, NSError *error))completionHandler{
    
    [[NeatoNucleoClient sharedInstance]
     sendCommand:command
     withParamenters:parameters
     robotSerial:self.serial robotKey:self.secretKey
     completion:^(id _Nullable response, NSError * _Nullable error) {
         
            _online = (error == nil);
            [self updateStateFromCommandResponse:response];

            NSString *resultStr = response[@"result"];
            bool result = [resultStr isEqualToString:@"ok"];

            completionHandler(result, response[@"data"], error);
    }];
    
}

/**
 Send command to the robot and manage the robot response calling success or failure callbacks.
 **/
- (void)sendAndManageCommand:(NSString*)command parameters:(NSDictionary* _Nullable)parameters completion:(void(^)(NSError * _Nullable error))completion{
    [self sendCommand:command
           parameters:parameters
           completion:^(bool result, id  _Nullable data, NSError * _Nullable error) {
                 if(result){
                     completion(nil);
                 }else{
                     if (error){
                         completion(error);
                     }else{
                         completion([NSError errorWithDomain:@"Neato.Robot" code:1 userInfo:nil]);
                     }
                 }
             }];
}

/** 
 Given a robot response that contains the state property, initialize robot properties with values from the response.
 **/
- (void)updateStateFromCommandResponse:(id _Nullable)response {
    if(response[@"state"]){
        _state =  [self robotStateFromObject:response[@"state"]];
        _action = [self robotActionFromObject:response[@"action"]];
        
        if(response[@"details"]){
            _chargeLevel = [response[@"details"][@"charge"] intValue];
            _isCharging = [response[@"details"][@"isCharging"] boolValue];
            _isDocked = [response[@"details"][@"isDocked"] boolValue];
            _isScheduleEnabled = [response[@"details"][@"isScheduleEnabled"] boolValue];
        }
    }
}

/** 
 Helper to convert NSNumber to robotState
**/
- (RobotState)robotStateFromObject:(id)obj{
    if ([obj respondsToSelector:@selector(intValue)]){
        int value = [obj intValue];
        if (value > RobotStateError){
            return RobotStateInvalid;
        }else{
            return (RobotState)value;
        }
    }else{
        return RobotStateInvalid;
    }
}

/** 
 Helper to convert NSNumber to robotAction
**/
- (RobotAction)robotActionFromObject:(id)obj{
    if ([obj respondsToSelector:@selector(intValue)]){
        int value = [obj intValue];
        if (value > RobotActionRecoveryLocation){
            return RobotActionInvalid;
        }else{
            return (RobotAction)value;
        }
    }else{
        return RobotActionInvalid;
    }
}

#pragma mark - Public -

- (instancetype)initWithName:(NSString*)name serial:(NSString *)serial secretKey:(NSString *)secretKey{
    self = [super init];
    if (self) {
        _name = name;
        _serial = serial;
        _secretKey = secretKey;
    }
    return self;
}

#pragma mark Robot

- (void)updateStateWithCompletion:(void(^)(NSError * _Nullable error))completion{
    [self sendAndManageCommand:@"getRobotState" parameters:nil completion:completion];
}

#pragma mark Cleaning

- (void)startCleaningWithParameters:(NSDictionary *)parameters completion:(void (^)(NSError * _Nullable error))completion{
    [self sendAndManageCommand:@"startCleaning" parameters:parameters completion:completion];
}

- (void)pauseCleaningWithCompletion:(void (^)(NSError * _Nullable error))completion{
    [self sendAndManageCommand:@"pauseCleaning" parameters:nil completion:completion];
}

- (void)stopCleaningWithCompletion:(void (^)(NSError * _Nullable error))completion{
    [self sendAndManageCommand:@"stopCleaning" parameters:nil completion:completion];
}

#pragma mark Scheduling

- (void)enableScheduleWithCompletion:(void (^)(NSError * _Nullable error))completion{
    [self sendAndManageCommand:@"enableSchedule" parameters:nil completion:completion];
}

- (void)disableScheduleWithCompletion:(void (^)(NSError * _Nullable error))completion{
    [self sendAndManageCommand:@"disableSchedule" parameters:nil completion:completion];
}

#pragma mark Helpers

- (void)forceRobotState:(RobotState)state action:(RobotAction)action online:(BOOL)online{
    _state = state;
    _action = action;
    _online = online;
}
 
@end

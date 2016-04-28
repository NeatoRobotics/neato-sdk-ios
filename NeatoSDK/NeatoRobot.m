//
//  NeatoRobot.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 27/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoRobot.h"
#import "NeatoNucleoClient.h"

@implementation NeatoRobot

#pragma mark - Private

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
         
            self.online = (error == nil);
           
            NSString *resultStr = response[@"result"];
            bool result = [resultStr isEqualToString:@"ok"];

            [self updateStateFromCommandResponse:response];
           
            id data = response[@"data"];
           
            completionHandler(result, data, error);
    }];
    
}

/**
 Send command to the robot and manage the robot response calling success or failure callbacks.
 **/
- (void)sendAndManageCommand:(NSString*)command parameters:(NSDictionary* _Nullable)parameters success:(void(^)())success failure:(void(^)(NSError *error))failure{
    [self sendCommand:command
           parameters:parameters
           completion:^(bool result, id  _Nullable data, NSError * _Nullable error) {
                 if(result){
                     success();
                 }else{
                     if (error){
                         failure(error);
                     }else{
                         failure([NSError errorWithDomain:@"Neato.Robot" code:1 userInfo:nil]);
                     }
                 }
             }];
}

/** 
 Given a robot response that contains the state property, initialize robot properties with values from the response.
 **/
- (void)updateStateFromCommandResponse:(id _Nullable)response {
    if(response[@"state"]){
        self.state =  [self robotStateFromObject:response[@"state"]];
        self.action = [self robotActionFromObject:response[@"action"]];
    }
}

/** 
 Helper to convert NSNumber to robotState
**/
- (RobotState)robotStateFromObject:(id)obj{
    if ([obj respondsToSelector:@selector(intValue)]){
        int value = [obj intValue];
        return (RobotState)value;
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
        return (RobotAction)value;
    }else{
        return RobotActionInvalid;
    }
}

#pragma mark - Public 

- (instancetype)initWithName:(NSString*)name serial:(NSString *)serial secretKey:(NSString *)secretKey{
    self = [super init];
    if (self) {
        self.name = name;
        self.serial = serial;
        self.secretKey = secretKey;
    }
    return self;
}

- (void)updateState:(void(^)())success failure:(void(^)(NSError *error))failure{
    [self sendAndManageCommand:@"getRobotState" parameters:nil success:success failure:failure];
}

- (void)startCleaning:(NSDictionary *)parameters success:(void (^)())success failure:(void (^)(NSError * _Nullable))failure{
    [self sendAndManageCommand:@"startCleaning" parameters:parameters success:success failure:failure];
}

- (void)stopCleaning:(void (^)())success failure:(void (^)(NSError * _Nullable))failure{
    [self sendAndManageCommand:@"stopCleaning" parameters:nil success:success failure:failure];
}

- (void)pauseCleaning:(void (^)())success failure:(void (^)(NSError * _Nullable))failure{
    [self sendAndManageCommand:@"pauseCleaning" parameters:nil success:success failure:failure];
}

- (NSString*)description{
    return [NSString stringWithFormat:@"My name is:%@\nstate: %lu\naction:%lu", self.name, (unsigned long)self.state, (unsigned long)self.action];
}

@end

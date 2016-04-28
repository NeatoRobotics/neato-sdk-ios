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

- (void)sendCommand:(NSString*)command
         parameters:(NSDictionary* _Nullable) parameters
           complete:(void (^)(bool result, id _Nullable data, NSError *error))completionHandler{
    
    [[NeatoNucleoClient sharedInstance]
     sendCommand:command
     withParamenters:parameters
     robotSerial:self.serial robotKey:self.secretKey
     complete:^(id _Nullable response, NSError * _Nullable error) {
                                               
               self.online = (error == nil);
               
               NSString *resultStr = response[@"result"];
               bool result = [resultStr isEqualToString:@"ok"];
               
               if (response[@"state"] != nil){
                   [self updateStateFromCommandResponse:response];
               }
               
               id data = response[@"data"];
               
               completionHandler(result, data, error);
    }];
    
}

- (void)sendAndManageCommand:(NSString*)command parameters:(NSDictionary* _Nullable)parameters success:(void(^)())success failure:(void(^)(NSError *error))failure{
    [self sendCommand:command
           parameters:parameters
             complete:^(bool result, id  _Nullable data, NSError * _Nullable error) {
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

- (void)updateStateFromCommandResponse:(id _Nullable)response{
    self.state =  [self robotStateFromObject:response[@"state"]];
    self.action = [self robotActionFromObject:response[@"action"]];
}

- (RobotState)robotStateFromObject:(id)obj{
    if ([obj respondsToSelector:@selector(intValue)]){
        int value = [obj intValue];
        return (RobotState)value;
    }else{
        return RobotStateInvalid;
    }
}

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

- (NSString*)description{
    return [NSString stringWithFormat:@"My name is:%@\nstate: %lu\naction:%lu", self.name, (unsigned long)self.state, (unsigned long)self.action];
}

@end

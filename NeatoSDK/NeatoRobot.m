//
//  NeatoRobot.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 27/04/16.
//  2016 Neato Robotics.
//

#import "NeatoRobot.h"
#import "NeatoSDKSessionManager.h"
#import "NSDate+Neato.h"
#import "NSString+Neato.h"

static NSString *kNeatoNucleoMessagesPath = @"/vendors/neato/robots/%@/messages";
static NSString *kNeatoBeehiveMapsPath = @"/users/me/robots/%@/maps";
static NSString *kNeatoBeehiveMapInfoPath = @"/users/me/robots/%@/maps/%@";

NSString * const kNeatoError_RobotServices = @"Robot.Services";

@implementation NeatoRobot

#pragma mark - Private -

/** 
 Send command to the robot then extract result, state and data from robot response.
 **/

- (void)sendAndManageCommand:(NSString*)command
         parameters:(NSDictionary* _Nullable) parameters
           completion:(void (^)(bool result, id _Nullable data, NSError *error))completionHandler{

    NSMutableDictionary *payloadData = [NSMutableDictionary dictionaryWithDictionary:@{@"reqId":@"1", @"cmd":command}];
    
    if (parameters){
        [payloadData setObject:parameters forKey:@"params"];
    }
    
    @try {
        NSError *jsonSerializeError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payloadData options:0 error:&jsonSerializeError];
        
        if(!jsonSerializeError){
            
            // Sign the call
            
            NSString *payloadString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSString *dateString = [NSDate date].rfc1123String;
            NSString *unsignedString = [NSString stringWithFormat:@"%@\n%@\n%@",
                                        self.serial.lowercaseString,
                                        dateString,
                                        payloadString];
            NSString *signedString = [unsignedString SHA256:self.secretKey];

            // Perform call
            
            NeatoSDKSessionManager *manager = [NeatoSDKSessionManager managerWithNucleoAuthorization:signedString date:dateString];
            NSString *path = [NSString stringWithFormat:kNeatoNucleoMessagesPath,self.serial];
            [manager POST:path parameters:payloadData
                 progress:^(NSProgress * _Nonnull uploadProgress) {}
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      
                      _online = true;
                      [self updateStateFromCommandResponse:responseObject];

                      NSString *resultStr = responseObject[@"result"];
                      bool result = [resultStr isEqualToString:@"ok"];
                      
                      completionHandler(result, responseObject[@"data"], nil);
                  }
                  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

                      _online = false;
                      completionHandler(false, nil, error);
                  }];
        }
    }
    
    @catch (NSException *exception) {
        completionHandler(nil, nil,  [NSError errorWithDomain:@"Neato.Nucleo" code:1 userInfo:@{@"exception":exception.name}]);
    }
}

- (BOOL)verifyCleaningServiceSupportForParameters:(NSDictionary *)parameters{
    
    int category = [parameters[@"category"] intValue];
    NSString *serviceVersion;
    
    if(category){
        
        switch (category) {
            case RobotCleaningCategoryHouse:
                serviceVersion = [self supportedVersionForService:@"houseCleaning"];
                break;
            case RobotCleaningCategorySpot:
                serviceVersion = [self supportedVersionForService:@"spotCleaning"];
                break;
            case RobotCleaningCategoryMap:
                serviceVersion = [self supportedVersionForService:@"houseCleaning"];
                if (! ([serviceVersion isEqualToString:@"basic-3"] || [serviceVersion isEqualToString:@"basic-4"])){
                    serviceVersion = nil;
                }
                break;
            default:
                break;
        }
    }
    
    return (serviceVersion != nil);
}

/**
 Send command to the robot and manage the robot response calling success or failure callbacks.
 **/
- (void)sendCommand:(NSString*)command parameters:(NSDictionary* _Nullable)parameters
                  completion:(void(^)(NSDictionary* _Nullable data, NSError * _Nullable error))completion{
    [self sendAndManageCommand:command
           parameters:parameters
           completion:^(bool result, id  _Nullable data, NSError * _Nullable error) {
                 if(result){
                     completion(data, nil);
                 }else{
                     if (error){
                         completion(data, error);
                     }else{
                         completion(data, [NSError errorWithDomain:@"Neato.Robot" code:1 userInfo:nil]);
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
            _error = response[@"error"];
            _alert = response[@"alert"];
        }
        
        if([response[@"availableServices"] isKindOfClass:[NSDictionary class]]){
            _availableServices = response[@"availableServices"];
        }
        
        if([response[@"availableCommands"] isKindOfClass:[NSDictionary class]]){
            _availableCommands = response[@"availableCommands"];
        }
        
        if([response[@"meta"] isKindOfClass:[NSDictionary class]]){
            _firmware = response[@"firmware"];
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

- (instancetype)initWithName:(NSString*)name serial:(NSString *)serial secretKey:(NSString *)secretKey model:(NSString *)model{
    self = [super init];
    if (self) {
        _name = name;
        _serial = serial;
        _secretKey = secretKey;
        _model = model;
    }
    return self;
}

#pragma mark Robot

- (void)updateStateWithCompletion:(void(^)(NSError * _Nullable error))completion{
    [self sendCommand:@"getRobotState" parameters:nil completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
        completion(error);
    }];
}

- (NSString *_Nullable)supportedVersionForService:(NSString *)serviceName{
    return self.availableServices[serviceName];
}

- (BOOL)supportService:(NSString *)serviceName version:(NSString *)version{
    return [self.availableServices[serviceName] isEqualToString:version];
}

#pragma mark Cleaning

- (void)startCleaningWithParameters:(NSDictionary *)parameters completion:(void (^)(NSError * _Nullable error))completion{
    
    if ([self verifyCleaningServiceSupportForParameters:parameters]){
        [self sendCommand:@"startCleaning" parameters:parameters completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
            completion(error);
        }];
    }else{
        completion([NSError errorWithDomain:@"Robot" code:1 userInfo:nil]);
    }
}

- (void)pauseCleaningWithCompletion:(void (^)(NSError * _Nullable error))completion{
    [self sendCommand:@"pauseCleaning" parameters:nil completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
        completion(error);
    }];
}

- (void)stopCleaningWithCompletion:(void (^)(NSError * _Nullable error))completion{
    [self sendCommand:@"stopCleaning" parameters:nil completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
        completion(error);
    }];
}

- (void)sendToBaseWithCompletion:(void (^)(NSError * _Nullable error))completion{
    [self sendCommand:@"sendToBase" parameters:nil completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
        completion(error);
    }];
}


#pragma mark Scheduling

- (void)enableScheduleWithCompletion:(void (^)(NSError * _Nullable error))completion{
    if ([self supportedVersionForService:@"schedule"]){
        [self sendCommand:@"enableSchedule" parameters:nil completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
            completion(error);
        }];
    }else{
        completion([NSError errorWithDomain:kNeatoError_RobotServices code:1 userInfo:nil]);
    }
}

- (void)disableScheduleWithCompletion:(void (^)(NSError * _Nullable error))completion{
    if ([self supportedVersionForService:@"schedule"]){
        [self sendCommand:@"disableSchedule" parameters:nil completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
            completion(error);
        }];
    }else{
        completion([NSError errorWithDomain:kNeatoError_RobotServices code:1 userInfo:nil]);
    }
}

- (void)setScheduleWithCleaningEvent:(NSArray *)events completion:(void (^)(NSError * _Nullable error))completion{
    if ([self supportedVersionForService:@"schedule"]){
        NSDictionary *parameters = @{@"type":@(1), @"events":events};
        [self sendCommand:@"setSchedule" parameters:parameters completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
            completion(error);
        }];
    }else{
        completion([NSError errorWithDomain:kNeatoError_RobotServices code:1 userInfo:nil]);
    }
}

- (void)getScheduleWithCompletion:(void (^)(NSDictionary * scheduleInfo, NSError * _Nullable error))completion{
    if ([self supportedVersionForService:@"schedule"]){
        [self sendCommand:@"getSchedule" parameters:nil completion:completion];
    }else{
        completion(nil, [NSError errorWithDomain:kNeatoError_RobotServices code:1 userInfo:nil]);
    }
}

#pragma mark - Maps - 

- (void)getMapsWithCompletion:(void (^)(NSArray * maps, NSError * _Nullable error))completion{
    
    if ([self supportedVersionForService:@"maps"]){
        NeatoSDKSessionManager *manager = [NeatoSDKSessionManager authenticatedBeehiveManager];
        
        NSString *path = [NSString stringWithFormat:kNeatoBeehiveMapsPath,self.serial];
        
        if (manager != nil){
            [manager GET:path
              parameters:nil
                progress:^(NSProgress * _Nonnull downloadProgress) {}
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     
                     if ([responseObject isKindOfClass:[NSDictionary class]]){
                         if ([responseObject objectForKey:@"maps"]){
                             completion(responseObject[@"maps"], nil);
                         }
                     }else{
                         completion(nil, [NSError errorWithDomain:@"Beehive.Maps" code:1 userInfo:nil]);
                     }
                 }
                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     completion(nil, error);
                 }];
        }else{
            completion(nil, [NSError errorWithDomain:@"OAuth" code:1 userInfo:nil]);
        }
    }else{
        completion(nil, [NSError errorWithDomain:kNeatoError_RobotServices code:1 userInfo:nil]);
    }
}

- (void)getMapInfo:(NSString*)mapID completion:(void (^)(NSDictionary * mapInfo, NSError * _Nullable error))completion{
    
    if ([self supportedVersionForService:@"maps"]){
        NeatoSDKSessionManager *manager = [NeatoSDKSessionManager authenticatedBeehiveManager];
        
        NSString *path = [NSString stringWithFormat:kNeatoBeehiveMapInfoPath,self.serial, mapID];
        
        if (manager != nil){
            [manager GET:path
              parameters:nil
                progress:^(NSProgress * _Nonnull downloadProgress) {}
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     
                     if ([responseObject isKindOfClass:[NSDictionary class]]){
                        completion(responseObject, nil);
                     }else{
                         completion(nil, [NSError errorWithDomain:@"Beehive.MapInfo" code:1 userInfo:nil]);
                     }
                 }
                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     completion(nil, error);
                 }];
        }else{
            completion(nil, [NSError errorWithDomain:@"OAuth" code:1 userInfo:nil]);
        }
    }else{
        completion(nil, [NSError errorWithDomain:kNeatoError_RobotServices code:1 userInfo:nil]);
    }
}

#pragma mark - Advanced Services - 

- (void)findMeWithCompletion:(void (^)(NSError * _Nullable))completion{
    if ([self supportedVersionForService:@"findMe"]){
        [self sendCommand:@"findMe" parameters:nil completion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
            completion(error);
        }];
    }else{
        completion([NSError errorWithDomain:kNeatoError_RobotServices code:1 userInfo:nil]);
    }
}

#pragma mark Helpers

- (void)forceRobotState:(RobotState)state action:(RobotAction)action online:(BOOL)online{
    _state = state;
    _action = action;
    _online = online;
}

- (void)forceServices:(NSDictionary*)services{
    _availableServices = services;
}


@end

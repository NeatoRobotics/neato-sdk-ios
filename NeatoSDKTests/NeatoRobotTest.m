//
//  NeatoRobotTest.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 28/04/16.
//  2016 Neato Robotics.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHHTTPStubsResponse+JSON.h>
#import "MockNeatoTokenStore.h"
#import "TestHelpers.h"
#import "OHHTTPStubs+Neato.h"

@import NeatoSDK;

SpecBegin(NeatoRobot)

describe(@"NeatoRobot", ^{
    
    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
    
    describe(@"Initialization", ^{
        
        context(@"when receives parameters", ^{
            
            it(@"has attributes", ^{
                NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret" model:@"model"];
                expect(robot.name).to.equal(@"name");
                expect(robot.serial).to.equal(@"serial");
                expect(robot.secretKey).to.equal(@"secret");
                expect(robot.model).to.equal(@"model");
            });
        });
    });
    
    describe(@"Update state", ^{
        
        context(@"when is online", ^{
            
            before(^{
                signInUser();
                [OHHTTPStubs stub:@"/vendors/neato/robots/serial/messages"
                         withFile:@"botvac_house_alltrue.json"
                             code:200];
            });
            
            it(@"updates robot properties", ^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret" model:@"botvacConnected"];
                
                waitUntil(^(DoneCallback done) {
                    [robot updateStateWithCompletion:^(NSError * _Nullable error) {
                        expect(robot.online).to.equal(YES);
                        expect(robot.action).to.equal(1);
                        expect(robot.state).to.equal(2);
                        expect(robot.chargeLevel).to.equal(100);
                        expect(robot.isCharging).to.equal(YES);
                        expect(robot.isScheduleEnabled).to.equal(YES);
                        expect(robot.isDocked).to.equal(YES);
                        expect(robot.isScheduleEnabled).to.equal(YES);

                        done();
                    }];
                });
            });
        });
        
        context(@"when is offline", ^{
            
            before(^{
                signInUser();
                [OHHTTPStubs stub:@"/vendors/neato/robots/serial/messages"
                         withJSON:@"{}"
                             code:404];
            });
            
            it(@"robot is not online", ^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret" model:@"botvacConnected"];
                [robot forceRobotState:RobotStateBusy action:RobotActionHouseCleaning online:YES];

                waitUntil(^(DoneCallback done) {
                    [robot updateStateWithCompletion:^(NSError * _Nullable error) {
                        expect(robot.online).to.equal(NO);
                        done();
                    }];
                });
            });
        });
        
        context(@"when receives invalid state/action", ^{
            
            before(^{
                signInUser();
                [OHHTTPStubs stub:@"/vendors/neato/robots/serial/messages"
                         withJSON:@"{\"state\": \"WTF?\",\"action\": \"WTF?\"}"
                             code:200];
            });
            
            it(@"robot is not online", ^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret" model:@"botvacConnected"];
                [robot forceRobotState:RobotStateBusy action:RobotActionHouseCleaning online:YES];
                
                waitUntil(^(DoneCallback done) {
                    [robot updateStateWithCompletion:^(NSError * _Nullable error) {
                        expect(robot.state).to.equal(0);
                        expect(robot.action).to.equal(0);
                        done();
                    }];
                });
            });
        });
        
        context(@"when receives wrong state/action", ^{
            
            before(^{
                signInUser();
                [OHHTTPStubs stub:@"/vendors/neato/robots/serial/messages"
                         withJSON:@"{\"state\": 100,\"action\": 100}"
                             code:200];
            });
            
            it(@"robot is not online", ^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret" model:@"botvacConnected"];
                [robot forceRobotState:RobotStateBusy action:RobotActionHouseCleaning online:YES];
                
                waitUntil(^(DoneCallback done) {
                    [robot updateStateWithCompletion:^(NSError * _Nullable error) {
                        expect(robot.state).to.equal(0);
                        expect(robot.action).to.equal(0);
                        done();
                    }];
                });
            });
        });
        
        context(@"when receives empty state/action", ^{
            
            before(^{
                signInUser();
                [OHHTTPStubs stub:@"/vendors/neato/robots/serial/messages"
                         withJSON:@"{\"state\": null,\"action\": null}"
                             code:200];
            });
            
            it(@"robot is not online", ^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret" model:@"botvacConnected"];
                [robot forceRobotState:RobotStateBusy action:RobotActionHouseCleaning online:YES];
                
                waitUntil(^(DoneCallback done) {
                    [robot updateStateWithCompletion:^(NSError * _Nullable error) {
                        expect(robot.state).to.equal(0);
                        expect(robot.action).to.equal(0);
                        done();
                    }];
                });
            });
        });
    });
    
    describe(@"Basic messages", ^{
        
        context(@"when a valid message is sent", ^{
            before(^{
                signInUser();
                
                [OHHTTPStubs stub:@"/vendors/neato/robots/123456/messages"
                         withJSON:@"{\"result\":\"ok\", \"data\":\"data\"}"
                             code:200];
            });
            
            it(@"converts the response in result and data", ^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"robot" serial:@"123456" secretKey:@"secret" model:@"botvacConnected"];
                
                waitUntil(^(DoneCallback done) {
                    [robot sendAndManageCommand:@"command" parameters:nil completion:^(bool result, id  _Nullable data, NSError * _Nonnull error) {
                        expect(result).to.equal(true);
                        expect(data).to.equal(@"data");
                        done();
                    }];
                });
            });
        });
        
        context(@"when invalid params are sent", ^{
            before(^{
                signInUser();
                [OHHTTPStubs stub:@"/vendors/neato/robots/123456/messages"
                         withJSON:@"{\"result\":\"ok\", \"data\":\"data\"}"
                             code:200];
            });
            
            it(@"reises an error", ^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"robot" serial:@"123456" secretKey:@"secret" model:@"botvacConnected"];
                
                waitUntil(^(DoneCallback done) {
                    [robot sendAndManageCommand:@"command" parameters:@{@"INVALID_PARAM":[NSDate date]} completion:^(bool result, id  _Nullable data, NSError * _Nonnull error) {
                        expect(result).to.equal(false);
                        expect(data).to.beNil();
                        expect(error).notTo.beNil();
                        expect(error.domain).to.equal(@"Neato.Nucleo");
                        done();
                    }];
                });
            });
        });
        
        context(@"when message fails", ^{
            before(^{
                signInUser();
                
                [OHHTTPStubs stub:@"/vendors/neato/robots/123456/messages"
                         withJSON:@"{}"
                             code:400];
            });
            
            it(@"reises an error", ^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"robot" serial:@"123456" secretKey:@"secret" model:@"botvacConnected"];
                
                waitUntil(^(DoneCallback done) {
                    [robot sendAndManageCommand:@"command" parameters:nil completion:^(bool result, id  _Nullable data, NSError * _Nonnull error) {
                        expect(result).to.equal(false);
                        expect(data).to.beNil();
                        expect(error).notTo.beNil();
                        done();
                    }];
                });
            });
        });
    });
    
    describe(@"Send a command", ^{
        
        context(@"when a valid command is sent", ^{
            
            before(^{
                signInUser();
                [OHHTTPStubs stub:@"/vendors/neato/robots/serial/messages"
                         withFile:@"botvac_house_alltrue.json"
                             code:200];
            });
            
            it(@"executes the completion callback",^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret" model:@"botvacConnected"];

                waitUntil(^(DoneCallback done) {
                    [robot startCleaningWithParameters:@{} completion:^(NSError * _Nullable error) {
                        expect(true);
                        done();
                    }];
                });
                
                waitUntil(^(DoneCallback done) {
                    [robot pauseCleaningWithCompletion:^(NSError * _Nullable error) {
                        expect(true);
                        done();
                    }];
                });
                waitUntil(^(DoneCallback done) {
                    [robot stopCleaningWithCompletion:^(NSError * _Nullable error) {
                        expect(true);
                        done();
                    }];
                });
                waitUntil(^(DoneCallback done) {
                    [robot enableScheduleWithCompletion:^(NSError * _Nullable error) {
                        expect(true);
                        done();
                    }];
                });
                waitUntil(^(DoneCallback done) {
                    [robot disableScheduleWithCompletion:^(NSError * _Nullable error) {
                        expect(true);
                        done();
                    }];
                });
                waitUntil(^(DoneCallback done) {
                    [robot getScheduleWithCompletion:^(NSDictionary * _Nonnull scheduleInfo, NSError * _Nullable error) {
                        expect(true);
                        done();
                    }];
                });
                waitUntil(^(DoneCallback done) {
                    [robot setScheduleWithCleaningEvent:@[@(1), @(2)] completion:^(NSError * _Nullable error) {
                        expect(true);
                        done();
                    }];
                });
                waitUntil(^(DoneCallback done) {
                    [robot findMeWithCompletion:^(NSError * _Nullable error) {
                        expect(true);
                        done();
                    }];
                });
                
            });
        });
    });
    
    describe(@"Supported Services", ^{
        
        context(@"when services area available",^{
            before(^{
                signInUser();
                [OHHTTPStubs stub:@"/vendors/neato/robots/serial/messages"
                         withJSON:@"{\"result\":\"ok\", \"state\":1, \"availableServices\":{\"service_1\":\"version_1\", \"service_2\":\"version_2\"}}"
                             code:200];
            });
            
            it(@"stores the services",^{
            __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret" model:@"botvacConnected"];
            
                waitUntil(^(DoneCallback done) {
                    [robot updateStateWithCompletion:^(NSError * _Nullable error) {
                        expect(robot.availableServices).to.equal(@{@"service_1":@"version_1", @"service_2":@"version_2"});
                        done();
                    }];
                });
            });
            
            it(@"supports a service",^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret" model:@"botvacConnected"];
                
                waitUntil(^(DoneCallback done) {
                    [robot updateStateWithCompletion:^(NSError * _Nullable error) {
                        expect([robot supportedVersionForService:@"service_1"]).to.equal(@"version_1");
                        expect([robot supportedVersionForService:@"unknown_service"]).to.beNil();
                        done();
                    }];
                });
            });
            
            it(@"supports a specific service version",^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret" model:@"botvacConnected"];
                
                waitUntil(^(DoneCallback done) {
                    [robot updateStateWithCompletion:^(NSError * _Nullable error) {
                        expect([robot supportService:@"service_1" version:@"version_1"]).to.equal(YES);
                        done();
                    }];
                });
            }); 
        });
        
        context(@"Cleaning support",^{
            before(^{
                signInUser();
                // A robot that support houseCleaning and doesn't support spotCleaning
                [OHHTTPStubs stub:@"/vendors/neato/robots/serial/messages"
                         withJSON:@"{\"result\":\"ok\", \"state\":1, \"availableServices\":{\"houseCleaning\":\"version_1\"}}"
                             code:200];
            });
            
            it(@"can execute houseCleaning",^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret" model:@"botvacConnected"];
                waitUntil(^(DoneCallback done) {
                    
                    [robot updateStateWithCompletion:^(NSError * _Nullable error) {
                        NSDictionary* houseCleaningParam = @{@"category":@(RobotCleaningCategoryHouse)};
                        [robot startCleaningWithParameters:houseCleaningParam completion:^(NSError * _Nullable error) {
                            expect(error).to.beNil();
                            done();
                        }];
                        
                    }];
                });
            });
            
            it(@"cannot execute spotCleaning",^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret" model:@"botvacConnected"];
                waitUntil(^(DoneCallback done) {
                    
                    [robot updateStateWithCompletion:^(NSError * _Nullable error) {
                        NSDictionary* houseCleaningParam = @{@"category":@(RobotCleaningCategorySpot)};
                        [robot startCleaningWithParameters:houseCleaningParam completion:^(NSError * _Nullable error) {
                            expect(error).notTo.beNil();
                            done();
                        }];
                        
                    }];
                });
            });
        });
    });
    
    
    describe(@"Schedule", ^{
        
        context(@"when a list of schedules is available", ^{
            before(^{
                signInUser();
                [OHHTTPStubs stub:@"/vendors/neato/robots/serial/messages"
                         withFile:@"botvac_get_schedule.json"
                             code:200];
            });
            
            it(@"receives the list",^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret" model:@"botvacConnected"];
                [robot forceServices:@{@"schedule":@"basic-1"}];
                
                waitUntil(^(DoneCallback done) {
                   
                    [robot getScheduleWithCompletion:^(NSDictionary * _Nonnull scheduleInfo, NSError * _Nullable error) {
                        expect([scheduleInfo[@"events"] count]).to.equal(2);
                        done();
                    }];
                });
            });
        });
        
        context(@"when a robot doesn't support schedule", ^{
            
            before(^{
                signInUser();
                [OHHTTPStubs stub:@"/vendors/neato/robots/serial/messages"
                         withFile:@"botvac_get_schedule.json"
                             code:200];
            });
            
            it(@"receives an error", ^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret" model:@"botvacConnected"];
                
                waitUntil(^(DoneCallback done) {
                    [robot getScheduleWithCompletion:^(NSDictionary * _Nonnull scheduleInfo, NSError * _Nullable error) {
                        expect(error.domain).to.equal(@"Robot.Services");
                        done();
                    }];
                });
                
                waitUntil(^(DoneCallback done) {
                    [robot getScheduleWithCompletion:^(NSDictionary * _Nonnull scheduleInfo, NSError * _Nullable error) {
                        expect(error.domain).to.equal(@"Robot.Services");
                        done();
                    }];
                });
                
                waitUntil(^(DoneCallback done) {
                    [robot enableScheduleWithCompletion:^(NSError * _Nullable error) {
                        expect(error.domain).to.equal(@"Robot.Services");
                        done();
                    }];
                });
                
                waitUntil(^(DoneCallback done) {
                    [robot disableScheduleWithCompletion:^(NSError * _Nullable error) {
                        expect(error.domain).to.equal(@"Robot.Services");
                        done();
                    }];
                });
                
                waitUntil(^(DoneCallback done) {
                    [robot setScheduleWithCleaningEvent:@[] completion:^(NSError * _Nullable error) {
                        expect(error.domain).to.equal(@"Robot.Services");
                        done();
                    }];
                });
                
                waitUntil(^(DoneCallback done) {
                    [robot getScheduleWithCompletion:^(NSDictionary * _Nonnull scheduleInfo, NSError * _Nullable error) {
                        expect(error.domain).to.equal(@"Robot.Services");
                        done();
                    }];
                });
            });
        });
    });
    
});

SpecEnd

//
//  NeatoRobotTest.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 28/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
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
                NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret"];
                expect(robot.name).to.equal(@"name");
                expect(robot.serial).to.equal(@"serial");
                expect(robot.secretKey).to.equal(@"secret");
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
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret"];
                
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
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret"];
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
                         withJSON:@"{\"state\": \"WTF?\",\"action\": 100}"
                             code:200];
            });
            
            it(@"robot is not online", ^{
                __block NeatoRobot *robot = [[NeatoRobot alloc]initWithName:@"name" serial:@"serial" secretKey:@"secret"];
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
});

SpecEnd

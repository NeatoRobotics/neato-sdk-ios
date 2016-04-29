//
//  NeatoRobotCommands.m
//  Example
//
//  Created by Yari D'areglia on 26/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoRobotCommands.h"
@import NeatoSDK;

@interface NeatoRobotCommands()

@property (nonatomic, weak) IBOutlet UILabel* robotState;
@end

@implementation NeatoRobotCommands

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.robot != nil, @"A robot is needed...");
    
    self.title = self.robot.name;
    [self updateRobotState];
}

- (void)updateRobotState{
    [self.robot updateStateWithCompletion:^(NSError * _Nonnull error) {
        if(error){
            self.robotState.text = @"Offline";
        }else{
            self.robotState.text = @"Online";
        }
    }];
}

- (IBAction)robotInfo:(id)sender{
    /*
    NSArray *cleaningEvents = @[
                                @{@"day":@(0), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)},
                                @{@"day":@(1), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)},
                                @{@"day":@(2), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)},
                                @{@"day":@(3), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)},
                                @{@"day":@(4), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)},
                                @{@"day":@(5), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)},
                                @{@"day":@(6), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)},
                                @{@"day":@(7), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)}
                                ];
    
    [self.robot setScheduleWithCleaningEvent:cleaningEvents completion:^(NSError * _Nullable error) {
        if(!error){

        }else{
            NSLog(@"Error");
        }
    }];
    */
    
    [self.robot getScheduleWithCompletion:^(NSDictionary * _Nonnull scheduleInfo, NSError * _Nullable error) {
        NSLog(@"%@", scheduleInfo);
    }];
}

- (IBAction)readSchedule:(id)sender{
    
}

- (IBAction)startCleaning:(id)sender{

    [self.robot startCleaningWithParameters:@{@"category":@(RobotCleaningCategoryHouse),
                                              @"modifier":@(RobotCleaningModifierNormal),
                                              @"mode":@(RobotCleaningModeTurbo)}
                                 completion:^(NSError * _Nullable error) {
                                     NSLog(@"OK!");
    }];
}

- (IBAction)stopCleaning:(id)sender{
    
    [self.robot stopCleaningWithCompletion:^(NSError * _Nullable error) {
                                     NSLog(@"OK!");
    }];
}

- (IBAction)enableSchedule:(id)sender{
    
    [self.robot enableScheduleWithCompletion:^(NSError * _Nullable error) {
        
    }];
}

- (IBAction)disableSchedule:(id)sender{
    
    [self.robot disableScheduleWithCompletion:^(NSError * _Nullable error) {
        
    }];
}
@end

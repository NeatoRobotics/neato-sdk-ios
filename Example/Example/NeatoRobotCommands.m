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
@property (nonatomic, weak) IBOutlet UISwitch* scheduleSwitch;
@property (nonatomic, weak) IBOutlet UILabel* robotState;
@end

@implementation NeatoRobotCommands

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.robot != nil, @"A robot is needed...");
    
    self.title = self.robot.name;
    [self updateRobotState];
}

#pragma - Robot -

- (IBAction)updateRobotState{
    
    [self.robot updateStateWithCompletion:^(NSError * _Nonnull error) {
        if(error){
            self.robotState.text = @"Offline";
        }else{
            self.robotState.text = @"Online";
        }
    }];
}


- (IBAction)robotInfo:(id)sender{
    [self.robot getScheduleWithCompletion:^(NSDictionary * _Nonnull scheduleInfo, NSError * _Nullable error) {
        NSLog(@"%@", scheduleInfo);
    }];
}

#pragma mark - Cleaning -

- (IBAction)startCleaning:(id)sender{

    [self.robot startCleaningWithParameters:@{@"category":@(RobotCleaningCategoryHouse),
                                              @"modifier":@(RobotCleaningModifierNormal),
                                              @"mode":@(RobotCleaningModeTurbo)}
                                 completion:^(NSError * _Nullable error) {
                                     
                                     [self stopLoading];
    }];
}

- (IBAction)stopCleaning:(id)sender{
    
    [self.robot stopCleaningWithCompletion:^(NSError * _Nullable error) {
        [self stopLoading];
    }];
}

- (IBAction)pauseCleaning:(id)sender{
    
    [self.robot pauseCleaningWithCompletion:^(NSError * _Nullable error) {
        [self stopLoading];
    }];
}

#pragma mark - Scheduling -

- (IBAction)scheduleStateChanged:(id)sender{
    if ([self.scheduleSwitch isOn]){
        [self enableSchedule];
    }else{
        [self disableSchedule];
    }
}

- (IBAction)scheduleMonday{
    NSArray *cleaningEvents = @[@{@"day":@(0), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)}];
    [self schedule:cleaningEvents];
}

- (IBAction)scheduleWeek{
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
    [self schedule:cleaningEvents];
}

- (void)schedule:(NSArray *)events{
    [self.robot setScheduleWithCleaningEvent:events completion:^(NSError * _Nullable error) {
        
        [self stopLoading];

        if(!error){
            
        }else{
            NSLog(@"Error");
        }
        
    }];
}

- (void)enableSchedule{
    
    [self.robot enableScheduleWithCompletion:^(NSError * _Nullable error) {
        [self stopLoading];
    }];
}

- (void)disableSchedule{
    
    [self.robot disableScheduleWithCompletion:^(NSError * _Nullable error) {
        [self stopLoading];
    }];
}

- (void)stopLoading{

}

@end

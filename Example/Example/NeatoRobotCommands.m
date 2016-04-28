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
    
}

- (IBAction)startCleaning:(id)sender{
    [self.robot startCleaningWithParameters:@{@"category":@(2), @"modifier":@(1), @"mode":@(1)}
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
}

- (IBAction)disableSchedule:(id)sender{
}
@end

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
    [self.robot updateState:^{
        self.robotState.text = (self.robot.online) ? @"ONLine" : @"OFFLine" ;
    } failure:^(NSError *error) {
        self.robotState.text = (self.robot.online) ? @"ONLine" : @"OFFLine" ;
    }];
}

- (IBAction)robotInfo:(id)sender{
    
}

- (IBAction)startCleaning:(id)sender{
    [self.robot startCleaning:@{@"category":@(2), @"modifier":@(1), @"mode":@(1)} success:^{
        NSLog(@"cleaning");
    } failure:^(NSError * _Nullable error) {
        NSLog(@"Error");
    }];
}

- (IBAction)stopCleaning:(id)sender{
    [self.robot stopCleaning:^{
        nil;
    } failure:^(NSError * _Nullable error) {
        nil;
    }];
}

- (IBAction)enableSchedule:(id)sender{
}

- (IBAction)disableSchedule:(id)sender{
}
@end

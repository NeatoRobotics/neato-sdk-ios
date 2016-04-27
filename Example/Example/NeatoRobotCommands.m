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
    [[NeatoClient sharedInstance] getRobotState:self.robot.serial
                                 robotSecretKey:self.robot.secretKey
                                       complete:^(id  _Nullable robotState, bool online, NSError * _Nonnull error) {
                                           
                                           if(online){
                                               self.robotState.text = @"Online";
                                           }else{
                                               self.robotState.text = @"OFFLINE";
                                           }
    }];
}

- (IBAction)robotInfo:(id)sender{
    [[NeatoClient sharedInstance]
     getRobotInfo:self.robot.serial
     robotSecretKey:self.robot.secretKey
     complete:^(id  _Nullable robotInfo, NSError * _Nonnull error) {
         NSLog(@"%@", robotInfo);
    }];
}
@end

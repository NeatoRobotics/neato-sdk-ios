//
//  NeatoDashboardViewController.m
//  Example
//
//  Created by Yari D'areglia on 22/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoDashboardViewController.h"
#import "NeatoRobotCommands.h"
#import "RobotCell.h"
#import "NeatoSDK.h"

@interface NeatoDashboardViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *robots;
@property (nonatomic, weak) IBOutlet UITableView *table;
@end

@implementation NeatoDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"DASHBOARD";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.robots = [NSMutableArray array];
    NeatoUser *user = [NeatoUser new];
    
    [user getRobotsWithCompletion:^(NSArray * _Nullable robots, NSError * _Nonnull error) {
        self.robots = robots;
        [self.table reloadData];
        [self updateRobots];
    }];
}

- (void)updateRobots{
    for(NeatoRobot *robot in self.robots){
        [robot updateStateWithCompletion:^(NSError * _Nullable error) {
            NSUInteger index = [self.robots indexOfObject:robot];
            [self.table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                              withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)logout:(id)sender{
    [[NeatoAuthentication sharedInstance] logoutWithCompletion:^(NSError * _Nonnull error) {        
        [self dismissViewControllerAnimated:true completion:nil];
    }];
}

#pragma mark - Table Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.robots count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NeatoRobot *robot = self.robots[indexPath.row];
    RobotCell *cell = (RobotCell*)[tableView dequeueReusableCellWithIdentifier:@"robot_cell"];
    cell.name.text = robot.name;
    
    NSString *status = @"OFFLINE";
    UIColor *color = [UIColor colorWithWhite:0.5 alpha:1.0];
    
    if (robot.online){
        switch (robot.state) {
            case RobotStateIdle:
                status = @"READY";
                color = [UIColor colorWithRed:0.2 green:0.7 blue:0.1 alpha:1.0];
                break;
            case RobotStateBusy:
                status = @"BUSY";
                color = [UIColor orangeColor];
                break;
            case RobotStatePaused:
                status = @"PAUSED";
                color = [UIColor colorWithRed:0.2 green:0.7 blue:0.1 alpha:1.0];
                break;
            default:
                status = @"ERROR";
                color = [UIColor colorWithRed:0.8 green:0.2 blue:0.1 alpha:1.0];
                break;
        }
    }
    cell.status.text = status;
    cell.status.textColor = color;
    cell.battery.text = [NSString stringWithFormat:@"%d%%",robot.chargeLevel];
    cell.batteryIndicator.progress = robot.chargeLevel / 100.0;
    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UITableViewCell *cell = sender;
    NSIndexPath *index = [self.table indexPathForCell:cell];
    [self.table deselectRowAtIndexPath:index animated:false];
    NeatoRobot *robot = self.robots[index.row];
    NeatoRobotCommands *commands = segue.destinationViewController;
    commands.robot = robot;
}

@end

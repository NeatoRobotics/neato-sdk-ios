//
//  NeatoDashboardViewController.m
//  Example
//
//  Created by Yari D'areglia on 22/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoDashboardViewController.h"
#import "NeatoRobotCommands.h"
#import "Robot.h"

@import NeatoSDK;

@interface NeatoDashboardViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *robots;
@property (nonatomic, weak) IBOutlet UITableView *table;
@end

@implementation NeatoDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"DASHBOARD";
    self.robots = [NSMutableArray array];
    NeatoUser *user = [NeatoUser new];
    
    [user getRobotsWithCompletion:^(NSArray * _Nullable robots, NSError * _Nonnull error) {
        
        for (NSDictionary *robotData in robots){
            Robot * robot = [Robot robotWithDictionary:robotData];
            [self.robots addObject:robot];
        }

        [self.table reloadData];
    }];
    
    [user updateUserInfo:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
        NSLog(@"%@ %@ %@", user.firstname, user.lastname, user.email);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)logout:(id)sender{
    [[NeatoAuthentication sharedInstance] logoutWithCompletion:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        
        [self dismissViewControllerAnimated:true completion:nil];
    }];
}

#pragma mark - Table Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.robots count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Robot *robot = self.robots[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"robot_cell"];
    cell.textLabel.text = robot.name;
    cell.detailTextLabel.text = robot.model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSegueWithIdentifier:@"robotCommands" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UITableViewCell *cell = sender;
    NSIndexPath *index = [self.table indexPathForCell:cell];
    Robot *robot = self.robots[index.row];
    NSLog(@"ROBOT%@", robot);
    NeatoRobotCommands *commands = segue.destinationViewController;
    commands.robot = [[NeatoRobot alloc]initWithName:robot.name serial:robot.serial secretKey:robot.secretKey];
}
@end

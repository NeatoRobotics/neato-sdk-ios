//
//  NeatoDashboardViewController.m
//  Example
//
//  Created by Yari D'areglia on 22/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoDashboardViewController.h"
#import "Robot.h"

@import NeatoSDK;

@interface NeatoDashboardViewController ()
@property (nonatomic, weak) IBOutlet UILabel *tokenLabel;
@property (nonatomic, strong) NSMutableArray *robots;
@end

@implementation NeatoDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"DASHBOARD";
    self.tokenLabel.text = [NeatoAuthentication sharedInstance].accessToken;
    
    self.robots = [NSMutableArray array];

    [[NeatoClient sharedInstance]robots:^(NSArray * _Nullable robots, NSError * _Nonnull error) {
        
        for (NSDictionary *robotData in robots){
            Robot * robot = [Robot robotWithDictionary:robotData];
            [self.robots addObject:robot];
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)logout:(id)sender{
    [[NeatoClient sharedInstance] logout:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        
        [self dismissViewControllerAnimated:true completion:nil];
    }];
}

@end

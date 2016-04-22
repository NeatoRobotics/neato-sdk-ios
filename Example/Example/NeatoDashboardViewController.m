//
//  NeatoDashboardViewController.m
//  Example
//
//  Created by Yari D'areglia on 22/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoDashboardViewController.h"
@import NeatoSDK;

@interface NeatoDashboardViewController ()
@property (nonatomic, weak) IBOutlet UILabel *tokenLabel;
@end

@implementation NeatoDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"DASHBOARD";
    self.tokenLabel.text = [NeatoAuthentication sharedInstance].accessToken;
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

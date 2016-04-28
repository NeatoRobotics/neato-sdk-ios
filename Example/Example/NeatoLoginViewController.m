//
//  NeatoLoginViewController.m
//  Example
//
//  Created by Yari D'areglia on 22/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoLoginViewController.h"
@import NeatoSDK;

@interface NeatoLoginViewController ()

@end

@implementation NeatoLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([[NeatoClient sharedInstance]isAuthenticated]){
        [self enterDashboard];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)launchLogin:(id)sender{
    
    [[NeatoClient sharedInstance] openLoginInBrowserWithCompletion:^(NSError *error) {
        if(error == nil){
            [self enterDashboard];
        }
    }];
}

- (void) enterDashboard{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *dashboard = [storyboard instantiateViewControllerWithIdentifier:@"Authorized"];
    
    [self presentViewController:dashboard animated:true completion:nil];
}

@end

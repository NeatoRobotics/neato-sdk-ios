//
//  NeatoLoginViewController.m
//  Example
//
//  Created by Yari D'areglia on 22/04/16.
//  2016 Neato Robotics.
//

#import "NeatoLoginViewController.h"
#import "NeatoSDK.h"

@interface NeatoLoginViewController ()

@end

@implementation NeatoLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:@"Logout" object:nil];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([[NeatoAuthentication sharedInstance]isAuthenticated]){
        [self enterDashboard];
    }
}

- (void)logout{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)launchLogin:(id)sender{
    
    [[NeatoAuthentication sharedInstance] openLoginInBrowserWithCompletion:^(NSError *error) {
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

//
//  NeatoUserViewController.m
//  Example
//
//  Created by Yari D'areglia on 20/05/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoUserViewController.h"
#import "NeatoSDK.h"

@interface NeatoUserViewController ()
@property (nonatomic, weak) IBOutlet UILabel* email;
@property (nonatomic, weak) IBOutlet UILabel* firstname;
@property (nonatomic, weak) IBOutlet UILabel* lastname;
@end

@implementation NeatoUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NeatoUser *user = [NeatoUser new];
    
    __weak typeof(self) weakSelf = self;
    
    [user getUserInfo:^(NSDictionary * _Nonnull userinfo, NSError * _Nullable error) {
        if(!error){
            NSLog(@"%@", userinfo);
            weakSelf.email.text = userinfo[@"email"];
            weakSelf.firstname.text = ([userinfo[@"first_name"] isEqual:[NSNull null]]) ? @"-" : userinfo[@"first_name"];
            weakSelf.lastname.text = ([userinfo[@"last_name"] isEqual:[NSNull null]]) ? @"-" : userinfo[@"last_name"];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

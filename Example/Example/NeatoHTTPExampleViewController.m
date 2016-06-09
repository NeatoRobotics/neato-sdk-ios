//
//  NeatoHTTPExampleViewController.m
//  Example
//
//  Created by Yari D'areglia on 09/06/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NeatoHTTPExampleViewController.h"
#import "NeatoHTTPSessionManager.h"

@interface NeatoHTTPExampleViewController ()

@end

@implementation NeatoHTTPExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendData {
    NeatoHTTPSessionManager *manager = [[NeatoHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:@"https://httpbin.org"]];
    NSLog(@"POST");
    [manager POST:@"post"
       parameters:nil progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"SUCCESS");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"FAIL");
    }];
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

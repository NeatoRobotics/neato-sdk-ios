//
//  RobotCell.h
//  Example
//
//  Created by Yari D'areglia on 09/05/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RobotCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UILabel *status;
@property (nonatomic, weak) IBOutlet UILabel *model;
@property (nonatomic, weak) IBOutlet UILabel *battery;
@property (nonatomic, weak) IBOutlet UIProgressView *batteryIndicator;

@end

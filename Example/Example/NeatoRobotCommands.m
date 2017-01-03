//
//  NeatoRobotCommands.m
//  Example
//
//  Created by Yari D'areglia on 26/04/16.
//  2016 Neato Robotics.
//

#import "NeatoRobotCommands.h"

@interface NeatoRobotCommands()
@property (nonatomic, weak) IBOutlet UISwitch* scheduleSwitch;
@property (nonatomic, weak) IBOutlet UILabel* robotState;
@property (nonatomic, weak) IBOutlet UIView* loader;

// Commands Buttons
@property (nonatomic, weak) IBOutlet UIButton *startHouseCleaning;
@property (nonatomic, weak) IBOutlet UIButton *startSpotCleaning;
@property (nonatomic, weak) IBOutlet UIButton *pauseCleaning;
@property (nonatomic, weak) IBOutlet UIButton *stopCleaning;
@property (nonatomic, weak) IBOutlet UIButton *dock;
@end

@implementation NeatoRobotCommands

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.robot != nil, @"A robot is needed...");
    
    self.title = self.robot.name;
    [self setupUI];
    [self attachLoader];
    [self updateRobotState];
}

- (void)setupUI{

    self.startHouseCleaning.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.startHouseCleaning.titleLabel.numberOfLines = 2;
    self.startHouseCleaning.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.startSpotCleaning.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.startSpotCleaning.titleLabel.numberOfLines = 2;
    self.startSpotCleaning.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)attachLoader{
    
    self.loader.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loader];
    
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[loader]-0-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:@{@"loader":self.loader}];
    
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[loader]-0-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:@{@"loader":self.loader}];
    
    [self.view addConstraints:constraint_POS_V];
    [self.view addConstraints:constraint_POS_H];
}

- (void)updateStateDescription{
    
    if (self.robot.online){
    
        switch (self.robot.state) {
                
            case RobotStateIdle:
                self.robotState.text = @"Ready to clean";

                break;
            
            case RobotStateBusy:
                
                switch (self.robot.action){
                        
                    case RobotActionHouseCleaning:
                        self.robotState.text = @"House Cleaning";
                        break;
                        
                    case RobotActionSpotCleaning:
                        self.robotState.text = @"Spot Cleaning";
                        break;
                        
                    case RobotActionManualCleaning:
                        self.robotState.text = @"Manual Cleaning";
                        break;
                        
                        // You can handle all the other Robot Action here
                        
                    default:
                        self.robotState.text = @"Busy";
                }
                break;
                
            case RobotStatePaused:
                self.robotState.text = @"Paused";
                break;
                
            case RobotStateError:
                self.robotState.text = @"Error";
                break;
                
            case RobotStateInvalid:
                self.robotState.text = @"???";

        }
        
        if(self.robot.action == RobotStateBusy){

        }
        
        if(self.robot.action == RobotStateBusy){
        
        }
    }else{
        self.robotState.text = @"Offline";
    }
}

#pragma - Robot -

- (IBAction)updateRobotState{
    [self startLoading];

    __weak typeof(self) weakSelf = self;

    [self.robot updateStateWithCompletion:^(NSError * _Nonnull error) {
        [weakSelf updateStateDescription];
        [weakSelf syncButtonsWithAvailableCommands];
        [weakSelf stopLoading];
    }];
}

- (void) syncButtonsWithAvailableCommands{
    self.startSpotCleaning.enabled = [self.robot.availableCommands[@"start"]boolValue];
    self.startHouseCleaning.enabled = [self.robot.availableCommands[@"start"]boolValue];

    self.pauseCleaning.enabled = [self.robot.availableCommands[@"pause"]boolValue];
    self.stopCleaning.enabled = [self.robot.availableCommands[@"stop"]boolValue];
    self.dock.enabled = [self.robot.availableCommands[@"goToBase"]boolValue];

    NSLog(@"%@", self.robot.availableCommands);
}

- (IBAction)robotInfo:(id)sender{
    [self.robot getScheduleWithCompletion:^(NSDictionary * _Nonnull scheduleInfo, NSError * _Nullable error) {
        NSLog(@"%@", scheduleInfo);
    }];
}

- (IBAction)findRobot:(id)sender{
    __weak typeof(self) weakSelf = self;
    [self.robot findMeWithCompletion:^(NSError * _Nullable error) {
        if(error){
            if(error.domain == kNeatoError_RobotServices){
                [weakSelf showMessage:@"Find Me is not supported by this robot" title:@"Error"];
            }
        }
    }];
}

#pragma mark - Cleaning -

- (IBAction)startHouseCleaning:(id)sender{
    [self startLoading];

    __weak typeof(self) weakSelf = self;
    [self.robot startCleaningWithParameters:@{@"category":@(RobotCleaningCategoryHouse),
                                              @"modifier":@(RobotCleaningModifierNormal),
                                              @"mode":@(RobotCleaningModeTurbo),
                                              @"navigationMode":@(RobotNavigationModeNormal)}
                                 completion:^(NSError * _Nullable error) {
                                     if(error == nil){
                                         
                                         [weakSelf updateStateDescription];
                                         [weakSelf syncButtonsWithAvailableCommands];
                                         [weakSelf stopLoading];
                                     }else{
                                         NSLog(@"%@", error.localizedDescription);
                                     }
    }];
}

- (IBAction)startSpotCleaning:(id)sender{
    [self startLoading];
    
    __weak typeof(self) weakSelf = self;
    [self.robot startCleaningWithParameters:@{@"category":@(RobotCleaningCategorySpot),
                                              @"modifier":@(RobotCleaningModifierNormal),
                                              @"mode":@(RobotCleaningModeTurbo),
                                              @"spotWidth":@(200),
                                              @"spotHeight":@(200),
                                              @"navigationMode":@(RobotNavigationModeNormal)}
                                 completion:^(NSError * _Nullable error) {
                                     if(error == nil){
                                         
                                         [weakSelf updateStateDescription];
                                         [weakSelf syncButtonsWithAvailableCommands];
                                         [weakSelf stopLoading];
                                     }else{
                                         NSLog(@"%@", error.localizedDescription);
                                     }
                                 }];
}

- (IBAction)stopCleaning:(id)sender{
    [self startLoading];

    __weak typeof(self) weakSelf = self;

    [self.robot stopCleaningWithCompletion:^(NSError * _Nullable error) {
        
        [weakSelf updateStateDescription];
        [weakSelf syncButtonsWithAvailableCommands];
        [weakSelf stopLoading];
    }];
}

- (IBAction)pauseCleaning:(id)sender{
    [self startLoading];

    __weak typeof(self) weakSelf = self;

    [self.robot pauseCleaningWithCompletion:^(NSError * _Nullable error) {
        
        [weakSelf updateStateDescription];
        [weakSelf syncButtonsWithAvailableCommands];
        [weakSelf stopLoading];
    }];
}

- (IBAction)returnToBase:(id)sender{
    [self startLoading];
    
    __weak typeof(self) weakSelf = self;
    
    [self.robot sendToBaseWithCompletion:^(NSError * _Nullable error) {
        
        [weakSelf updateStateDescription];
        [weakSelf syncButtonsWithAvailableCommands];
        [weakSelf stopLoading];
    }];
}

#pragma mark - Scheduling -

- (IBAction)scheduleStateChanged:(id)sender{
    [self startLoading];

    if ([self.scheduleSwitch isOn]){
        [self enableSchedule];
    }else{
        [self disableSchedule];
    }
}

- (IBAction)scheduleMonday{
    NSArray *cleaningEvents = @[@{@"day":@(0), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)}];
    [self schedule:cleaningEvents];
}

- (IBAction)scheduleWeek{
    NSArray *cleaningEvents = @[
                                @{@"day":@(0), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)},
                                @{@"day":@(1), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)},
                                @{@"day":@(2), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)},
                                @{@"day":@(3), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)},
                                @{@"day":@(4), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)},
                                @{@"day":@(5), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)},
                                @{@"day":@(6), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)},
                                @{@"day":@(7), @"startTime":@"10:00", @"mode":@(RobotCleaningModeEco)}
                                ];
    [self schedule:cleaningEvents];
}

- (void)schedule:(NSArray *)events{
    [self startLoading];

    __weak typeof(self) weakSelf = self;
    [self.robot setScheduleWithCleaningEvent:events completion:^(NSError * _Nullable error) {

        [weakSelf stopLoading];

        if(!error){
            
        }else{
            NSLog(@"Error");
        }
        
    }];
}

- (void)enableSchedule{
    [self startLoading];

    __weak typeof(self) weakSelf = self;
    [self.robot enableScheduleWithCompletion:^(NSError * _Nullable error) {
        [weakSelf stopLoading];
    }];
}

- (void)disableSchedule{
    [self startLoading];

    __weak typeof(self) weakSelf = self;
    [self.robot disableScheduleWithCompletion:^(NSError * _Nullable error) {
        [weakSelf stopLoading];
    }];
}

#pragma mark - Maps -

- (IBAction)getMaps{
    [self startLoading];
    
    __weak typeof(self) weakSelf = self;
    
    // Get the list of Maps for this robot
    [self.robot getMapsWithCompletion:^(NSArray * _Nonnull maps, NSError * _Nullable error) {
        
        if(error == nil){
            if (maps.count > 0){
                // Get details for a specific Map
                NSString *mapID = maps[0][@"id"];
                
                [self.robot getMapInfo:mapID completion:^(NSDictionary * _Nonnull mapInfo, NSError * _Nullable error) {
                    if (error == nil){
                        [weakSelf showMessage:[NSString stringWithFormat:@"%@",mapInfo] title:@"Maps info"];
                    }
                    [weakSelf stopLoading];
                }];
            }
        }else{
            if(error.domain == kNeatoError_RobotServices){
                [weakSelf showMessage:@"Maps service is not supported by this robot" title:@"Error"];
            }
            
            [weakSelf stopLoading];
        }
    }];
}

#pragma mark - UI -

- (void)showMessage:(NSString *)message title:(NSString *)title{
    UIAlertController *ctr = [UIAlertController alertControllerWithTitle:title
                                                                 message:message
                                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    [ctr addAction:action];
    
    [self presentViewController:ctr animated:true completion:nil];
}

- (void)startLoading{
    [UIView animateWithDuration:0.3 animations:^{
        self.loader.alpha = 1.0;
        self.loader.userInteractionEnabled = true;
    }];
}

- (void)stopLoading{
    [UIView animateWithDuration:0.3 animations:^{
        self.loader.alpha = 0;
        self.loader.userInteractionEnabled = false;
    }];
}

@end

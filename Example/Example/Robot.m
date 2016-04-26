//
//  Robot.m
//  Example
//
//  Created by Yari D'areglia on 26/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "Robot.h"

@implementation Robot

+ (instancetype)robotWithDictionary:(NSDictionary *)data {
    Robot *robot = [[Robot alloc]initWithDictionary:data];
    
    return robot;
}

- (instancetype)initWithDictionary:(NSDictionary *)data {
    
    self = [super init];
    if (self) {
        self.name = data[@"name"];
        self.serial = data[@"serial"];
        self.model = data[@"model"];
    }
    return self;
}



@end

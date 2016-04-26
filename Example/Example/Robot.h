//
//  Robot.h
//  Example
//
//  Created by Yari D'areglia on 26/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Robot : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *serial;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *secretKey;

+ (instancetype)robotWithDictionary:(NSDictionary *) data;
- (instancetype)initWithDictionary:(NSDictionary*) data;

@end

//
//  NSDate+Neato.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 26/04/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import "NSDate+Neato.h"

@implementation NSDate (Neato)

- (NSString *) rfc1123String
{
    static NSDateFormatter *df = nil;
    if(df == nil)
    {
        df = [[NSDateFormatter alloc] init];
        df.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
    }
    return [df stringFromDate:self];
}
@end

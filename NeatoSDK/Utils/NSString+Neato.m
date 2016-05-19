//
//  NSString+Neato.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 26/04/16.
//  2016 Neato Robotics.
//

#import "NSString+Neato.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (Neato)

-(NSString *)SHA256:(NSString *)key{
    
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    return [[HMAC.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}
@end

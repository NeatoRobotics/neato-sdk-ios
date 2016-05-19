#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#import "NSDate+Neato.h"
#import "NSString+Neato.h"

@import NeatoSDK;

SpecBegin(NeatoUtils)

describe(@"Neato Utils", ^{
    
    describe(@"String category", ^{
        
        it(@"returns a sha256 signed string", ^{
            NSString *unsignedString = @"value";
            NSString *signedString = [unsignedString SHA256:@"key"];
            
            expect(signedString).to.equal(@"90fbfcf15e74a36b89dbdb2a721d9aecffdfdddc5c83e27f7592594f71932481");
        });
    });
    
    describe(@"Date category", ^{
        
        it(@"returns a rfc date", ^{
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
            expect(date.rfc1123String).to.equal(@"Thu, 01 Jan 1970 00:00:00 GMT");
        });
    });
});
SpecEnd
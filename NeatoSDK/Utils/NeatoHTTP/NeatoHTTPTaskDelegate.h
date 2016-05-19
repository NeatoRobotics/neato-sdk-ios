//
//  NeatoHTTPTaskDelegate.h
//  NeatoHTTP
//
//  Created by Yari D'areglia on 12/05/16.
//  2016 Neato Robotics.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NeatoHTTPTaskCompletionCallback)(NSHTTPURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error);

@interface NeatoHTTPTaskDelegate : NSObject

- (instancetype)initWithCompletion:(NeatoHTTPTaskCompletionCallback)completion;
- (void)didReceiveData:(NSData*)data;
- (void)didCompleteWithResponse:(NSHTTPURLResponse* _Nullable)response Error:(NSError* _Nullable)error;

@end

NS_ASSUME_NONNULL_END

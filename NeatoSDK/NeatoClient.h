//
//  NeatoClient.h
//  iossdk
//
//  Created by Yari D'areglia
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NeatoClient : NSObject

@property (nonatomic, copy, nullable) NSString* token;

+ (instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init __attribute__ ((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new __attribute__  ((unavailable("new not available, call sharedInstance instead")));
- (instancetype) copy __attribute__ ((unavailable("copy not available, call sharedInstance instead")));

+ (instancetype)sharedInstance;

#pragma mark - NeatoAuthentication bridge

+ (void) configureWithClientID: (NSString*) clientID
                        scopes: (NSArray<NSString*> *) scopes
                   redirectURI: (NSString*) redirectURI;

- (void) openLoginInBrowser:(void (^)(NSError* error)) completionHandler;
- (void) handleURL:(NSURL*)url;
- (BOOL) isAuthenticated;
- (void) logout:(void (^)(NSError* error)) completionHandler;

#pragma mark - User commands

- (void) robots:(void (^)(NSArray* _Nullable robots, NSError *error))completionHandler;

@end

NS_ASSUME_NONNULL_END
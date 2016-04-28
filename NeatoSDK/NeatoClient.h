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

/**
 Configure the client with information related to the App.
 
 @param clientID    the ID that defines the App
 @param scopes      the scopes this App will request
 @param redirectURI the redirect URI called when user completes a login (it has to contain your custom URI Schema).
 
**/
+ (void) configureWithClientID: (NSString*) clientID
                        scopes: (NSArray<NSString*> *) scopes
                   redirectURI: (NSString*) redirectURI;

/**
 Open user's browser at the Neato login URL.
 
 @param completionHandler The callback called when application is launched through the redirectURI, when user login completes.
 
**/
- (void) openLoginInBrowserWithCompletion:(void (^)(NSError* error)) completionHandler;

/**
 Call this function from application:(UIApplication *)application handleOpenURL:(NSURL *)url
 
 @param url the url received via handleOpenURL.

 **/
- (void) handleURL:(NSURL*)url;

/**
 Return true if user has a valid token. This function verifies only that a not expired token is available, it doesn't verify the token over Neato servers.
 
 **/
- (BOOL) isAuthenticated;

/**
 Perform logout.
 
 @param completionHandler Callback raised when the logout call completes.
 
 **/
- (void) logoutWithCompletion:(void (^)(NSError* error)) completionHandler;

#pragma mark - User commands

/**
 Get user robots.
 
 @param completionHandler Callback raised when the logout call completes.
 
 **/
- (void) robotsWithCompletion:(void (^)(NSArray* _Nullable robots, NSError *error))completionHandler;

@end

NS_ASSUME_NONNULL_END
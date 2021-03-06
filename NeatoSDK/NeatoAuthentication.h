//
//  NeatoAuthentication.h
//  NeatoSDK
//
//  Created by Yari D'areglia on 24/03/16.
//

#import <Foundation/Foundation.h>
#import "NeatoTokenStore.h"
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif
NS_ASSUME_NONNULL_BEGIN

#pragma mark - Constants and Typedef

typedef enum : NSUInteger {
    NeatoAuthenticationErrorDeny
} NeatoAuthenticationError;

extern NSString* const NeatoAuthenticationErrorDomain;
extern NSString* const NeatoOAuthScopeControlRobots;
extern NSString* const NeatoOAuthScopePublicProfile;
extern NSString* const NeatoOAuthScopeMaps;

typedef void (^NeatoAuthenticationCallback)(NSError* _Nullable error );
typedef void (^NeatoAuthenticationLogoutCallback)(NSError* _Nullable  error);

#pragma mark - NeatoAuthentication Class

@interface NeatoAuthentication : NSObject

@property (nonatomic, copy, nullable) NSString* clientID;
@property (nonatomic, copy, nullable) NSArray* authScopes;
@property (nonatomic, copy, nullable) NSString* redirectURI;
@property (nonatomic, copy, nullable) NSString* accessToken;
@property (nonatomic, copy, nullable) NSDate* accessTokenExpiration;
@property (nonatomic, strong, nullable) id<NeatoTokenStore> tokenStore;

+ (instancetype) alloc __attribute__((unavailable("Initialize using sharedInstance")));
+ (instancetype) new __attribute__  ((unavailable("Initialize using sharedInstance")));
- (instancetype) init __attribute__ ((unavailable("Initialize using sharedInstance")));
- (instancetype) copy __attribute__ ((unavailable("Initialize using sharedInstance")));

/**
 Singleton accessor.
**/
+ (instancetype) sharedInstance;

/**
 Configure the shared instance.

 @param  clientID
 @param  scopes
 @param  redirectURI

**/
+ (void) configureWithClientID: (NSString*) clientID
                       scopes: (NSArray<NSString*> *) scopes
                  redirectURI: (NSString*) redirectURI;


/** 
 Obtain the authorization url. 
 You might need this method to write a custom authentication flow.
 Use `openLoginInBrowserWithCompletion` or `presentLogicnControllerWithCompletion` to run
 the default authentication flow.
 **/
- (NSURL*) authorizationURL;

/**
 Launch the authentication process with an external browser.
 
 @param  completionHandler
 
**/
- (void) openLoginInBrowserWithCompletion:(NeatoAuthenticationCallback) completionHandler;

#if TARGET_OS_IOS
/**
 Launch the authentication process with a local viewController
 
 @param  completionHandler
 
**/
- (void) presentLoginControllerWithCompletion:(NeatoAuthenticationCallback) completionHandler;
#endif

/**
 Call this method inside the appDelegate application:handleOpenURL: method
 to complete the auth process.
 
 @param  completionHandler
 
**/
- (void) handleURL:(NSURL*)url;

/**
 Verify if a not expired token is stored in the current device.
 Note: this function doesn't verify if the token is currently available on the server.
 
**/
- (BOOL) isAuthenticated;

/**
 Perform logout on server and remove local token data.

**/
- (void) logoutWithCompletion:(NeatoAuthenticationLogoutCallback) completionHandler;

@end

NS_ASSUME_NONNULL_END

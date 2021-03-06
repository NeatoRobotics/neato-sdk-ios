//
//  NeatoAuthentication.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 24/03/16.
//

@import UIKit;
@import SafariServices;

#import "NeatoAuthentication.h"
#import "NeatoTokenUserDefaultStore.h"
#import "NeatoSDKSessionManager.h"

#pragma mark - Constants and Typedef

NSString* const NeatoAuthenticationErrorDomain  = @"com.neatosdk.authentication";
NSString* const NeatoOAuthScopeControlRobots    = @"control_robots";
NSString* const NeatoOAuthScopePublicProfile    = @"public_profile";
NSString* const NeatoOAuthScopeMaps             = @"maps";

static NSString * const kNeatoOAuthAuthorizeEndPoint = @"https://apps.neatorobotics.com/oauth2/authorize?";

#pragma mark - NeatoAuthentication Implementation

@interface NeatoAuthentication()
@property (nonatomic, strong) NeatoAuthenticationCallback authenticationCallback;
@property (nonatomic, strong) NSString *oauthState;
@end

@implementation NeatoAuthentication
@synthesize accessToken = _accessToken;

#pragma mark - Public Methods

- (instancetype) initInstance
{
    return [super init];
}

// TODO: DO NOT USE SINGLETON PATTER :(
+ (instancetype) sharedInstance
{
    static NeatoAuthentication *neatoAuthClient;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        neatoAuthClient = [[super alloc]initInstance];
        // TODO: Move the tokenstore init and token update into configuration.
        neatoAuthClient.tokenStore = [[NeatoTokenUserDefaultStore alloc]init];
        [neatoAuthClient updateTokenDataFromStore];
    });
    
    return neatoAuthClient;
}

+ (void) configureWithClientID: (NSString*) clientID
                          scopes: (NSArray<NSString*> *) scopes
                     redirectURI: (NSString*) redirectURI {

    [NeatoAuthentication sharedInstance].clientID = clientID;
    [NeatoAuthentication sharedInstance].authScopes = scopes;
    [NeatoAuthentication sharedInstance].redirectURI = redirectURI;
}

- (NSURL*) authorizationURL{
    self.oauthState = [NSString stringWithFormat:@"st%dst",arc4random_uniform(10000)];
    NSString *parametersString = [NSString stringWithFormat:@"client_id=%@&redirect_uri=%@&scope=%@&response_type=token&state=%@",
                                  self.clientID,
                                  self.redirectURI,
                                  [self.authScopes componentsJoinedByString:@"+"],
                                  self.oauthState];
    
    NSString *urlPath = [kNeatoOAuthAuthorizeEndPoint stringByAppendingString:parametersString];
    return [NSURL URLWithString:urlPath];
}

- (void) openLoginInBrowserWithCompletion:(NeatoAuthenticationCallback) completionHandler{
    self.authenticationCallback = completionHandler;
    
    NSURL *authURL = [self authorizationURL];

    if ([[UIApplication sharedApplication] canOpenURL:authURL]) {
        [[UIApplication sharedApplication] openURL:authURL]; // LCOV_EXCL_LINE
    }
}

#if TARGET_OS_IOS
- (void) presentLoginControllerWithCompletion:(NeatoAuthenticationCallback) completionHandler{
    self.authenticationCallback = completionHandler;
    
    NSURL *authURL = [self authorizationURL];
    
    UIViewController *viewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:authURL];
    [viewController presentViewController:safariViewController animated:YES completion:nil];
}
#endif

- (BOOL) isAuthenticated{
    NSString *token = [self.tokenStore readStoredAccessToken];
    NSDate *tokenExpiration = [self.tokenStore readStoredAccessTokenExpirationDate];
    if (token != NULL && [tokenExpiration compare:[NSDate date]] == NSOrderedDescending){
        return true;
    }else{
        return false;
    }
}

//  ACCEPT: your-app://neato#access_token=123cc3f6e3fb4de2dfde5ac63e0a96a2f8c3613f608d53bee5577b727a8ad43b&token_type=bearer&expires_in=1209600
//  DENY: your-app://neato#error=access_denied&error_description=The+resource+owner+or+authorization+server+denied+the+request
- (void) handleURL:(NSURL*)url{
    
    UIViewController *safariViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if ([[safariViewController presentedViewController] isKindOfClass:[SFSafariViewController class]]) {
        [safariViewController dismissViewControllerAnimated:true completion:nil];
    }
    
    NSString *urlPath = [url absoluteString];
    NSRange searchResult = [urlPath rangeOfString:@"#"];
    
    if (searchResult.location != NSNotFound) {
        [self resetTokenData];
        
        NSString *query = [[urlPath componentsSeparatedByString:@"#"] lastObject];
        NSArray *queryElements = [query componentsSeparatedByString:@"&"];
        BOOL authenticationCompleted = NO;
        
        for (NSString *element in queryElements) {
            
            NSArray *keyVal = [element componentsSeparatedByString:@"="];
            
            if (keyVal.count > 0) {
                NSString *key = [keyVal objectAtIndex:0];
                NSString *value = (keyVal.count == 2) ? [keyVal lastObject] : nil;
                
                if ([key isEqualToString:@"error"]){
                    break;
                }
                
                if ([key isEqualToString:@"access_token"]){
                    authenticationCompleted = YES;
                    [self setAccessToken:value];
                }
                
                if ([key isEqualToString:@"expires_in"]){
                    NSDate *expirationDate = [NSDate dateWithTimeInterval:[value integerValue] sinceDate:[NSDate date]];
                    self.accessTokenExpiration = expirationDate;
                }
                
                if ([key isEqualToString:@"state"]){
                    
                    if(![value isEqualToString:self.oauthState]){
                        self.authenticationCallback([NSError errorWithDomain:NeatoAuthenticationErrorDomain code:2 userInfo:nil]);
                        self.accessToken = nil;
                        self.accessTokenExpiration = nil;
                        NSLog(@"Neato SDK: state param is not valid.");
                        break;
                    }
                }

            }
        }
        
        if (authenticationCompleted) {
            [self storeAccessTokenData];
        }
        
        if (self.authenticationCallback){
            
            if (authenticationCompleted){
                self.authenticationCallback(nil);
            }else{
                self.authenticationCallback([NSError errorWithDomain:NeatoAuthenticationErrorDomain code:1 userInfo:nil]);
            }
        }
    }
}

- (void) logoutWithCompletion:(NeatoAuthenticationLogoutCallback)completionHandler{

    NeatoSDKSessionManager *manager = [NeatoSDKSessionManager authenticatedBeehiveManager];
    
    [manager POST:@"/oauth2/revoke"
                    parameters:@{@"token":self.accessToken}
                      progress:^(NSProgress * uploadProgress) {}
                       success:^(NSURLSessionDataTask * task, id responseObject) {
                           
        [self resetTokenData];
        completionHandler(nil);
        
    } failure:^(NSURLSessionDataTask * task, NSError * error) {
        completionHandler(error);
    }];
}

#pragma mark - Private Methods

- (void) storeAccessTokenData{
    [self.tokenStore storeAccessToken:self.accessToken expirationDate:self.accessTokenExpiration];
}

- (void) updateTokenDataFromStore{
    self.accessToken = [self.tokenStore readStoredAccessToken];
    self.accessTokenExpiration = [self.tokenStore readStoredAccessTokenExpirationDate];
}

- (void) resetTokenData{
    self.accessToken = nil;
    self.accessTokenExpiration = nil;
    [self.tokenStore reset];
}

@end

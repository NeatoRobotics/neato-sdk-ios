//
//  NeatoAuthentication.m
//  NeatoSDK
//
//  Created by Yari D'areglia on 24/03/16.
//

@import UIKit;
@import AFNetworking;

#import "NeatoAuthentication.h"
#import "NeatoTokenUserDefaultStore.h"
#import "NeatoHTTPSessionManager.h"

#pragma mark - Constants and Typedef

NSString* const NeatoAuthenticationErrorDomain  = @"com.neatosdk.authentication";
NSString* const NeatoOAuthScopeControlRobots    = @"control_robots";
NSString* const NeatoOAuthScopePublicProfile    = @"public_profile";
NSString* const NeatoOAuthScopeViewRobots       = @"view_robots";
NSString* const NeatoOAuthScopeEmail            = @"email";

static NSString * const kNeatoOAuthLoginEndPoint = @"https://beehive.neatocloud.com/login?";
static NSString * const kNeatoOAuthAuthorizeEndPoint = @"https://beehive.neatocloud.com/oauth2/revoke";

#pragma mark - NeatoAuthentication Implementation

@interface NeatoAuthentication()
@property (nonatomic, strong) NeatoAuthenticationCallback authenticationCallback;
@end

@implementation NeatoAuthentication
@synthesize accessToken = _accessToken;

#pragma mark - Public Methods

- (instancetype) initInstance
{
    return [super init];
}

+ (instancetype) sharedInstance
{
    static NeatoAuthentication *neatoAuthClient;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        neatoAuthClient = [[super alloc]initInstance];
        // TODO: Move the tokenstore init and token update into confiration.
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

- (void) openLoginInBrowserWithCompletion:(NeatoAuthenticationCallback) completionHandler{
    self.authenticationCallback = completionHandler;
    
    NSURL *authURL = [self buildAuthorizationURL];

    if ([[UIApplication sharedApplication] canOpenURL:authURL]) {
        [[UIApplication sharedApplication] openURL:authURL]; // LCOV_EXCL_LINE
    }
}

- (BOOL) isAuthenticated{
    NSString *token = [self.tokenStore readStoredAccessToken];
    NSDate *tokenExpiration = [self.tokenStore readStoredAccessTokenExpirationDate];

    if (token != NULL && [tokenExpiration compare:[NSDate date]] == NSOrderedDescending){
        return true;
    }else{
        return false;
    }
}

//  ACCEPT: marco-app://neato#access_token=3e5cc3f6e3fb4de2dfde5ac63e0a96a2f8c3613f608d53bee5577b727a8ad43b&token_type=bearer&expires_in=1209600
//  DENY: marco-app://neato#error=access_denied&error_description=The+resource+owner+or+authorization+server+denied+the+request
- (void) handleURL:(NSURL*)url{
    
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

    NeatoHTTPSessionManager *manager = [NeatoHTTPSessionManager authenticatedBeehiveManager];
    
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

- (NSURL*) buildAuthorizationURL{
    NSString *parametersString = [NSString stringWithFormat:@"client_id=%@&redirect_uri=%@&scope=%@&response_type=token",
                            self.clientID,
                            self.redirectURI,
                            NeatoOAuthScopeControlRobots];
    
    NSString *urlPath = [kNeatoOAuthLoginEndPoint stringByAppendingString:parametersString];
    return [NSURL URLWithString:urlPath];
}

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

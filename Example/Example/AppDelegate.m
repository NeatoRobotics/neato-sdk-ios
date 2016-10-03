//
//  AppDelegate.m
//  Example
//
//  Created by Yari D'areglia on 22/04/16.
//  2016 Neato Robotics.
//

#import "AppDelegate.h"

@import NeatoSDK;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [NeatoAuthentication configureWithClientID:@"71511e87da9aa6e42e7f350bdd74385effea087b64ab65d682fd0b683b9cfdca"
                                scopes:@[NeatoOAuthScopeControlRobots, NeatoOAuthScopePublicProfile]
                           redirectURI:@"neato-mobile-demo://demo"];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    // Handle redirect after OAuth login completes.
    // Remember to set the URL schema for your project!
    [[NeatoAuthentication sharedInstance] handleURL:url];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

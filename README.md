[![Build Status](https://magnum.travis-ci.com/NeatoRobotics/neato-sdk-ios.svg?token=qhAJEiMuuszAF4XdspZf&branch=master)](https://magnum.travis-ci.com/NeatoRobotics/neato-sdk.ios)


#Neato SDK - iOS

This is the official iOS SDK for the Neato API services.
Importing the Neato SDK in your projects you can easily implement applications that communicate with Neato robots.

## Installation

### With CocoaPods

The NeatoSDK is available on [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod "NeatoSDK"
```

### With Carthage

To integrate the NeatoSDK into your Xcode project using Carthage, specify it in your Cartfile:

```
github "NeatoRobotics/NeatoSDK" ~> 1.0
```
## Usage
The Neato SDK has 3 main roles:
1. Handling OAuth authentications.
2. Simplifying access to users info.
3. Managing communication with Robots.

These tasks are handled by 3 different classes: `NeatoAuthentication`, `NeatoRobot` and `NeatoUser`

### Authentication
The Neato SDK leverages on OAuth 2 to perform user authentication. The `NeatoAuthentication` class gives you all the needed means to easily perform a login through your apps. Let’s go through the steps needed to setup an iOS App and achieve a user authentication.

#### 1. Creating a Schema URL
During the registration of your Neato App on the Neato Developer Portal you have defined a `Redirect URI`. This is the URL where we redirect a user that completes a login with your Neato App Client ID. You iOS App must be able to handle this Redirect URI thanks to a dedicated `Schema URL`. To register it you can click on your app target on Xcode, select the `info` tab a under `URL types` add a new URL that must be equal to your Redirect URI. We suggest to use something specific and unique like `MyCompanyNeatoCommander://` to avoid interferences with other applications that might have registered the same URL.

#### 2. Configuring the Authentication class
Just call the configuration method in the `application:didFinishLaunchingWithOptions` function of the `AppDelegate`, specifying your client ID, the scopes and the redirect URI.

```objective-c
[NeatoAuthentication configureWithClientID:@"YOUR_CLIENT_ID"
                   scopes:@[NeatoOAuthScopeControlRobots]
              redirectURI:@“MyCompanyNeatoCommander://neato"];
```

#### 3. Showing the Login page
You can choose when to present a login page to your users. The easiest way to go is to call the `openLoginInBrowser` function on an instance of `NeatoAuthentication` (This class is implemented as singleton, so you can easily access its shared instance):

```objective-c
[[NeatoAuthentication sharedInstance] openLoginInBrowserWithCompletion:^(NSError *error) {
	if(error == nil){
    // The user is logged! do something here
	}else{
    // oh… no :(
	}
}];
```
The user will be presented with a login page (on Safari) and when it completes the login it will be redirect to your App thanks to the `URL Schema` previously defined.

A slightly different way to present the login page is via `presentLoginControllerWithCompletion`. This method pushes a new view controller into your app hierarchy. The presented controller is an instance of `SFSafariViewController` that loads and presents the Neato Login page. The advantage of using this method is that your users don’t have to leave the App to perform the login.

```
[[NeatoAuthentication sharedInstance] presentLoginControllerWithCompletion:^(NSError * _Nullable error) {
	  if(error == nil){
      // The user is logged! do something here
	  }else{
      // oh… no :(
	}
}];
```

#### 4. Handling the Redirect URI
Now that the user has been redirected to the app there is one last thing to do: Retrieving the generated `access token`.
This is extremely simple actually since the `NeatoAuthentication` class will handle it for you. Just call the `handleURL` function inside `application:(UIApplication *)application handleOpenURL:(NSURL *)url` of the `AppDelegate` and pass the url received:

```objective-c
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {

    [[NeatoAuthentication sharedInstance] handleURL:url];
    return YES;
}
```

### Working with Users
Now your users can perform authentication and you can get  information about them.

With a `NeatoUser` instance you can easily access the robot list for the currently logged in user.

```objective-c
NeatoUser *user = [NeatoUser new];
[user getRobotsWithCompletion:^(NSArray<NeatoRobot*> *robots, NSError * _Nonnull error) {

  if(error == nil){
		// do something with robots array
	}
}];
```

and accessing user’s info:

```objective-c
[user getUserInfo:^(NSDictionary* userinfo, NSError * _Nullable error) {

  if(!error){
		NSLog(@"%@ %@ %@",
       userinfo[@"first_name"], 
       userinfo[@"last_name"], 
       userinfo[@"email"]
    );
	}
}];
```

### Communicating with Robots
Now that you have the robots for an authenticated user it’s time to communicate with them.
In the previous call you've seen how easy is to retrieve `NeatoRobot` instances for your current user. Those instances are ready to receive messages from your iOS App, obviously a robot must be online to receive a message.

#### The robot status
Each robot has a specific status that can be easily obtained using the function `updateState`. When the functions completes, the robot instance properties will be filled with the current robot status, if the robot is currently offline you'll get an error with code `404`.

```objective-c
- (void)updateRobotState{
    [self.robot updateStateWithCompletion:^(NSError * _Nonnull error) {

		if(error){
      // robot is offline
		}else{
      // Now you can read updated robot.state and robot.action… and many other robot properties.
      // As example:  if the robot has correctly received the cleanHouse command, `robot.action` will be `2` and `robot.state` will be `2`
		}
	}];
}
```

__Important Note:__ An instance of the `NeatoRobot` class doesn't update its state automatically. To get the updated robot state you need to call `updateStateWithCompletion` anytime you want to refresh the state of robot instance. 
The robot state is automatically updated when some specific commands completes (to get the list of this commands check the API documentation for the commands that respond with a __State Responses__. Some examples of those commands are `startCleaning`, stopCleaning` and `pauseCleaning`).

#### Sending commands to a Robot
An online robot is ready to receives commands like `start cleaning`:

```objective-c
[self.robot startCleaningWithParameters:@{
  @"category":@(RobotCleaningCategoryHouse),
  @"modifier":@(RobotCleaningModifierNormal),
  @"mode":@(RobotCleaningModeTurbo)}

  completion:^(NSError * _Nullable error) {
		if(!error){
			// Robot is cleaning!
			// now its state is “busy” and its action “cleaning house”
		}
}];
```

Within the completion block of a command that changes the robot status (like `start cleaning`) the updated robot status is immediately available. Accessing robot properties from there you can be sure that you are working with the most recent robot status.
Example: You call `pause cleaning` on a robot that has a state equal to`Busy` and `House Cleaning` as action. Inside the completion block of `pause cleaning` (if the call succeeds without errors) robot.state will be now equal to “Paused” and robot.action to “House Cleaning”.

#### Available commands
When you ask to update robot state through the `updateStateWithCompletion` function you also update the available commands list for the current robot state. These commands are `start`, `stop`, `pause`, `resume` and `goToBase` and they are listed under the `availableCommands` property (`NSDictionary`) of each `NeatoRobot` instance.
You can leverage on this elements to show or hide buttons in your user interface. As example, when the robot is cleaning, `availableCommands` is equal to: 

``` json
	“start”: 0,
	“stop”: 1,
	“pause”: 1, 
	“resume”: 0, 
	“goToBase”: 0
```
In this case, you might want to enable “stop” and “pause” buttons and disable “start” on your user interface.


#### Robot Services 
To identify the services available for a robot you can rely on the `availableServices` property returned by a `getRobotState` call. 

``` JSON
    “availableServices”:{
        “houseCleaning”: “basic-1”,
        “manualCleaning”: “basic-1”,
        “spotCleaning”: “basic-1”,
        “easyConnect”: “basic-1”,
        “schedule”: “basic-1”,
        “softwareUpdate”: “basic-1”,
        “findMe”:”basic-1”,
        “localStats”:”advanced-1”
    }
```

A `service` might have one or more versions. Take `houseCleaning` as example: this service supports 3 different versions, `minimal-1`, `basic-1` and `basic-2`. In turn each version might have completely different functions, or functions that require different parameters.
You can read more about `houseCleaning` service here (__LINK NEEDED__). 

Before sending a command to a robot you should verify the robot supports that command and, depending on the service supported, you decide which function to call and white which parameters. 











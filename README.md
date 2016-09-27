[![Build Status](https://magnum.travis-ci.com/NeatoRobotics/neato-sdk-ios.svg?token=qhAJEiMuuszAF4XdspZf&branch=master)](https://magnum.travis-ci.com/NeatoRobotics/neato-sdk-ios)

# Neato SDK - iOS
The official iOS SDK (Beta release) for the Neato API services can be found at this [link](https://github.com/NeatoRobotics/neato-sdk-ios).
The Neato iOS SDK enables iOS apps to easily communicate with Neato connected robots and use its various features.

To boost your development, you can also check the *sample application*.

> This is a beta version. It is subject to change without prior notice.

## Preconditions

 - Create the Neato user account via the Neato portal or from the official Neato App
 - Link the robot to the user account via the official Neato App

## Installation

### With Carthage

To integrate the NeatoSDK into your Xcode project using Carthage, specify it in your Cartfile:

```
github "NeatoRobotics/NeatoSDK" ~> 1.0
```

### Manually

Drag and drop the whole "NeatoSDK" folder into your Xcode project (remove the info.plist file).

## Usage

The Neato SDK has 3 main roles:
1. Handling OAuth authentications
2. Simplifying access to users info
3. Managing communication with Robots

These tasks are handled by 3 different classes: `NeatoAuthentication`, `NeatoRobot` and `NeatoUser`

### Authentication

The Neato SDK leverages on OAuth 2 to perform user authentication. The `NeatoAuthentication` class gives you all the needed means to easily perform a login through your apps. Let’s go through the steps needed to setup an iOS App and complete a user authentication.

#### 1. Creating a Schema URL

During the registration of your Neato App on the Neato Developer Portal you have defined a `Redirect URI`. This is the URL where we redirect a user that completes a login with your Neato App Client ID. Your iOS App must be able to handle this Redirect URI using a dedicated `Schema URL`. To register it, you can click on your app target on Xcode, select the `info` tab under `URL types`, and add a new URL that must be equal to your Redirect URI. We suggest to use something specific and unique like `MyCompanyNeatoCommander://` to avoid conflicts with other applications that might have registered the same URL.

#### 2. Configuring the Authentication class

Just call the configuration method in the `application:didFinishLaunchingWithOptions` function of your `AppDelegate`, specifying the client ID, the scopes and the redirect URI.

```objective-c
[NeatoAuthentication configureWithClientID:@"YOUR_CLIENT_ID"
                   scopes:@[NeatoOAuthScopeControlRobots]
              redirectURI:@"MyCompanyNeatoCommander://neato"];
```

#### 3. Showing the Login page

You can choose when to present a login page to your users. The easiest way is to call the `openLoginInBrowser` function from an instance of `NeatoAuthentication` (This class is implemented as singleton, so you can easily access its shared instance):

```objective-c
[[NeatoAuthentication sharedInstance] openLoginInBrowserWithCompletion:^(NSError *error) {
	if(error == nil){
    // The user is logged! do something here
	}else{
    // oh… no :(
	}
}];
```
The user will be presented with a login page (on Safari) and when it completes the login, it will redirect to your App thanks to the `URL Schema` previously defined.

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

In case you prefer to write your custom authentication flow, you can obtain the authentication URL calling the `authenticationURL` method of a `NeatoAuthentication` instance.

#### 4. Handling the Redirect URI

Now that the user has been redirected to the app, there is one last thing to do: Retrieving the generated `access token`.
This is extremely simple since the `NeatoAuthentication` class will handle it for you. Just call the `handleURL` function inside `application:(UIApplication *)application handleOpenURL:(NSURL *)url` of the `AppDelegate` and pass the url received:

```objective-c
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {

    [[NeatoAuthentication sharedInstance] handleURL:url];
    return YES;
}
```

### Working with Users

Now your users can perform authentication and you can get information about them.

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
A new `NeatoUser` doesn't need any configuration to be used. The authentication information will be automatically retrieved from the `NeatoAuthentication` class. The only constraint before using a ` NeatoUser` is that a user has already completed the login process previously described.

### Communicating with Robots

Now that you have the robots for an authenticated user it’s time to communicate with them.
In the previous call, you've seen how easy it is to retrieve `NeatoRobot` instances for your current user. Those instances are ready to receive messages from your iOS App, obviously a robot must be online to receive a message.

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

__Important Note:__ An instance of the `NeatoRobot` class doesn't update its state automatically. To get the updated robot state you need to call `updateStateWithCompletion` anytime you want to refresh the state of a robot instance.
The robot state is automatically updated when some specific command completes (to get the list of commands, check the API documentation for the commands that respond with __State Responses__. Some examples of those commands are `startCleaning`, `stopCleaning` and `pauseCleaning`).

#### Sending commands to a Robot
An online robot is ready to receive commands like `startCleaning`:

```objective-c
[self.robot startCleaningWithParameters:@{
  @"category":@(RobotCleaningCategoryHouse),
  @"modifier":@(RobotCleaningModifierNormal),
  @"mode":@(RobotCleaningModeTurbo)}

  completion:^(NSError * _Nullable error) {
		if(!error){
			// Robot is cleaning!
			// now its state is "busy" and its action "cleaning house"
		}
}];
```

The  robot status is immediately available within the completion block of a command like `startCleaning`. Accessing robot properties from there, you are sure to have the most recent robot status.
Example: You call `pauseCleaning` on a robot that has a state equal to`Busy` and `House Cleaning` as action. Inside the completion block of `pauseCleaning` (if the call succeeds without errors) `robot.state` will now be equal to "Paused" and `robot.action` to `House Cleaning`.

#### Available commands

When you ask to update robot state through the `updateStateWithCompletion` function you also update the available commands list for the current robot state. These commands are `start`, `stop`, `pause`, `resume` and `goToBase` and they are listed under the `availableCommands` property (`NSDictionary`) of each `NeatoRobot` instance.
You can leverage on these elements to show or hide buttons in your user interface. As example, when the robot is cleaning, `availableCommands` is equal to:

```json
	"start": 0,
	"stop": 1,
	"pause": 1,
	"resume": 0,
	"goToBase": 0
```
In this case, you might want to enable "stop" and "pause" buttons and disable "start" on your user interface as the robot is already cleaning.


#### Robot Services

To identify the services available for a robot you can rely on the `availableServices` property returned by a `getRobotState` call.

```json
    "availableServices":{
        "houseCleaning": "basic-1",
        "manualCleaning": "basic-1",
        "spotCleaning": "basic-1",
        "easyConnect": "basic-1",
        "schedule": "basic-1",
    }
```

A `service` might have one or more versions. Take `houseCleaning` as example: this service supports 3 different versions, `basic-1`, `minimal-2` and `basic-2`. Each version might have completely different functions, or functions that require different parameters. You can read more about `houseCleaning` service [here](https://developers.neatorobotics.com/api/robot-remote-protocol/housecleaning).

Before sending a command to a robot you should verify the robot supports that command and, depending on the service supported, you decide which function to call and with which parameters.


## Compile the SDK

The NeatoSDK uses Carthage to handle some dependencies.

Currently we are adopting `specta/expecta` and `OHTTPStubs` to write all the SDK tests. Those libraries are not included into the repository, hence you cannot download the SDK source and just compile but you have to pull and compile the missing frameworks.
The fastest way to go is to move into the project folder from terminal and launch the Carthage bootstrap command:

```
carthage bootstrap —use-submodules
```
This command will read the latest resolved frameworks version (you can check them into the cartfile.resolved), pull and compile the needed builds. Now you can compile and test the SDK.







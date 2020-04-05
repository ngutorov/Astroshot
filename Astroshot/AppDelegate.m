//
//  AppDelegate.m
//  Astroshot
//
//  Created by Nikolay Gutorov on 2/15/19.
//  Copyright © 2019 Nikolay Gutorov. All rights reserved.
//

#import "AppDelegate.h"
#import "GameViewController.h"

@implementation AppDelegate

GameViewController *viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    application.statusBarHidden = YES;
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    
    // Main game ViewController.
    viewController = [[GameViewController alloc] init];
    viewController.view.frame = screenFrame;
    
    // Main game UIWindow.
    self.window = [[UIWindow alloc] initWithFrame: screenFrame];
    self.window.backgroundColor = [UIColor blackColor];
    self.window.rootViewController = viewController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Pause the game for inactive mode.
    viewController.startScene.paused = YES;
}

@end

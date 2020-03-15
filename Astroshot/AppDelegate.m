//
//  AppDelegate.m
//  Astroshot
//
//  Created by Nikolay Gutorov on 2/15/19.
//  Copyright © 2019 Nikolay Gutorov. All rights reserved.
//

#import "AppDelegate.h"
#import "MainScene.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

MainScene *startScene;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    application.statusBarHidden = YES;
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    
    UIViewController *_viewController = [[UIViewController alloc] init];
    _viewController.view = [[UIView alloc] initWithFrame:screenFrame];
    
    SKView *startView = [[SKView alloc] initWithFrame:screenFrame];
    startView.showsFPS = YES;
    
    startScene = [[MainScene alloc] initWithSize:screenFrame.size];
    startScene.scaleMode = SKSceneScaleModeAspectFit;
    startScene.backgroundColor = [UIColor blackColor];
    
    [_viewController.view addSubview:startView];
    [startView presentScene:startScene];
    
    self.window = [[UIWindow alloc] initWithFrame:screenFrame];
    self.window.backgroundColor = [UIColor blackColor];
    self.window.rootViewController = _viewController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    startScene.paused = YES;
}

@end

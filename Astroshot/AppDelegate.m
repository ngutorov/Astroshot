//
//  AppDelegate.m
//  Astroshot
//
//  Created by Nikolay Gutorov on 2/15/19.
//  Copyright © 2019 Nikolay Gutorov. All rights reserved.
//

#import "AppDelegate.h"
#import "MyScene.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    
    UIViewController *_viewController = [[UIViewController alloc] init];
    _viewController.view = [[UIView alloc] initWithFrame:screenFrame];
    
    SKView *startView = [[SKView alloc] initWithFrame:screenFrame];
    startView.showsFPS = YES;
    startView.showsNodeCount = YES;
    
    SKScene *startScene = [[MyScene alloc] initWithSize:startView.bounds.size];
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
    
    SKView *view = (SKView*)self.window.rootViewController.view;
    ((MyScene*)view.scene).gamePaused = YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

@end

//
//  GameViewController.m
//  Astroshot
//
//  Created by Nikolay Gutorov on 4/3/20.
//  Copyright © 2020 Nikolay Gutorov. All rights reserved.
//

#import "GameViewController.h"

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    SKView *startView = [[SKView alloc] initWithFrame: self.view.frame];
    
    _startScene = [[MainScene alloc] initWithSize: self.view.frame.size];
    _startScene.scaleMode = SKSceneScaleModeResizeFill;
    _startScene.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:startView];
    [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    [startView presentScene:_startScene];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

@end

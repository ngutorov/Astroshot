//
//  GameScene.m
//  Astroshot
//
//  Created by Nikolay Gutorov on 2/15/19.
//  Copyright © 2019 Nikolay Gutorov. All rights reserved.
//

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#import <SpriteKit/SpriteKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MainScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic) int ammo;
@property (nonatomic) int score;
@property (nonatomic) BOOL gamePaused;

-(void)setGamePaused:(BOOL)gamePaused;

@end

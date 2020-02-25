//
//  Ball.h
//  Astroshot
//
//  Created by Nikolay Gutorov on 2/15/19.
//  Copyright © 2019 Nikolay Gutorov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface Ball : SKSpriteNode


@property (nonatomic) SKEmitterNode *trail;
@property (nonatomic) int bounces;

-(void)updateTrail;


@end

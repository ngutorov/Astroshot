//
//  CannonBall.h
//  Astroshot
//
//  Created by Nikolay Gutorov on 3/22/20.
//  Copyright © 2020 Nikolay Gutorov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface CannonBall : SKSpriteNode

@property (nonatomic) SKEmitterNode *trail;
@property (nonatomic) int bounces;

-(void)updateTrail;

@end

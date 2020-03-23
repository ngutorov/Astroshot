//
//  CannonBall.m
//  Astroshot
//
//  Created by Nikolay Gutorov on 3/22/20.
//  Copyright © 2020 Nikolay Gutorov. All rights reserved.
//

#import "CannonBall.h"

@implementation CannonBall

-(void)updateTrail {
    
    if (self.trail) {
        self.trail.position = self.position;
    }
}

-(void)removeFromParent {
    
    if (self.trail) {
        self.trail.particleBirthRate = 0.0;
        
        SKAction *removeTrail = [SKAction sequence:@[[SKAction waitForDuration:self.trail.particleLifetime + self.trail.particleLifetimeRange], [SKAction removeFromParent]]];
                                 
        [self runAction:removeTrail];
    }
    
    [super removeFromParent];
}

@end

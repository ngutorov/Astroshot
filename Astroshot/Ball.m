//
//  Ball.m
//  Astroshot
//
//  Created by Nikolay Gutorov on 2/15/19.
//  Copyright © 2019 Nikolay Gutorov. All rights reserved.
//

#import "Ball.h"


@implementation Ball


-(void)updateTrail
{
    if (self.trail) {
        self.trail.position = self.position;
    }
    
}


-(void)removeFromParent {
    
    if (self.trail) {
        self.trail.particleBirthRate = 0.0;
        
        [self performSelector:@selector(removeTrail) withObject:self afterDelay:self.trail.particleLifetime
         + self.trail.particleLifetimeRange];
        
    }
    
    [super removeFromParent];
}


-(void)removeTrail {
    [_trail removeFromParent];
}


@end

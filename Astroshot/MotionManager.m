//
//  MotionManager.m
//  Astroshot
//
//  Created by Nikolay Gutorov on 2/25/20.
//  Copyright © 2020 Nikolay Gutorov. All rights reserved.
//

#import "MotionManager.h"

@implementation MotionManager {
        
}

+ (id) sharedManager {
    static dispatch_once_t pred = 0;
    static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(void)startDeviceMitionForObject:(SKSpriteNode*)object {
    
    // Add gyro control of cannon.
    [_manager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical toQueue:_queue withHandler:^(CMDeviceMotion *motion, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            CGFloat x = motion.gravity.x;
            CGFloat y = motion.gravity.y * 0.75;
            CGFloat realAngle = atan2(x, y);
            CGFloat angle = realAngle + M_PI;
            if (realAngle < -M_PI_2 || realAngle > M_PI_2)
            {
                self->_rotateObject = [SKAction rotateToAngle:angle duration:0];
                [object runAction:self->_rotateObject];
            }
        }];
    }];
}

-(void)stopDeviceMotion {
    [_manager stopDeviceMotionUpdates];
    [_queue cancelAllOperations];
    [[NSOperationQueue mainQueue] cancelAllOperations];
}

@end

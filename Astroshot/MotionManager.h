//
//  MotionManager.h
//  Astroshot
//
//  Created by Nikolay Gutorov on 2/25/20.
//  Copyright © 2020 Nikolay Gutorov. All rights reserved.
//

#define SINGLETON_FOR_CLASS(MotionManager)

#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreMotion/CoreMotion.h>
#import <SpriteKit/SpriteKit.h>

@interface MotionManager : NSObject

@property (strong,nonatomic) CMMotionManager *manager;
@property (strong,nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) SKAction *rotateObject;

+ (id) sharedManager;

-(void)startDeviceMitionForObject:(SKSpriteNode*)object;
-(void)stopDeviceMotion;

@end





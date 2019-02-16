
#import <SpriteKit/SpriteKit.h>
#import <CoreMotion/CoreMotion.h>


@interface MyScene : SKScene <SKPhysicsContactDelegate>


@property (nonatomic) int ammo;
@property (nonatomic) int score;
@property (nonatomic) int friendsSaved;
@property (nonatomic) BOOL multiMode;
@property (nonatomic) BOOL gamePaused;

@property (strong,nonatomic) CMMotionManager *motionManager;
@property (strong,nonatomic) NSOperationQueue *motionQueue;


@end

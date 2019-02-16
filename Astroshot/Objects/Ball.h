
#import <SpriteKit/SpriteKit.h>


@interface Ball : SKSpriteNode


@property (nonatomic) SKEmitterNode *trail;
@property (nonatomic) int bounces;

-(void)updateTrail;


@end

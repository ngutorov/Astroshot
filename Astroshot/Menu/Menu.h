
#import <SpriteKit/SpriteKit.h>


@interface Menu : SKNode


@property (nonatomic) int score;
@property (nonatomic) int topScore;
@property (nonatomic) BOOL touchable;

-(void)hide;
-(void)show;


@end

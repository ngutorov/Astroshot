//
//  Menu.m
//  Astroshot
//
//  Created by Nikolay Gutorov on 2/15/19.
//  Copyright © 2019 Nikolay Gutorov. All rights reserved.
//

#import "MainMenu.h"

@implementation MainMenu {
    
    SKLabelNode *_scoreLabel;
    SKLabelNode *_topScoreLabel;
    SKLabelNode *_controlHintLabel;
    
    SKSpriteNode *_title;
    SKSpriteNode *_scoreBoard;
    SKSpriteNode *_playButton;
    SKSpriteNode *_controlHint;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _title = [SKSpriteNode spriteNodeWithImageNamed:@"Title"];
        _title.position = CGPointMake(0, 25);
        [self addChild:_title];
        
        _scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"ScoreBoard"];
        _scoreBoard.position = CGPointMake(0, -90);
        [self addChild:_scoreBoard];
        
        _playButton = [SKSpriteNode spriteNodeWithImageNamed:@"PlayButton"];
        _playButton.name = @"Play";
        _playButton.position = CGPointMake(0, -200);
        [self addChild:_playButton];
        
        _controlHint = [SKSpriteNode spriteNodeWithImageNamed:@"ControlHint"];
        _controlHint.position = CGPointMake(0, -315);
        [self addChild:_controlHint];
        
        _controlHintLabel = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
        _controlHintLabel.fontSize = 15;
        _controlHintLabel.position = CGPointMake(0, -325);
        _controlHintLabel.text = @"ROTATE DEVICE TO CONTROL";
        [_scoreBoard addChild:_controlHintLabel];
        
        // Create bounce action for play button.
        SKAction *bouncePlayButton = [SKAction sequence:@[[SKAction resizeByWidth:-30 height:-10 duration:0.35],
                                                          [SKAction resizeByWidth:30 height:10 duration:0.35]]];
        
        // Create rotation action for "motion control hint" sprite.
        SKAction *rotateControlHint = [SKAction sequence:@[[SKAction rotateByAngle:M_PI/4 duration:1],
                                                           [SKAction rotateByAngle:-M_PI/2 duration:1],
                                                           [SKAction rotateByAngle:M_PI/4 duration:1]]];
        
        // Run rotation and bounce actions.
        [_controlHint runAction:[SKAction repeatAction:rotateControlHint count:1] completion:^{
            [self->_playButton runAction:[SKAction repeatActionForever:bouncePlayButton]];
        }];
        
        self.score = 0;
        self.topScore = 0;
        self.touchable = YES;
    }
    
    return self;
}

-(void)hide {
    self.touchable = NO;
    
    SKAction *animateMenu = [SKAction scaleTo:0.0 duration:0.25];
    animateMenu.timingMode = SKActionTimingEaseIn;
    [self runAction:animateMenu completion:^{
        self.hidden = YES;
        self.xScale = 1.0;
        self.yScale = 1.0;
    }];
}

-(void)show {
    self.hidden = NO;
    self.touchable = NO;
    
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.5];
    
    _title.position = CGPointMake(0, 280);
    _title.alpha = 0;
    SKAction *animateTitle = [SKAction group:@[[SKAction moveToY:140 duration:0.5], fadeIn]];
    animateTitle.timingMode = SKActionTimingEaseOut;
    [_title runAction:animateTitle];
    
    _scoreBoard.xScale = 4.0;
    _scoreBoard.yScale = 4.0;
    _scoreBoard.alpha = 0;
    SKAction *animateScoreBoard = [SKAction group:@[[SKAction scaleTo:1.0 duration:0.5], fadeIn]];
    animateScoreBoard.timingMode = SKActionTimingEaseOut;
    [_scoreBoard runAction:animateScoreBoard];
    
    _playButton.alpha = 0;
    SKAction *animatePlayButton = [SKAction fadeInWithDuration:2.0];
    animatePlayButton.timingMode = SKActionTimingEaseIn;
    [_playButton runAction:animatePlayButton completion:^{
        self.touchable = YES;
    }];
}

-(void)setScore:(int)score {
    [_scoreBoard removeChildrenInArray:[[NSArray alloc] initWithObjects:_scoreLabel, nil]];
    _score = score;
    _scoreLabel = [self makeDropShadowString:[[NSNumber numberWithInt:score] stringValue]
                                    position:CGPointMake(-70, -23)];
    [_scoreBoard addChild:_scoreLabel];
}

-(void)setTopScore:(int)topScore {
    [_scoreBoard removeChildrenInArray:[[NSArray alloc] initWithObjects:_topScoreLabel, nil]];
    _topScore = topScore;
    _topScoreLabel = [self makeDropShadowString:[[NSNumber numberWithInt:topScore] stringValue]
                                       position:CGPointMake(65, -23)];
    [_scoreBoard addChild:_topScoreLabel];
}

// MARK: - Helpers

- (SKLabelNode *) makeDropShadowString:(NSString *) text
                              position: (CGPoint) position {
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text
                                                                           attributes:@{
        NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:28],
        NSStrokeWidthAttributeName: @-6.0,
        NSStrokeColorAttributeName:[UIColor colorWithRed: 235/255.0 green: 38/255.0 blue: 39/255.0 alpha:1.000],
        NSForegroundColorAttributeName:[UIColor whiteColor]
    }];
    
    SKLabelNode *dropShadow = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Bold"];
    dropShadow.attributedText = attributedString;
    dropShadow.position = position;
    
    return dropShadow;
}

@end

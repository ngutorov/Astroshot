//
//  Menu.h
//  Astroshot
//
//  Created by Nikolay Gutorov on 2/15/19.
//  Copyright © 2019 Nikolay Gutorov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MainMenu : SKNode

@property (nonatomic) int score;
@property (nonatomic) int topScore;
@property (nonatomic) BOOL touchable;

-(void)hide;
-(void)show;

@end

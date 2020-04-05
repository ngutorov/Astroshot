//
//  GameViewController.h
//  Astroshot
//
//  Created by Nikolay Gutorov on 4/3/20.
//  Copyright © 2020 Nikolay Gutorov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Scenes/MainScene.h"

@interface GameViewController : UIViewController

// Main game SKScene.
@property (nonatomic) MainScene *startScene;

@end

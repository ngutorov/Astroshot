//
//  GameScene.m
//  Astroshot
//
//  Created by Nikolay Gutorov on 2/15/19.
//  Copyright © 2019 Nikolay Gutorov. All rights reserved.
//

#import "MyScene.h"
#import "Menu.h"
#import "Ball.h"


@implementation MyScene {
    
    SKNode *_mainLayer;
    Menu *_menu;
    SKSpriteNode *_ammoDisplay;
    SKSpriteNode *_pauseButton;
    SKSpriteNode *_resumeButton;
    SKLabelNode *_scoreLabel;
    SKLabelNode *_friendLabel;
    BOOL _didShoot;
    int _killCount;
    SKAction *_bounceSound;
    SKAction *_deepExplosionSound;
    SKAction *_explosionSound;
    SKAction *_laserSound;
    SKAction *_zapSound;
    SKAction *_shieldUpSound;
    BOOL _gameOver;
    NSUserDefaults *_userDefaults;
    NSMutableArray *_shieldPool;
    SKSpriteNode *_cannon;
    
}


static const CGFloat SHOOT_SPEED = 1000.0f;
static const CGFloat kCCHaloLowAngle = 200.0 * M_PI / 180.0;
static const CGFloat kCCHaloHighAngle = 340.0 * M_PI / 180.0;
static const CGFloat kCCHaloSpeed = 100.0;

static const uint32_t kCCHaloCategory = 0x1 << 0;
static const uint32_t kCCHaloFriend = 0x1 << 1;
static const uint32_t kCCBallCategory = 0x1 << 2;
static const uint32_t kCCEdgesCategory = 0x1 << 3;
static const uint32_t kCCShieldCategory = 0x1 << 4;
static const uint32_t kCCLifeBarCategory = 0x1 << 5;
static const uint32_t kCCShieldUpCategory = 0x1 << 6;
static const uint32_t kCCMultiUpCategory = 0x1 << 7;

static NSString * const kCCKeyTopScore = @"TopScore";

static inline CGVector radiansToVector(CGFloat radians) {
    CGVector vector;
    vector.dx = cosf(radians);
    vector.dy = sinf(radians);
    return vector;
}

static inline CGFloat randomInRange(CGFloat low, CGFloat high) {
    CGFloat value = arc4random_uniform(UINT32_MAX) / (CGFloat)UINT32_MAX;
    return value * (high - low) +low;
}


-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        
        // Set up motion manager.
        _motionManager = [[CMMotionManager alloc] init];
        _motionQueue = [[NSOperationQueue alloc] init];
        //_motionManager.showsDeviceMovementDisplay = YES;
        _motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
        
        
        
        // Turn off gravity.
        self.physicsWorld.gravity = CGVectorMake(0.0, -0.01);
        self.physicsWorld.contactDelegate = self;
        
        /* Setup your scene here */
        
        
        // Add background.
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
        background.position = CGPointZero;
        background.anchorPoint = CGPointZero;
        background.size = CGSizeMake(self.size.width, self.size.height);
        background.blendMode = SKBlendModeReplace;
        [self addChild:background];
        
        // Add edges.
        SKNode *leftEdge = [[SKNode alloc] init];
        leftEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0.0, self.size.height + 100)];
        leftEdge.position = CGPointZero;
        leftEdge.physicsBody.categoryBitMask = kCCEdgesCategory;
        [self addChild:leftEdge];
        
        SKNode *rightEdge = [[SKNode alloc] init];
        rightEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0.0, self.size.height + 100)];
        rightEdge.position = CGPointMake(self.size.width, 0.0);
        rightEdge.physicsBody.categoryBitMask = kCCEdgesCategory;
        
        [self addChild:rightEdge];
        
        // Add main layer.
        _mainLayer = [[SKNode alloc] init];
        [self addChild:_mainLayer];
        
        
        // Add cannon.
        _cannon = [SKSpriteNode spriteNodeWithImageNamed:@"BigGun"];
        _cannon.position = CGPointMake(self.size.width * 0.5, 0.0);
        [self addChild:_cannon];
        
        
        // Create spawn halo action.
        SKAction *spawnHalo = [SKAction sequence:@[[SKAction waitForDuration:2 withRange:1],
                                                   [SKAction performSelector:@selector(spawnHalo) onTarget:self]]];
        [self runAction:[SKAction repeatActionForever:spawnHalo] withKey:@"SpawnHalo"];
        
        // Create spawn shield power up action.
        SKAction *spawnShieldPowerUp = [SKAction sequence:@[[SKAction waitForDuration:15 withRange:4],
                                                            [SKAction performSelector:@selector(spawnShieldPowerUp) onTarget:self]]];
        [self runAction: [SKAction repeatActionForever:spawnShieldPowerUp]];
        
        // Setup Ammo.
        _ammoDisplay = [SKSpriteNode spriteNodeWithImageNamed:@"Ammo5"];
        _ammoDisplay.anchorPoint = CGPointMake(0.5, 0.0);
        _ammoDisplay.position = _cannon.position;
        [self addChild:_ammoDisplay];
        self.ammo = 5;
        
        SKAction *incrementAmmo = [SKAction sequence:@[[SKAction waitForDuration:1],
                                                       [SKAction runBlock:^{
            if (!self.multiMode) {
                self.ammo++;
            }
        }]]];
        [self runAction:[SKAction repeatActionForever:incrementAmmo]];
        
        // Setup shield pool
        _shieldPool = [[NSMutableArray alloc] init];
        
        // Setup shields.
        for (int i=0; i< 7; i++) {
            SKSpriteNode *shield = [SKSpriteNode spriteNodeWithImageNamed:@"Block"];
            shield.size = CGSizeMake(50, 15);
            shield.name = @"shield";
            shield.position = CGPointMake(31 + (52 * i), 150);
            shield.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(50, 15)];
            shield.physicsBody.categoryBitMask = kCCShieldCategory;
            shield.physicsBody.collisionBitMask = 0;
            shield.physicsBody.affectedByGravity = NO;
            [_shieldPool addObject:shield];
            
        }
        
        // Setup pause button.
        _pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"PauseButton"];
        _pauseButton.position = CGPointMake(self.size.width - 30, 35);
        [self addChild:_pauseButton];
        
        //Setup resume button.
        _resumeButton = [SKSpriteNode spriteNodeWithImageNamed:@"ResumeButton"];
        _resumeButton.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
        [self addChild:_resumeButton];
        
        // Setup score display.
        _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
        _scoreLabel.position = CGPointMake(10, 12);
        _scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _scoreLabel.fontSize = 16;
        _scoreLabel.fontColor = [UIColor colorWithRed:0.471 green:0.831 blue:0.992 alpha:1];
        [self addChild:_scoreLabel];
        
        // Setup saved ships label.
        _friendLabel = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
        _friendLabel.position = CGPointMake(10, 35);
        _friendLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _friendLabel.fontSize = 16;
        _friendLabel.fontColor = [UIColor colorWithRed:0.471 green:0.831 blue:0.992 alpha:1];
        [self addChild:_friendLabel];
        
        // Setup sounds.
        _bounceSound = [SKAction playSoundFileNamed:@"Bounce.caf" waitForCompletion:NO];
        _deepExplosionSound = [SKAction playSoundFileNamed:@"DeepExplosion.caf" waitForCompletion:NO];
        _explosionSound = [SKAction playSoundFileNamed:@"Explosion.caf" waitForCompletion:NO];
        _laserSound = [SKAction playSoundFileNamed:@"Laser.caf" waitForCompletion:NO];
        _zapSound = [SKAction playSoundFileNamed:@"Zap.caf" waitForCompletion:NO];
        _shieldUpSound = [SKAction playSoundFileNamed:@"ShieldUp.caf" waitForCompletion:NO];
        
        // Setup menu.
        _menu = [[Menu alloc] init];
        _menu.position = CGPointMake(self.size.width * 0.5, self.size.height - 220);
        [self addChild:_menu];
        
        // Set initial values.
        self.ammo = 5;
        self.score = 0;
        self.friendsSaved = 0;
        _gameOver = YES;
        _scoreLabel.hidden = YES;
        _friendLabel.hidden = YES;
        _pauseButton.hidden = YES;
        _resumeButton.hidden = YES;
        
        // Load top score.
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _menu.topScore = [_userDefaults integerForKey:kCCKeyTopScore];
        
        
    }
    
    return self;
    
}


-(void)newGame {
    
    [_mainLayer removeAllChildren]; // to see the menu
    
    
    // Add all shields from pool to scene.
    while (_shieldPool.count > 0){
        [_mainLayer addChild:[_shieldPool objectAtIndex:0]];
        [_shieldPool removeObjectAtIndex:0];
    }
    
    if (_shieldPool.count == 0){
        
        
        // Setup life bar.
        SKSpriteNode *lifeBar = [SKSpriteNode spriteNodeWithImageNamed:@"BlueBar"];
        lifeBar.position = CGPointMake(self.size.width * 0.5, 128);
        lifeBar.size = CGSizeMake(self.size.width, 18);
        lifeBar.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(-lifeBar.size.width * 0.5, 0) toPoint:CGPointMake(lifeBar.size.width * 0.5, 0)];
        lifeBar.physicsBody.categoryBitMask = kCCLifeBarCategory;
        [_mainLayer addChild:lifeBar];
        
        // Set initial values.
        [self actionForKey:@"SpawnHalo"].speed = 1.0;
        self.score = 0;
        self.ammo = 5;
        self.friendsSaved = 0;
        _scoreLabel.hidden = NO;
        _friendLabel.hidden = NO;
        _pauseButton.hidden = NO;
        [_menu hide];
        _gameOver = NO;
        _killCount = 0;
        self.multiMode = NO;
        
        // Start motion detection
        [self startDeviceMition];
    }
    
}


-(void)setAmmo:(int)ammo {
    
    if (ammo >= 0 && ammo <= 5) {
        _ammo = ammo;
        _ammoDisplay.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Ammo%d", ammo]];
    }
    
}


-(void)setScore:(int)score {
    _score = score;
    _scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
}


-(void)setFriendsSaved:(int)friendsSaved {
    _friendsSaved = friendsSaved;
    _friendLabel.text = [NSString stringWithFormat:@"Capsules: %d", friendsSaved];
}


// Pause game.
-(void)setGamePaused:(BOOL)gamePaused {
    if (!_gameOver){
        _gamePaused = gamePaused;
        _pauseButton.hidden = gamePaused;
        _resumeButton.hidden = !gamePaused;
        self.paused = gamePaused;
    }
    
}


-(void)setMultiMode:(BOOL)multiMode {
    
    _multiMode = multiMode;
    if (multiMode) {
        _cannon.texture = [SKTexture textureWithImageNamed:@"BigGun"];
    } else {
        _cannon.texture = [SKTexture textureWithImageNamed:@"BigGun"];
    }
    
}


-(void)shoot {
    
    // Create ball node.
    Ball *ball = [Ball spriteNodeWithImageNamed:@"Ball"];
    ball.name = @"ball";
    CGVector rotaionVector = radiansToVector(_cannon.zRotation + M_PI/2);
    ball.position = CGPointMake(_cannon.position.x + (_cannon.size.width * 0.5 * rotaionVector.dx),
                                _cannon.position.y + (_cannon.size.height * 0.5 * rotaionVector.dy));
    [_mainLayer addChild:ball];
    
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:6.0];
    ball.physicsBody.velocity = CGVectorMake(rotaionVector.dx * SHOOT_SPEED, rotaionVector.dy * SHOOT_SPEED);
    ball.physicsBody.restitution = 1.0;
    ball.physicsBody.linearDamping = 0.0;
    ball.physicsBody.friction = 0.0;
    ball.physicsBody.categoryBitMask = kCCBallCategory;
    ball.physicsBody.collisionBitMask = kCCEdgesCategory;
    ball.physicsBody.contactTestBitMask = kCCEdgesCategory | kCCShieldUpCategory | kCCMultiUpCategory;
    
    [self runAction:_laserSound];
    
    
    
    // Create trail.
    NSString *ballTrailPath = [[NSBundle mainBundle] pathForResource:@"BallTrail" ofType:@"sks"];
    SKEmitterNode *ballTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:ballTrailPath];
    ballTrail.targetNode = _mainLayer;
    [_mainLayer addChild:ballTrail];
    ball.trail = ballTrail;
    [ball updateTrail];
    
    
    
}


-(void) spawnHalo {
    
    // Increase halo speed.
    SKAction *spawnHaloAction = [self actionForKey:@"SpawnHalo"];
    if (spawnHaloAction.speed < 2.5) {
        spawnHaloAction.speed += 0.025;
    }
    
    // Create halo node.
    SKSpriteNode *halo = [SKSpriteNode spriteNodeWithImageNamed:@"Asteroid"];
    halo.name = @"halo";
    halo.position = CGPointMake(randomInRange(halo.size.width * 0.5, self.size.width - (halo.size.width * 0.5)), self.size.height + (halo.size.height * 0.5));
    halo.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:halo.size.width * 0.5];
    CGVector direction = radiansToVector(randomInRange(kCCHaloLowAngle, kCCHaloHighAngle));
    halo.physicsBody.velocity = CGVectorMake(direction.dx * kCCHaloSpeed, direction.dy * kCCHaloSpeed);
    halo.physicsBody.linearDamping = 0.0;
    halo.physicsBody.friction = 0.1;
    halo.physicsBody.categoryBitMask = kCCHaloCategory;
    halo.physicsBody.collisionBitMask = kCCEdgesCategory | kCCHaloCategory | kCCHaloFriend;
    halo.physicsBody.contactTestBitMask = kCCBallCategory | kCCShieldCategory | kCCLifeBarCategory;
    halo.physicsBody.velocity = CGVectorMake(-100, randomInRange(-50, 50));
    halo.physicsBody.angularVelocity = M_PI_2;
    
    int haloCount = 0;
    for (SKNode *node in _mainLayer.children) {
        if ([node.name isEqualToString:@"halo"]) {
            haloCount++;
        }
    }
    
    if (haloCount == 4) {
        //Create a bomb.
        halo.texture = [SKTexture textureWithImageNamed:@"Nuke"];
        halo.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:27];
        halo.userData = [[NSMutableDictionary alloc] init];
        CGVector direction = radiansToVector(randomInRange(kCCHaloLowAngle, kCCHaloHighAngle));
        halo.physicsBody.velocity = CGVectorMake(direction.dx * kCCHaloSpeed, direction.dy * kCCHaloSpeed);
        halo.physicsBody.linearDamping = 0.0;
        halo.physicsBody.friction = 0.1;
        halo.physicsBody.categoryBitMask = kCCHaloCategory;
        halo.physicsBody.collisionBitMask = kCCEdgesCategory | kCCHaloCategory | kCCHaloFriend;
        halo.physicsBody.contactTestBitMask = kCCBallCategory | kCCShieldCategory | kCCLifeBarCategory;
        halo.physicsBody.velocity = CGVectorMake(-100, randomInRange(-50, 50));
        halo.physicsBody.angularVelocity = M_PI_2;
        [halo.userData setValue:@YES forKey:@"Bomb"];
        
    } else if (arc4random_uniform(6) == 0) {
        //Create a friend (capsule).
        halo.texture = [SKTexture textureWithImageNamed:@"Capsule"];
        halo.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(23, 20)];
        CGVector direction = radiansToVector(randomInRange(kCCHaloLowAngle, kCCHaloHighAngle));
        halo.physicsBody.velocity = CGVectorMake(direction.dx * kCCHaloSpeed, direction.dy * kCCHaloSpeed);
        halo.physicsBody.linearDamping = 0.0;
        halo.physicsBody.friction = 0.1;
        halo.physicsBody.categoryBitMask = kCCHaloFriend;
        halo.physicsBody.collisionBitMask = kCCEdgesCategory | kCCHaloCategory;
        halo.physicsBody.contactTestBitMask = kCCBallCategory | kCCLifeBarCategory;
        halo.physicsBody.velocity = CGVectorMake(-100, randomInRange(-50, 50));
        halo.physicsBody.angularVelocity = M_PI_4;
        
        // Create capsule smoke.
        NSString *capsuleSmoke = [[NSBundle mainBundle] pathForResource:@"CapsuleSmoke" ofType:@"sks"];
        SKEmitterNode *capsuleSmokePath = [NSKeyedUnarchiver unarchiveObjectWithFile:capsuleSmoke];
        capsuleSmokePath.targetNode = _mainLayer;
        [halo addChild:capsuleSmokePath];
        
    }
    
    [_mainLayer addChild:halo];
    
}


-(void)spawnShieldPowerUp {
    
    if (_shieldPool.count > 0) {
        
        SKSpriteNode *shieldUp = [SKSpriteNode spriteNodeWithImageNamed:@"Block"];
        shieldUp.name = @"shieldUp";
        shieldUp.position = CGPointMake(self.size.width + shieldUp.size.width, randomInRange(150, self.size.height - 100));
        shieldUp.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(42, 9)];
        shieldUp.physicsBody.categoryBitMask = kCCShieldUpCategory;
        shieldUp.physicsBody.collisionBitMask = 0;
        shieldUp.physicsBody.velocity = CGVectorMake(-100, randomInRange(-40, 40));
        shieldUp.physicsBody.angularVelocity = M_PI;
        shieldUp.physicsBody.linearDamping = 0.0;
        shieldUp.physicsBody.angularDamping = 0.0;
        shieldUp.physicsBody.affectedByGravity = NO;
        
        [_mainLayer addChild: shieldUp];
    }
    
}


-(void)spawnMultiShotPowerUp {
    
    SKSpriteNode *multiUp = [SKSpriteNode spriteNodeWithImageNamed:@"MultiShotPowerUp"];
    multiUp.name = @"multiUp";
    multiUp.position = CGPointMake(-multiUp.size.width, randomInRange(150, self.size.height - 100));
    multiUp.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:12.0];
    multiUp.physicsBody.categoryBitMask = kCCMultiUpCategory;
    multiUp.physicsBody.collisionBitMask = 0;
    multiUp.physicsBody.velocity = CGVectorMake(100, randomInRange(40, -40));
    multiUp.physicsBody.angularVelocity = M_PI;
    multiUp.physicsBody.linearDamping = 0.0;
    multiUp.physicsBody.angularDamping = 0.0;
    [_mainLayer addChild:multiUp];
    
}


-(void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
        
    }
    
    
    if (firstBody.categoryBitMask == kCCHaloCategory && secondBody.categoryBitMask == kCCBallCategory) {
        // Collision between halo and ball.
        self.score++;
        [self addExplosion:firstBody.node.position withName:@"HaloExplosion"];
        [self runAction:_explosionSound];
        _killCount++;
        
        if (_killCount % 10 == 0) {
            [self spawnMultiShotPowerUp];
        }
        
        if ([[firstBody.node.userData valueForKey:@"Bomb"] boolValue]) {
            
            [self addExplosion:firstBody.node.position withName:@"MassExplosion"];
            
            firstBody.node.name = nil;
            [_mainLayer enumerateChildNodesWithName:@"halo" usingBlock:^(SKNode *node, BOOL *stop) {
                [self addExplosion:node.position withName:@"HaloExplosion"];
                self.score = self.score++;
                [node removeFromParent];
            }];
        }
        
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
    }
    
    
    // Add friend (capsule) killed event.
    if (firstBody.categoryBitMask == kCCHaloFriend && secondBody.categoryBitMask == kCCBallCategory) {
        // Collision between friend and ball.
        [self addExplosion:firstBody.node.position withName:@"HaloExplosion"];
        [self runAction:_explosionSound];
        self.score = self.score - 5;
        
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
    }
    
    
    // Saved friends count.
    if (firstBody.categoryBitMask == kCCHaloFriend && secondBody.categoryBitMask == kCCLifeBarCategory) {
        
        [self addExplosion:secondBody.node.position withName:@"ShipSaved"];
        [self runAction:_shieldUpSound];
        self.friendsSaved++;
        self.score = self.score + 10;
        
        [firstBody.node removeFromParent];
        
    }
    
    
    if (firstBody.categoryBitMask == kCCHaloCategory && secondBody.categoryBitMask == kCCShieldCategory) {
        // Collision between halo and shield.
        
        [self addExplosion:firstBody.node.position withName:@"HaloExplosion"];
        [self runAction:_explosionSound];
        
        if ([[firstBody.node.userData valueForKey:@"Bomb"] boolValue]) {
            // Remove all shields.
            [_mainLayer enumerateChildNodesWithName:@"shield" usingBlock:^(SKNode *node, BOOL *stop) {
                [node removeFromParent];
            }];
        }
        
        firstBody.categoryBitMask = 0;
        
        [firstBody.node removeFromParent];
        [_shieldPool addObject:secondBody.node];
        [secondBody.node removeFromParent];
    }
    
    
    if (firstBody.categoryBitMask == kCCHaloCategory && secondBody.categoryBitMask == kCCLifeBarCategory) {
        // Collision between halo and lifeBar. (GAME OVER)
        [self addExplosion:secondBody.node.position withName:@"LifeBarExplosion"];
        [self runAction:_deepExplosionSound];
        
        [secondBody.node removeFromParent];
        [self gameOver];
    }
    
    
    if (firstBody.categoryBitMask == kCCBallCategory && secondBody.categoryBitMask == kCCEdgesCategory) {
        if ([firstBody.node isKindOfClass:[Ball class]]) {
            ((Ball*)firstBody.node).bounces++;
            if (((Ball*)firstBody.node).bounces > 3) {
                [firstBody.node removeFromParent];
                
            }
        }
        
        [self addExplosion:contact.contactPoint withName:@"BounceExplosion"];
        [self runAction:_bounceSound];
    }
    
    
    if (firstBody.categoryBitMask == kCCBallCategory && secondBody.categoryBitMask == kCCShieldUpCategory) {
        // Hit a shield power up.
        if (_shieldPool.count > 0) {
            int randomIndex = arc4random_uniform((int)_shieldPool.count);
            [_mainLayer addChild:[_shieldPool objectAtIndex:randomIndex]];
            [_shieldPool removeObjectAtIndex:randomIndex];
            [self runAction:_shieldUpSound];
        }
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
    }
    
    
    if (firstBody.categoryBitMask == kCCBallCategory && secondBody.categoryBitMask == kCCMultiUpCategory) {
        // Hit a MultiUp.
        self.multiMode = YES;
        [self runAction:_shieldUpSound];
        self.ammo = 5;
        
        
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
    }
    
    
}


-(void) gameOver {
    
    [_mainLayer enumerateChildNodesWithName:@"halo" usingBlock:^(SKNode *node, BOOL *stop) {
        [self addExplosion:node.position withName:@"HaloExplosion"];
        [node removeFromParent];
    }];
    [_mainLayer enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    [_mainLayer enumerateChildNodesWithName:@"shield" usingBlock:^(SKNode *node, BOOL *stop) {
        [self->_shieldPool addObject:node];
        [node removeFromParent];
    }];
    
    [_mainLayer enumerateChildNodesWithName:@"shieldUp" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    
    [_mainLayer enumerateChildNodesWithName:@"multiUp" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    
    
    _menu.score = self.score;
    if (self.score > _menu.topScore) {
        _menu.topScore = self.score;
        [_userDefaults setInteger:self.score forKey:kCCKeyTopScore];
        [_userDefaults synchronize];
    }
    _gameOver = YES;
    _scoreLabel.hidden = YES;
    _friendLabel.hidden = YES;
    _pauseButton.hidden = YES;
    
    [self stopDeviceMotion];
    
    
    [self runAction:[SKAction waitForDuration:1.0] completion:^{
        [self->_menu show];
    }];
    
}


-(void) addExplosion:(CGPoint)position withName:(NSString*)name {
    
    NSString *explosionPath = [[NSBundle mainBundle] pathForResource:name ofType:@"sks"];
    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
    
    explosion.position = position;
    [_mainLayer addChild:explosion];
    
    SKAction *removeExplosion = [SKAction sequence:@[[SKAction waitForDuration:2],
                                                     [SKAction removeFromParent]]];
    
    [explosion runAction:removeExplosion];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        if (!_gameOver && !self.gamePaused) {
            if (![_pauseButton containsPoint:[touch locationInNode:_pauseButton.parent]]) {
                _didShoot = YES;
            }
        }
    }
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (_gameOver && _menu.touchable) {
            SKNode *n = [_menu nodeAtPoint:[touch locationInNode:_menu]];
            if ([n.name isEqualToString:@"Play"]) {
                [self newGame];
            }
        }
        else if (!_gameOver)
        {
            if (self.gamePaused){
                if ([_resumeButton containsPoint:[touch locationInNode:_resumeButton.parent]]) {
                    self.gamePaused = NO;
                    [self startDeviceMition];
                }
            } else{
                if ([_pauseButton containsPoint:[touch locationInNode:_pauseButton.parent]]) {
                    self.gamePaused = YES;
                    [self stopDeviceMotion];
                }
            }
        }
    }
}


-(void)didSimulatePhysics {
    
    // Shoot.
    if (_didShoot) {
        
        if (self.ammo > 0) {
            self.ammo--;
            
            [self shoot];
            
            if (self.multiMode) {
                for (int i = 1; i < 5; i++) {
                    [self performSelector:@selector(shoot) withObject:nil afterDelay:0.75 * i];
                }
                if (self.ammo == 0) {
                    self.multiMode = NO;
                    self.ammo = 5;
                }
            }
        }
        _didShoot = NO;
    }
    
    // Remove unused nodes.
    [_mainLayer enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        if ([node respondsToSelector:@selector(updateTrail)]) {
            [node performSelector:@selector(updateTrail) withObject:nil afterDelay:0.0];
        }
        
        
        if (!CGRectContainsPoint(self.frame, node.position)) {
            [node removeFromParent];
            
        }
    }];
    
    
    [_mainLayer enumerateChildNodesWithName:@"shieldUp" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x + node.frame.size.width < 0) {
            [node removeFromParent];
        }
    }];
    
    [_mainLayer enumerateChildNodesWithName:@"multiUp" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x - node.frame.size.width > self.size.width) {
            [node removeFromParent];
        }
    }];
    
    [_mainLayer enumerateChildNodesWithName:@"halo" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y + node.frame.size.height < 0) {
            [node removeFromParent];
        }
    }];
    
    
}


-(void)startDeviceMition {
    
    // Add gyro control of cannon.
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical toQueue:self.motionQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            CGFloat x = motion.gravity.x;
            CGFloat y = motion.gravity.y * 0.75;
            CGFloat realAngle = atan2(x, y);
            CGFloat angle = realAngle + M_PI;
            if (realAngle < -M_PI_2 || realAngle > M_PI_2)
            {
                SKAction *rotateCannon = [SKAction rotateToAngle:angle duration:0];
                [self->_cannon runAction:rotateCannon];
            }
        }];
    }];
    
}


-(void)stopDeviceMotion {
    [_motionManager stopDeviceMotionUpdates];
    [_motionQueue cancelAllOperations];
    [[NSOperationQueue mainQueue] cancelAllOperations];
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}


@end

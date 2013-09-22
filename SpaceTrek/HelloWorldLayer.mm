//
//  HelloWorldLayer.mm
//  SpaceTrek
//
//  Created by huang yongke on 13-9-22.
//  Copyright huang yongke 2013年. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"

// Not included in "cocos2d.h"
#import "CCPhysicsSprite.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"


enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) createMenu;
@end

@implementation HelloWorldLayer

const int treasureV_x = 100;
const int minTreasureDes_X = 250;

NSMutableArray * _treasures;

CCSprite *player;
CGRect playerRect;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
    
	if( (self=[super initWithColor:ccc4(255, 255, 255, 255)] )) {
        
        _treasures = [[NSMutableArray alloc] init];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        player = [CCSprite spriteWithFile:@"Player.png"];
        
        
        
        player.position = ccp(player.contentSize.width/2, winSize.height/2);
        
        playerRect = CGRectMake(
                                player.position.x - (player.contentSize.width/2),
                                player.position.y - (player.contentSize.height/2),
                                player.contentSize.width,
                                player.contentSize.height);
        
        
        
        int minDuration =2.0;
        int maxDuration =4.0;
        int rangeDuration = maxDuration - minDuration;
        int actualDuration = (arc4random() % rangeDuration) + minDuration;
        
        // Create the actions
        id actionMove = [CCMoveTo actionWithDuration:actualDuration
                                            position:ccp(winSize.width/2, winSize.height/2)];
        
        
        id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                                 selector:@selector(playerMoveFinished:)];
        
        [player runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
        
        
        
        
        
        [self addChild:player];
        
    }
    
    [self schedule:@selector(gameLogic:) interval:2.0];
    [self schedule:@selector(gameOver:)];
    return self;
}

-(void)gameLogic:(ccTime)dt {
    [self addTreasure];
}

-(void)playerMoveFinished:(id)sender {
    //    CCSprite *sprite = (CCSprite *)sender;
    //    [self removeChild:sprite cleanup:YES];
}


-(void)addTreasure {
    
    CCSprite *treasure = [CCSprite spriteWithFile:@"Target.png"];
    
    
    
    // Determine where to spawn the target along the Y axis
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    treasure.position = ccp(winSize.width, winSize.height/2);
    
    [self addChild:treasure];
    
    
    int actualDuration = 4;
    
    // Create the actions
    id actionMove = [CCMoveTo actionWithDuration:actualDuration
                                        position:ccp(0, winSize.height/2)];
    
    
    id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                             selector:@selector(treasureMoveFinished:)];
    
    [treasure runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
    treasure.tag =1;
    [_treasures addObject:treasure];
    
    /*
     int minX = treasure.contentSize.width/2;
     int maxX = winSize.width - treasure.contentSize.width/2;
     int rangeX = maxX - minX;
     int actualX =  arc4random() % (rangeX - minTreasureDes_X);
     int minY = treasure.contentSize.height/2;
     int maxY = winSize.height - treasure.contentSize.height/2;
     int rangeY = maxY - minY;
     int actualY = (arc4random() % rangeY) + minY;
     
     
     int random = arc4random() % 2;
     int destinationY = 0;
     if(random == 1)
     destinationY = 0;
     else
     destinationY = winSize.height;
     
     
     
     treasure.position = ccp(winSize.width - treasure.contentSize.width/2,actualY);
     
     [self addChild:treasure];
     
     
     int actualDuration = (winSize.width - actualX)/treasureV_x;
     
     // Create the actions
     id actionMove = [CCMoveTo actionWithDuration:actualDuration
     position:ccp(actualX, destinationY)];
     id actionMoveDone = [CCCallFuncN actionWithTarget:self
     selector:@selector(treasureMoveFinished:)];
     [treasure runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
     
     treasure.tag =1;
     [_treasures addObject:treasure];
     */
}

-(void)treasureMoveFinished:(id)sender {
    
    CCSprite *sprite = (CCSprite *)sender;
    if (sprite.tag ==1)
    {
        [_treasures removeObject:sprite];
    }
    
    [self removeChild:sprite cleanup:YES];
}


- (void)gameOver:(ccTime)dt {
    
    for (CCSprite *treasure in _treasures) {
        CGRect treasureRect = CGRectMake(
                                         treasure.position.x - (treasure.contentSize.width/2),
                                         treasure.position.y - (treasure.contentSize.height/2),
                                         treasure.contentSize.width,
                                         treasure.contentSize.height);
        
        if (CGRectIntersectsRect(playerRect, treasureRect)) {
            player.visible = NO;
        }
    }
}




// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    
    [_treasures release];
    _treasures = nil;
	[super dealloc];
}


#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end

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

const int treasureV_x = 50;
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
        
        int actualDuration = winSize.width/5.0/treasureV_x;
        
        // Create the actions
        id actionMove = [CCMoveTo actionWithDuration:actualDuration
                                            position:ccp(winSize.width/5, winSize.height/2)];
        
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

int GetRandom(int lowerbound, int upperbound){
    return lowerbound + arc4random() % ( upperbound - lowerbound + 1 );
}

int GetRandomGaussian( int lowerbound, int upperbound ){
    double u1 = (double)arc4random() / UINT32_MAX;
    double u2 = (double)arc4random() / UINT32_MAX;
    double f1 = sqrt(-2 * log(u1));
    double f2 = 2 * M_PI * u2;
    double g1 = f1 * cos(f2);
    g1 = (g1+1)/2;
    return lowerbound + g1 * ( upperbound - lowerbound + 1 );
}

-(void)addTreasure {
    
    CCSprite *treasure = [CCSprite spriteWithFile:@"Target.png"];
    
    // Determine where to spawn the target along the Y axis
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    [self addChild:treasure];
    
    int treasureStartY = GetRandom( treasure.contentSize.height/2, winSize.height - treasure.contentSize.height/2 );
    int treasureDestinationY = GetRandomGaussian( treasureStartY-winSize.height/2, treasureStartY+winSize.height/2 );
    int actualDuration = winSize.width /treasureV_x;
    
    treasure.position = ccp(winSize.width - treasure.contentSize.width/2, treasureStartY);
    
    // Create the actions
    id actionMove = [CCMoveTo actionWithDuration:actualDuration
                                        position:ccp(0, treasureDestinationY)];
    
    
    id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                             selector:@selector(treasureMoveFinished:)];
    
    [treasure runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
    treasure.tag =1;
    [_treasures addObject:treasure];
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

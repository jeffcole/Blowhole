//
//  Ring.mm
//  Blowhole
//
//  Created by Jeffrey Cole on 5/11/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "BlowholeLayer.h"
#import "Ring.h"

@interface Ring (PrivateMethods)
-(id) initWithType:(RingType)ringType 
    leftParentNode:(CCNode*)leftParentNode
   rightParentNode:(CCNode*)rightParentNode;
-(void) createSpritesWithFrameName:(NSString*)frameName
                    leftParentNode:(CCNode*)leftParentNode
                   rightParentNode:(CCNode*)rightParentNode;
-(void) createBodies;
-(void) setPosition:(CGPoint)pos;
-(void) removeSpritesFromParent;
-(void) removeSprites;
-(void) removeBodies;
@end

@implementation Ring

@synthesize type, leftParent, rightParent, leftSprite, rightSprite,
            topBody, bottomBody;

/* Static autorelease initializer for Ring
 ******************************************************************************/
+(id) ringWithType:(RingType)ringType
    leftParentNode:(CCNode*)leftParentNode
   rightParentNode:(CCNode*)rightParentNode {
  
  return [[[self alloc] initWithType:ringType
                      leftParentNode:leftParentNode
                     rightParentNode:rightParentNode] autorelease];
}

/* Initialize a ring instance
 ******************************************************************************/
-(id) initWithType:(RingType)ringType
    leftParentNode:(CCNode*)leftParentNode
   rightParentNode:(CCNode*)rightParentNode {
  
  type = ringType;
  NSString* frameName;
	
  switch (type) {
    case RingTypeSmall:
      frameName = @"ring";
      velocity = CGPointMake(-1, 0);
      break;
    default:
      [NSException exceptionWithName:@"RingException" reason:@"unhandled Ring type" userInfo:nil];
  }
  
  // load the ring's sprites using a frame name (i.e. the filename)
  if ((self = [super init])) {
    [self createSpritesWithFrameName:frameName
                      leftParentNode:leftParentNode
                     rightParentNode:rightParentNode];
    leftSprite.visible = NO;
    rightSprite.visible = NO;
    
    [self createBodies];
    
    [[CCScheduler sharedScheduler] scheduleUpdateForTarget:self priority:0 paused:NO];
    
    // create an animation object from all the sprite animation frames
    //CCAnimation* anim = [CCAnimation animationWithFrame:@"Ring-anim" frameCount:5 delay:0.08f];
		
    // add the animation to the sprite (optional)
    //[sprite addAnimation:anim];
		
    // run the animation by using the CCAnimate action
    /*
     CCAnimate* animate = [CCAnimate actionWithAnimation:anim];
     CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
     [self runAction:repeat];
     */
  }
  return self;
}

/* Deallocate the ring
 ******************************************************************************/
-(void) dealloc {
  CCLOG(@"Ring dealloc %@", self);
  
  [[CCScheduler sharedScheduler] unscheduleUpdateForTarget:self];
  
  [self removeSprites];
  [self removeBodies];
	
  [super dealloc];
}

/* Create the ring's sprite and add it as a child of the parent
 ******************************************************************************/
-(void) createSpritesWithFrameName:(NSString*)frameName
                    leftParentNode:(CCNode*)leftParentNode
                   rightParentNode:(CCNode*)rightParentNode {
  
  [self removeSprites];
  
  NSString* leftName = [Utility platformImageWithName:
                        [NSString stringWithFormat:@"%@_left", frameName]];
  NSString* rightName = [Utility platformImageWithName:
                        [NSString stringWithFormat:@"%@_right", frameName]];
  
  // must retain sprite because we need to be able to use it after it has been
  // removed from its parent
  leftSprite = [[CCSprite spriteWithSpriteFrameName:leftName] retain];
  rightSprite = [[CCSprite spriteWithSpriteFrameName:rightName] retain];
  leftParent = leftParentNode;
  [leftParent addChild:leftSprite];
  rightParent = rightParentNode;
  [rightParent addChild:rightSprite];
}

/* Create the physics bodies for the ring, one at the top and one at the bottom
 ******************************************************************************/
-(void) createBodies { 
  
  float radius;
  b2BodyDef bodyDef;
  b2FixtureDef fixtureDef;
  
  switch (type) {
    case RingTypeSmall:
      // this radius factor needs to accurately reflect the ring thickness
      radius = rightSprite.height * 0.07f;
      bodyDef.angularDamping = 0.9f;
      fixtureDef.density = 0.8f;
      fixtureDef.friction = 0.7f;
      fixtureDef.restitution = 0.3f;
      break;
    default:
      [NSException exceptionWithName:@"RingException" reason:@"unhandled Ring type" userInfo:nil];
  }
  
  b2CircleShape shape;
  float radiusInMeters = radius / PTM_RATIO;
  shape.m_radius = radiusInMeters;
  fixtureDef.shape = &shape;
  
  b2World* world = (b2World*)[[BlowholeLayer sharedLayer] world];
	
  [self removeBodies];
  
  topBody = world->CreateBody(&bodyDef);
  topBody->SetUserData(self);
  
  bottomBody = world->CreateBody(&bodyDef);
  bottomBody->SetUserData(self);
	
  if (&fixtureDef != NULL) {
    topBody->CreateFixture(&fixtureDef);
    bottomBody->CreateFixture(&fixtureDef);
  }
}

/* Set the positions of the ring's sprites and bodies
 ******************************************************************************/
-(void) setPosition:(CGPoint)pos {
  
  // set the positions of the sprites
  CGPoint leftPos = CGPointMake(pos.x
                                - (rightSprite.halfWidth)
                                - (leftSprite.halfWidth)
                                + 1 // overlap to correct gap due to rounding
                                // errors
                                , pos.y);
  [leftSprite setPosition:leftPos];
  [rightSprite setPosition:pos];
  
  // set the positions of the bodies
  float radiusInMeters = topBody->GetFixtureList()[0].GetShape()->m_radius;
  float radius = radiusInMeters * PTM_RATIO;
  CGPoint topPos = CGPointMake(pos.x - (rightSprite.width * 0.5f),
                               pos.y + (rightSprite.height * 0.5f) - radius);
  CGPoint bottomPos = CGPointMake(pos.x - (rightSprite.width * 0.5f),
                                  pos.y - (rightSprite.height * 0.5f) + radius);
  
  topBody->SetTransform([Utility toMeters:topPos], 0.0f);
  bottomBody->SetTransform([Utility toMeters:bottomPos], 0.0f);
}

/* Spawn a ring onto the screen
 ******************************************************************************/
-(void) spawn {
  
  CGSize screenSize = [BlowholeLayer screenRect].size;
  // just off the right side of the screen
  float xPos = screenSize.width + rightSprite.halfWidth + leftSprite.width;
  // at a random position between the top of the screen and above the water
  float yPos = (CCRANDOM_0_1() * (screenSize.height
                                  - rightSprite.height
                                  - [BlowholeLayer waterLevel])
                + (rightSprite.halfHeight)
                + [BlowholeLayer waterLevel]);
  CGPoint position = CGPointMake(xPos, yPos);
  //[Utility logCGPoint:position named:@"position"];
  
  [self setPosition:position];
  leftSprite.visible = YES;
  rightSprite.visible = YES;
}

/* Scheduled time update hander
 ******************************************************************************/
-(void) update:(ccTime)delta {
  
  if (rightSprite.visible) {
    if ((rightSprite.positionRight) > 0) {
      [self setPosition:ccpAdd(rightSprite.position, velocity)];
    } else {
      // set to invisible to allow further spawning
      leftSprite.visible = NO;
      rightSprite.visible = NO;
    }
  }
}

/* Remove the ring's sprite from its parent
 ******************************************************************************/
-(void) removeSpritesFromParent {
  if ((leftSprite != nil) && [leftParent.children containsObject:leftSprite]) {
    [leftSprite removeFromParentAndCleanup:NO];
    leftParent = nil;
  }
  
  if ((rightSprite != nil) && [rightParent.children containsObject:rightSprite]) {
    [rightSprite removeFromParentAndCleanup:NO];
    rightParent = nil;
  }
}

/* Remove the ring's sprite completely
 ******************************************************************************/
-(void) removeSprites {
  [self removeSpritesFromParent];
  
  [leftSprite release];
  leftSprite = nil;
  
  [rightSprite release];
  rightSprite = nil;
}

/* Remove the ring's body from the world
 ******************************************************************************/
-(void) removeBodies {
  if (topBody != NULL) {
    topBody->GetWorld()->DestroyBody(topBody);
    topBody = NULL;
  }
  if (bottomBody != NULL) {
    bottomBody->GetWorld()->DestroyBody(bottomBody);
    bottomBody = NULL;
  }
}

@end

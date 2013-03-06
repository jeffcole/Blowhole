//
//  Player.mm
//  Blowhole
//
//  Created by Jeffrey Cole on 4/25/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "BlowholeLayer.h"
#import "Player.h"

@interface Player (PrivateMethods)
-(id) initWithParentNode:(CCNode*)parentNode;
-(void) removeChild;
@end

@implementation Player

@synthesize attachedEntity;

/* Static autorelease initializer for player
 ******************************************************************************/
+(id) playerWithParentNode:(CCNode*)parentNode {
  
  return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

/* Initialize a player instance
 ******************************************************************************/
-(id) initWithParentNode:(CCNode*)parentNode {
  
  // load the player's sprite using a sprite frame name (i.e. the filename)
  if ((self = [super init])) {
    NSString* frameName = [Utility platformImageWithName:@"whale"];
    [super createSpriteWithFrameName:frameName parentNode:parentNode];
    [[CCScheduler sharedScheduler] scheduleUpdateForTarget:self priority:0 paused:NO];
    
    // create an animation object from all the sprite animation frames
    //CCAnimation* anim = [CCAnimation animationWithFrame:@"player-anim" frameCount:5 delay:0.08f];
		
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

/* Deallocate the player
 ******************************************************************************/
-(void) dealloc {
  CCLOG(@"Player dealloc %@", self);

  [[CCScheduler sharedScheduler] unscheduleUpdateForTarget:self];
  
  [self removeChild];
  
  [super dealloc];
}

/* Set the player's sprite position while keeping it below the water and within
 * the screen
 ******************************************************************************/
-(void) setPosition:(CGPoint)pos {
  
  // If the current position is (still) outside the screen no adjustments
  // should be made. This allows entities to move into the screen from
  // outside.
  if (CGRectContainsRect([BlowholeLayer screenRect], [sprite boundingBox])) {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
    // Cap the position so the entity's sprite stays on the screen
    if (pos.x < sprite.halfWidth) {
      pos.x = sprite.halfWidth;
    }
    else if (pos.x > (screenSize.width - sprite.halfWidth)) {
      pos.x = screenSize.width - sprite.halfWidth;
    }
		
    if (pos.y < sprite.halfHeight) {
      pos.y = sprite.halfHeight;
    }
    else if (pos.y > ([BlowholeLayer waterLevel] - sprite.halfHeight)) {
      pos.y = [BlowholeLayer waterLevel] - sprite.halfHeight;
    }
  }

  // handle x orientation
  if (((pos.x < sprite.position.x) && (sprite.scaleX > 0))
      || ((pos.x > sprite.position.x) && (sprite.scaleX < 0))) {
    sprite.scaleX *= -1;
  }

  [sprite setPosition:pos];
}

/* Collision handler override
 ******************************************************************************/
-(void) collidedWith:(Entity*)entity {
  if (attachedEntity == nil) {
    //CCLOG(@"Player collidedWith");
    [self addChild:entity];
  }
}


/* Add an entity as a child of this entity
 ******************************************************************************/
-(void) addChild:(Entity*)childEntity {
  
  if ((sprite != nil) && (childEntity.sprite != nil)) {
    //CCLOG(@"Player addChild");
    [childEntity removeSpriteFromParent];
    
    // handle x orientation
    if (sprite.scaleX < 0) {
      childEntity.sprite.scaleX *= -1;
    }
    
    CGPoint position = CGPointMake(sprite.halfWidth, sprite.height);
                                   //sprite.halfHeight
                                   //+ childEntity.sprite.halfHeight);
    [childEntity setPosition:position];
    
    childEntity.parent = sprite;
    childEntity.isAttached = YES;
    [sprite addChild:childEntity.sprite];
    attachedEntity = childEntity;    
  }
}

/* Launch the attached entity, taking into account a diminishing factor for the
 * force in the y-direction, and a velocity in the x-direction
 ******************************************************************************/
-(void) launchAttachedWithFactor:(float)factor velocityX:(float)velocityX {
  
  if (attachedEntity != nil) {
    CGPoint position = CGPointMake(sprite.position.x,
                                   sprite.positionTop);
    
    [sprite addParticleWithFile:@"blow_particle.plist"
                     atPosition:position
                     withFactor:factor
                        withTag:0];
    
    Entity* entity = attachedEntity;
    [self removeChild];
    
    CCSpriteBatchNode* blowholeBatch = [[BlowholeLayer sharedLayer] getSpriteBatch];
    [blowholeBatch addChild:entity.sprite];
    entity.parent = blowholeBatch;
    
    // handle x orientation
    if (sprite.scaleX < 0) {
      entity.sprite.scaleX *= -1;
    }
    
    [entity setPosition:position];
    
    [entity createBody];
    //b2Vec2 force = b2Vec2(0.0f, 100.0f * factor);
    b2Vec2 force = b2Vec2(velocityX * 20.0f, 100.0f * factor);
    b2Vec2 center = entity.body->GetWorldCenter();
    //CCLOG(@"Player launchAttachedWithFactor force->y = %f", force.y);
    entity.body->ApplyForce(force, center);
    entity.body->SetAngularVelocity(velocityX * -20.0f);
    entity.hasBeenLaunched = YES;
  }
}

/* Remove the player's attached entity
 ******************************************************************************/
-(void) removeChild {
  //CCLOG(@"Player removeChild");
  [attachedEntity removeSpriteFromParent];
  attachedEntity.isAttached = NO;
  attachedEntity = nil;
}

/* Scheduled time update hander
 ******************************************************************************/
-(void) update:(ccTime)delta {
  
}

@end

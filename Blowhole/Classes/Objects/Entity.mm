//
//  Entity.mm
//  Blowhole
//
//  Created by Jeffrey Cole on 4/23/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "BlowholeLayer.h"
#import "Entity.h"

@implementation Entity

@synthesize parent, sprite, body, isAttached, hasBeenLaunched;

/* Create the entity's sprite and add it as a child of the parent
 ******************************************************************************/
-(void) createSpriteWithFrameName:(NSString*)frameName
                       parentNode:(CCNode*)parentNode {
  
  [self removeSprite];
  
  // must retain sprite because we need to be able to use it after it has been
  // removed from its parent
  sprite = [[CCSprite spriteWithSpriteFrameName:frameName] retain];
  parent = parentNode;
  [parent addChild:sprite];
}

/* Abstract entity-specific method left for subclasses to implement
 ******************************************************************************/
-(void) createBody {}

/* Create a body for the entity in the world
 ******************************************************************************/
-(void) createBodyWithBodyDef:(b2BodyDef*)bodyDef
               fixtureDef:(b2FixtureDef*)fixtureDef {
  
  b2World* world = (b2World*)[[BlowholeLayer sharedLayer] world];
	
  [self removeBody];
  
  body = world->CreateBody(bodyDef);
  body->SetUserData(self);
	
  if (fixtureDef != NULL) {
    body->CreateFixture(fixtureDef);
  }
}

/* Abstract entity-specific method left for subclasses to implement
 ******************************************************************************/
-(void) setPosition:(CGPoint)pos {}

/* Set the npc's sprite to invisible
 ******************************************************************************/
-(void) setInvisible {
  //CLOG(@"Entity setInvisible");
  sprite.visible = NO;
}

/* Set the npc's sprite to visible
 ******************************************************************************/
-(void) setVisible {
  sprite.visible = YES;
}

/* Physics update hander called from the central world processing handler
 ******************************************************************************/
-(void) updatePhysics {
  //CCLOG(@"Entity updatePhysics");
  sprite.position = CGPointMake(body->GetPosition().x * PTM_RATIO, body->GetPosition().y * PTM_RATIO);
  sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(body->GetAngle());
}

/* Remove the entity's sprite from its parent
 ******************************************************************************/
-(void) removeSpriteFromParent {
  if ((sprite != nil) && [parent.children containsObject:sprite]) {
    [sprite removeFromParentAndCleanup:YES];
    parent = nil;
  }
}

/* Remove the entity's sprite completely
 ******************************************************************************/
-(void) removeSprite {
  [self removeSpriteFromParent];
  [sprite release];
  sprite = nil;
}

/* Remove the entity's body from the world
 ******************************************************************************/
-(void) removeBody {
  if (body != NULL) {
    body->GetWorld()->DestroyBody(body);
    body = NULL;
  }
}

/* Deallocate the entity
 ******************************************************************************/
-(void) dealloc {
  CCLOG(@"Entity dealloc %@", self);
  
  [self removeSpriteFromParent];
  [self removeSprite];
  [self removeBody];
	
  [super dealloc];
}

@end

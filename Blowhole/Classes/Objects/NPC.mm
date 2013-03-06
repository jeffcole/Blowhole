//
//  NPC.mm
//  Blowhole
//
//  Created by Jeffrey Cole on 4/29/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "BlowholeLayer.h"
#import "NPC.h"

@interface NPC (PrivateMethods)
-(id) initWithType:(NPCType)npcType 
        parentNode:(CCNode*)parentNode;
@end

@implementation NPC

@synthesize type, hasReentered;

/* Static autorelease initializer for NPC
 ******************************************************************************/
+(id) npcWithType:(NPCType)npcType
       parentNode:(CCNode*)parentNode {
  
  return [[[self alloc] initWithType:npcType parentNode:parentNode] autorelease];
}

/* Initialize an npc instance
 ******************************************************************************/
-(id) initWithType:(NPCType)npcType 
        parentNode:(CCNode*)parentNode {
  
  type = npcType;
  NSString* frameName;
	
  switch (type) {
    case NPCTypeSeal:
      frameName = [Utility platformImageWithName:@"seal"];
      break;
    default:
      [NSException exceptionWithName:@"NPCException"
                              reason:@"unhandled npc type"
                            userInfo:nil];
  }
  
  // Loading the NPC's sprite using a sprite frame name (i.e. the filename)
  if ((self = [super init])) {
    [self createSpriteWithFrameName:frameName parentNode:parentNode];
    sprite.visible = NO;
    [[CCScheduler sharedScheduler] scheduleUpdateForTarget:self priority:0 paused:NO];
    
    // create an animation object from all the sprite animation frames
    //CCAnimation* anim = [CCAnimation animationWithFrame:@"NPC-anim" frameCount:5 delay:0.08f];
		
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

/* Deallocate the npc
 ******************************************************************************/
-(void) dealloc {
  CCLOG(@"NPC dealloc %@", self);
  
  [[CCScheduler sharedScheduler] unscheduleUpdateForTarget:self];
  
  [super dealloc];
}

/* Create the physics body for the npc
 ******************************************************************************/
-(void) createBody {
  
  b2BodyDef bodyDef;
  bodyDef.type = b2_dynamicBody;
  
  b2CircleShape shape;
  float radiusInMeters = (sprite.height / PTM_RATIO) * 0.5f;
  shape.m_radius = radiusInMeters;
  
  b2FixtureDef fixtureDef;
  fixtureDef.shape = &shape;
  
  switch (type) {
    case NPCTypeSeal:
      bodyDef.position = [Utility toMeters:sprite.position];
      bodyDef.angularDamping = 0.9f;
      fixtureDef.density = 0.8f;
      fixtureDef.friction = 0.7f;
      fixtureDef.restitution = 0.3f;
      break;
    default:
      [NSException exceptionWithName:@"NPCException"
                              reason:@"unhandled npc type"
                            userInfo:nil];
  }
  
  [self createBodyWithBodyDef:&bodyDef fixtureDef:&fixtureDef];
}

/* Set the npc's sprite position
 ******************************************************************************/
-(void) setPosition:(CGPoint)pos {
  [sprite setPosition:pos];
}

/* Spawn an npc onto the screen
 ******************************************************************************/
-(void) spawn {
  float waterLevel = [BlowholeLayer waterLevel];
  
  CGSize screenSize = [BlowholeLayer screenRect].size;
  // just off the right side of the screen
  float xPos = screenSize.width + sprite.halfWidth;
  
  // at a random position between the water and the bottom of the screen
  float yPos = (CCRANDOM_0_1() * waterLevel + (sprite.halfHeight));
  CGPoint position = CGPointMake(xPos, yPos);
  //[Utility logCGPoint:position named:@"position"];
  
  [self setPosition:position];
  sprite.scaleX = 1;
  sprite.rotation = 0;
  sprite.visible = YES;
  hasBeenLaunched = NO;
  hasBreached = NO;
  hasReentered = NO;
  
  // use a bezier to get fluid motion across the screen
  ccBezierConfig bezConfig;
  float thirdWidth = screenSize.width / 3.0f;
  float cp1y = (CCRANDOM_0_1() * waterLevel + (sprite.halfHeight));
  float cp2y = (CCRANDOM_0_1() * waterLevel + (sprite.halfHeight));
	bezConfig.controlPoint_1 = ccp(thirdWidth * 2.0f, cp1y);
	bezConfig.controlPoint_2 = ccp(thirdWidth, cp2y);
	bezConfig.endPosition = ccp(-sprite.halfWidth, yPos);
  
  CCBezierTo* bezierTo = [CCBezierTo actionWithDuration:4 bezier:bezConfig];
  // set to invisible when done
  CCCallFunc* callback = [CCCallFunc actionWithTarget:self
                                             selector:@selector(setInvisible)];
  CCSequence* sequence = [CCSequence actions:bezierTo, callback, nil];
  [sprite runAction:sequence];
}

/* Scheduled time update hander
 ******************************************************************************/
-(void) update:(ccTime)delta {
  
  if (!sprite.visible) return;
  
  // detect breach, reentry, and unbreached launch events
  if (body != nil) {
    
    float water = [BlowholeLayer waterLevel];
    
    if (!hasBreached && (sprite.position.y > water)) {
      //CCLOG(@"NPC update hasBreached");
      hasBreached = YES;
      return;
    }
    
    if (hasBreached && !hasReentered && (sprite.position.y < water)) {
      //CCLOG(@"NPC update hasReentered");
      hasReentered = YES;
      CGPoint position = CGPointMake(sprite.position.x,
                                     sprite.positionTop);
      
      [[BlowholeLayer sharedLayer] addParticleWithFile:@"splash_particle.plist"
                                            atPosition:position
                                            withFactor:0.5f
                                               withTag:0];
      return;
    }
    
    if (hasReentered && (sprite.positionTop < water)) {
      //CCLOG(@"NPC update hasSubmerged");
      [self removeBody];
      
      // move to half water height
      CGPoint halfWater = CGPointMake(sprite.position.x, water * 0.5f);
      CCMoveTo* moveToHalfWater = [CCMoveTo actionWithDuration:1
                                                      position:halfWater];
      
      // move to left by length of sprite
      CGPoint endPos = CGPointMake(sprite.position.x - sprite.width,
                                   -sprite.halfHeight);
      CCMoveTo* moveToEndPos = [CCMoveTo actionWithDuration:1
                                                   position:endPos];
      
      // set to invisible when done
      CCCallFunc* callback = [CCCallFunc actionWithTarget:self
                                                 selector:@selector(setInvisible)];
      
      CCSequence* sequence = [CCSequence actions:moveToHalfWater, moveToEndPos,
                              callback, nil];
      [sprite runAction:sequence];
      return;
    }
    
    // if we've gotten to here, the npc has been launched but hasn't breached
    // check for out of bounds (left, bottom, right) and clean up
    CGSize screenSize = [BlowholeLayer screenRect].size;
    if ((sprite.positionLeft > screenSize.width)
        || (sprite.positionRight < 0)
        || (sprite.positionTop < 0)) {
      [self removeBody];
      [self setInvisible];
    }
    
  }
}

@end

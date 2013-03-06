//
//  NPCCache.mm
//  Blowhole
//
//  Created by Jeffrey Cole on 4/30/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "BlowholeLayer.h"
#import "NPC.h"
#import "NPCCache.h"
#import "Player.h"

@interface NPCCache (PrivateMethods)
-(void) initNPCs;
-(void) initSpawnFrequency;
-(void) checkForCollisions;
+(int) getSpawnFrequencyForNPCType:(NPCType)npcType;
@end

@implementation NPCCache

static CCArray* spawnFrequency;

/* Static autorelease initializer for NPCCache
 ******************************************************************************/
+(id) cache {
  return [[[self alloc] init] autorelease];
}

/* Initialize an npc cache
 ******************************************************************************/
-(id) init {

  if ((self = [super init])) {
    // get any image from the Texture Atlas we're using
    CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                            spriteFrameByName:[Utility platformImageWithName:@"seal"]];
      
    batch = [CCSpriteBatchNode batchNodeWithTexture:frame.texture];
    [self addChild:batch];
		
    [self initNPCs];
    [self initSpawnFrequency];
    [self scheduleUpdate];
  }
	
  return self;
}

/* Load the array of npc's
 ******************************************************************************/
-(void) initNPCs {

  // create the npcArray containing further arrays for each type
  npcArray = [[CCArray alloc] initWithCapacity:NPCType_MAX];
	
  // create the arrays for each type
  for (int i = 0; i < NPCType_MAX; i++) {
    // depending on NPC type the array capacity is set to hold the desired number of NPCs
    int capacity;
    switch (i) {
      case NPCTypeSeal:
        capacity = 1;
        break;	
      default:
        [NSException exceptionWithName:@"NPCCacheException" reason:@"unhandled npc type" userInfo:nil];
        break;
    }
		
    // no alloc needed since the npcArray will retain anything added to it
    CCArray* npcArrayOfType = [CCArray arrayWithCapacity:capacity];
    [npcArray addObject:npcArrayOfType];

    // load npcArrayOfType with capacity NPCs of that type
    for (int j = 0; j < capacity; j++) {
      // FIXME: could add z and tag to NPC static initializer in order to do:
      // NPC* npc = [NPC npcWithType:i parentNode:batch z:0 tag:i];
      // to later retrieve all children from the batch of a particular type
      NPC* npc = [NPC npcWithType:(NPCType)i parentNode:batch];
      [npcArrayOfType addObject:npc];
    }
  }
}

/* Deallocate the npc cache
 ******************************************************************************/
-(void) dealloc {
  CCLOG(@"NPCCache dealloc %@", self);
  
  [npcArray release];
  [super dealloc];
}

/* Initialize how frequently the npc's will spawn
 ******************************************************************************/
-(void) initSpawnFrequency {
  
  if (spawnFrequency == nil) {
    spawnFrequency = [[CCArray alloc] initWithCapacity:NPCType_MAX];
    [spawnFrequency insertObject:[NSNumber numberWithInt:60] atIndex:NPCTypeSeal];
    //[spawnFrequency insertObject:[NSNumber numberWithInt:260] atIndex:NPCType];
    //[spawnFrequency insertObject:[NSNumber numberWithInt:1500] atIndex:NPCType];
    
    // spawn one npc immediately
    //[self spawn];
  }
}

/* Deterimine the spawn frequency for the given npc type
 ******************************************************************************/
+(int) getSpawnFrequencyForNPCType:(NPCType)npcType {
  
  if ((npcType < 0) || (npcType >= NPCType_MAX)) {
    [NSException exceptionWithName:@"NPCCacheException" reason:@"invalid npc type" userInfo:nil];
  }
  
  NSNumber* number = [spawnFrequency objectAtIndex:npcType];
  return [number intValue];
}

/* Spawn an npc of a particular type
 ******************************************************************************/
-(void) spawnNPCOfType:(NPCType)NPCType {
  
  CCArray* npcArrayOfType = [npcArray objectAtIndex:NPCType];
	
  NPC* npc;
  CCARRAY_FOREACH(npcArrayOfType, npc) {
    // find the first free npc and respawn it
    if (npc.sprite.visible == NO) {
      //CCLOG(@"NPCCache spawnNPCOfType: %i", NPCType);
      [npc spawn];
      break;
    }
  }
}

/* Determine if an npc has collided with the player
 ******************************************************************************/
-(void) checkForCollisions {
  
  Player* player = (Player*)[[BlowholeLayer sharedLayer] player];
  
  CCArray* npcArrayOfType;
  CCARRAY_FOREACH(npcArray, npcArrayOfType) {
    NPC* npc;
    CCARRAY_FOREACH(npcArrayOfType, npc) {
      if (npc.sprite.visible && !npc.hasBeenLaunched) {
        CGPoint playerTop = CGPointMake(player.sprite.position.x,
                                        player.sprite.positionTop);
        if (CGRectContainsPoint(npc.sprite.boundingBox, playerTop)) {
          //CCLOG(@"NPCCache checkForCollisions");
          [player collidedWith:npc];
          break;
        }
      }
    }
  }
}

/* Determine if an npc is positioned within a given rectangle
 ******************************************************************************/
-(BOOL) isNPCInRect:(CGRect)rect {
  
  CCArray* npcArrayOfType;
  CCARRAY_FOREACH(npcArray, npcArrayOfType) {
    NPC* npc;
    CCARRAY_FOREACH(npcArrayOfType, npc) {
      if (npc.hasBeenLaunched && !npc.hasReentered) {
        if (CGRectContainsPoint(rect, npc.sprite.position)) {
          return YES;
        }
      }
    }
  }
  
  return NO;
}

/* Handle periodic spawning and checking for collisions
 ******************************************************************************/
-(void) update:(ccTime)delta {
  
  updateCount++;
  
  for (int i = NPCType_MAX - 1; i >= 0; i--) {
    int frequency = [NPCCache getSpawnFrequencyForNPCType:(NPCType)i];
		
    if (updateCount % frequency == 0) {
      [self spawnNPCOfType:(NPCType)i];
      break;
    }
  }
	
  [self checkForCollisions];
}

@end

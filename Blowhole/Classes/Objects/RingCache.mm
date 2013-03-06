//
//  RingCache.mm
//  Blowhole
//
//  Created by Jeffrey Cole on 5/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "BlowholeLayer.h"
#import "Ring.h"
#import "RingCache.h"

@interface RingCache (PrivateMethods)
-(void) initRings;
-(void) initSpawnFrequency;
-(void) checkForCollisions;
+(int) getSpawnFrequencyForRingType:(RingType)ringType;
@end

@implementation RingCache

static CCArray* spawnFrequency;

/* Static autorelease initializer for RingCache
 ******************************************************************************/
+(id) cache {
  return [[[self alloc] init] autorelease];
}

/* Initialize a ring cache
 ******************************************************************************/
-(id) init {

  if ((self = [super init])) {
    // get any image from the Texture Atlas we're using
    CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                            spriteFrameByName:[Utility platformImageWithName:@"whale"]];
    leftBatch = [CCSpriteBatchNode batchNodeWithTexture:frame.texture];
    rightBatch = [CCSpriteBatchNode batchNodeWithTexture:frame.texture];

    BlowholeLayer* blowhole = [BlowholeLayer sharedLayer];
    // NPCCache is added at z=1, the following z-orders allow the npc's to pass
    // thru the rings
    [blowhole addChild:leftBatch  z:0];
    [blowhole addChild:rightBatch z:2];

    [self initRings];
    [self initSpawnFrequency];
    [[CCScheduler sharedScheduler] scheduleUpdateForTarget:self priority:0 paused:NO];
  }
	
  return self;
}

/* Load the array of rings
 ******************************************************************************/
-(void) initRings {

  // create the ringArray containing further arrays for each type
  ringArray = [[CCArray alloc] initWithCapacity:RingType_MAX];
	
  // create the arrays for each type
  for (int i = 0; i < RingType_MAX; i++) {
    // depending on Ring type the array capacity is set to hold the desired number of Rings
    int capacity;
    switch (i) {
      case RingTypeSmall:
        capacity = 1;
        break;	
      default:
        [NSException exceptionWithName:@"RingCacheException" reason:@"unhandled RingType" userInfo:nil];
        break;
    }
		
    // no alloc needed since the ringArray will retain anything added to it
    CCArray* ringArrayOfType = [CCArray arrayWithCapacity:capacity];
    [ringArray addObject:ringArrayOfType];

    // load ringArrayOfType with capacity Rings of that type
    for (int j = 0; j < capacity; j++) {
      Ring* ring = [Ring ringWithType:(RingType)i
                       leftParentNode:leftBatch
                      rightParentNode:rightBatch];
      [ringArrayOfType addObject:ring];
    }
  }
}

/* Deallocate the ring cache
 ******************************************************************************/
-(void) dealloc {
  CCLOG(@"RingCache dealloc %@", self);
  
  [[CCScheduler sharedScheduler] unscheduleUpdateForTarget:self];

  [ringArray release];
  [super dealloc];
}

/* Initialize how frequently the rings will spawn
 ******************************************************************************/
-(void) initSpawnFrequency
{
	if (spawnFrequency == nil)
	{
		spawnFrequency = [[CCArray alloc] initWithCapacity:RingType_MAX];
		[spawnFrequency insertObject:[NSNumber numberWithInt:80] atIndex:RingTypeSmall];
		//[spawnFrequency insertObject:[NSNumber numberWithInt:260] atIndex:RingType];
		//[spawnFrequency insertObject:[NSNumber numberWithInt:1500] atIndex:RingType];
		
		// spawn one ring immediately
		//[self spawn];
	}
}

/* Deterimine the spawn frequency for the given ring type
 ******************************************************************************/
+(int) getSpawnFrequencyForRingType:(RingType)ringType {
  
  if ((ringType < 0) || (ringType >= RingType_MAX)) {
    [NSException exceptionWithName:@"RingCacheException" reason:@"invalid ring type" userInfo:nil];
  }
  
	NSNumber* number = [spawnFrequency objectAtIndex:ringType];
	return [number intValue];
}

/* Spawn a ring of a particular type
 ******************************************************************************/
-(void) spawnRingOfType:(RingType)ringType {
  
  CCArray* ringArrayOfType = [ringArray objectAtIndex:ringType];
	
  Ring* ring;
  CCARRAY_FOREACH(ringArrayOfType, ring) {
    // find the first free ring and respawn it
    if (ring.rightSprite.visible == NO) {
      //CCLOG(@"RingCache spawnRingOfType: %i", ringType);
      [ring spawn];
      break;
    }
  }
}

/* Determine if an npc is passing through a ring
 ******************************************************************************/
-(void) checkForCollisions {
  BlowholeLayer* blowholeLayer = [BlowholeLayer sharedLayer];
  NPCCache* npcCache = [blowholeLayer npcCache];
  
  CCArray* ringArrayOfType;
  CCARRAY_FOREACH(ringArray, ringArrayOfType) {
    Ring* ring;
    CCARRAY_FOREACH(ringArrayOfType, ring) {
      if (ring.rightSprite.visible) {
        
        // create a rectangle bounded by the area enclosed by (but not
        // including) the ring's bodies
        float radiusInMeters =
          ring.topBody->GetFixtureList()[0].GetShape()->m_radius;
        float radius = radiusInMeters * PTM_RATIO;
        CGRect rect = CGRectMake(ring.rightSprite.positionLeft - radius,
                                 ring.rightSprite.positionBottom + radius * 2.0f,
                                 radius * 2.0f,
                                 ring.rightSprite.height - radius * 4.0f);
        
        if ([npcCache isNPCInRect:rect]
            && ([blowholeLayer getChildByTag:BlowholeLayerNodeTagScoreParticle] == nil)) {
          CCLOG(@"RingCache checkForCollisions hit");
          CGPoint position = CGPointMake(ring.rightSprite.positionLeft,
                                         ring.rightSprite.position.y);
          [blowholeLayer addParticleWithFile:@"score_particle.plist"
                                  atPosition:position
                                  withFactor:1.0f
                                     withTag:BlowholeLayerNodeTagScoreParticle];
          
          blowholeLayer.score += 100;
          [blowholeLayer.scoreLabel setString:[NSString stringWithFormat:@"%i",
                                               blowholeLayer.score]];
          break;
        }
      }
    }
  }
}

/* Handle periodic spawning and checking for collisions
 ******************************************************************************/
-(void) update:(ccTime)delta {
  
  updateCount++;
  
  for (int i = RingType_MAX - 1; i >= 0; i--) {
    int frequency = [RingCache getSpawnFrequencyForRingType:(RingType)i];
		
    if (updateCount % frequency == 0) {
      [self spawnRingOfType:(RingType)i];
      break;
    }
  }
	
  [self checkForCollisions];
}

@end

//
//  BlowholeLayer.mm
//  Blowhole
//
//  Created by Jeffrey Cole on 4/23/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//
// test
#import "BlowholeLayer.h"
#import "InputLayer.h"
#import "NPC.h"
#import "ParallaxBackground.h"
#import "RingCache.h"

@interface BlowholeLayer (PrivateMethods)
-(void) setupWorld;
@end

@implementation BlowholeLayer

@synthesize player, world, npcCache, scoreLabel, score;

// static global variables
static BlowholeLayer* blowholeLayerInstance;
static CGRect screenRect;
static float waterLevel;

/* Get the shared semi-singleton layer
 ******************************************************************************/
+(BlowholeLayer*) sharedLayer {
  return blowholeLayerInstance;
}

/* Get a rectangle representing the screen
 ******************************************************************************/
+(CGRect) screenRect {
  return screenRect;
}

/* Get the y position of the water level
 ******************************************************************************/
+(float) waterLevel {
  return waterLevel;
}

/* Get the shared sprite batch
 ******************************************************************************/
-(CCSpriteBatchNode*) getSpriteBatch {
	return (CCSpriteBatchNode*)[self getChildByTag:BlowholeLayerNodeTagSpriteBatch];
}

/* Static scene initializer
 ******************************************************************************/
+(CCScene *) scene {
  
  CCScene *scene = [CCScene node];
  BlowholeLayer *layer = [BlowholeLayer node];
  [scene addChild:layer];
  InputLayer* inputLayer = [InputLayer node];
	[scene addChild:inputLayer z:1 tag:BlowholeLayerNodeTagInputLayer];
	
  return scene;
}

/* Layer initializer
 ******************************************************************************/
-(id) init {

  if( (self=[super init])) {
    
    blowholeLayerInstance = self;
    self.isTouchEnabled = YES;
		
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    screenRect = CGRectMake(0, 0, screenSize.width, screenSize.height);
    CCLOG(@"Screen width %0.2f screen height %0.2f", screenSize.width, screenSize.height);
    
    waterLevel = screenSize.height * WATER_LEVEL_RATIO;
		
    [self setupWorld];
		
    // load all of the game's artwork up front
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:
     [Utility platformCoordsWithName:@"art"]];

    ParallaxBackground* background = [ParallaxBackground node];
		[self addChild:background];
    
    score = 0;
    scoreLabel = [CCLabelBMFont labelWithString:@"0"
                                        fntFile:[Utility platformFontWithName:@"score"]];
    scoreLabel.position = CGPointMake(screenSize.width - screenSize.width * 0.025,
                                      screenSize.height);
		scoreLabel.anchorPoint = CGPointMake(1.0f, 1.0f);
		[self addChild:scoreLabel];
    
    // this BlowholeLayer sprite batch will hold the launched entities
    NSString* fileName = [Utility platformImageWithName:@"art"];
    CCSpriteBatchNode* batch = [CCSpriteBatchNode batchNodeWithFile:fileName
                                                           capacity:150];
    [self addChild:batch z:1 tag:BlowholeLayerNodeTagSpriteBatch];
    
    // needs to be a direct child of the layer (not the batch node) because
    // we're adding non-CCSprite's as children, which is not supported when
    // using CCSpriteBatchNode
    player = [Player playerWithParentNode:self];
    CGPoint playerPos = CGPointMake(screenSize.width * 0.5f,
                                    player.sprite.halfHeight);
    [player setPosition:playerPos];
    
    npcCache = [NPCCache cache];
		[self addChild:npcCache z:0 tag:BlowholeLayerNodeTagNPCCache];
    
    //RingCache* ringCache =
      [RingCache cache];
    
    [Utility preloadParticleEffect:@"blow_particle.plist"];
    [Utility preloadParticleEffect:@"splash_particle.plist"];
    [Utility preloadParticleEffect:@"score_particle.plist"];
		
    [self schedule: @selector(update:)];
  }
  return self;
}

/* Deallocate the layer
 ******************************************************************************/
- (void) dealloc {
  CCLOG(@"BlowholeLayer dealloc %@", self);
  
  delete world;
  world = NULL;
	
  delete debugDraw;
  
  blowholeLayerInstance = nil;
  
  // don't forget to call "super dealloc"
  [super dealloc];
}

/* Set up the physics world
 ******************************************************************************/
-(void) setupWorld {
  // Define the gravity vector.
  b2Vec2 gravity;
  gravity.Set(0.0f, -10.0f);
  
  // Do we want to let bodies sleep?
  // This will speed up the physics simulation
  bool doSleep = true;
  
  // Construct a world object, which will hold and simulate the rigid bodies.
  world = new b2World(gravity, doSleep);
  world->SetContinuousPhysics(true);
  
  // Debug Draw functions
  debugDraw = new GLESDebugDraw( PTM_RATIO );
  world->SetDebugDraw(debugDraw);
  
  uint32 flags = 0;
  flags += b2DebugDraw::e_shapeBit;
  //		flags += b2DebugDraw::e_jointBit;
  //		flags += b2DebugDraw::e_aabbBit;
  //		flags += b2DebugDraw::e_pairBit;
  //		flags += b2DebugDraw::e_centerOfMassBit;
  debugDraw->SetFlags(flags);}

/* Scheduled time update hander
 ******************************************************************************/
-(void) update:(ccTime)delta {
  // Instruct the world to perform a single step of simulation. We are using a
  // semi-fixed timestep.
  // http://gafferongames.com/game-physics/fix-your-timestep/
	
  int32 velocityIterations = 8;
  int32 positionIterations = 1;
	
  float oneSixtieth = 1.0f / 60.0f;
  float step = delta < oneSixtieth ? delta : oneSixtieth;
  //CCLOG(@"BlowholeLayer update step = %f", step);
  world->Step(step, velocityIterations, positionIterations);
	
  //Iterate over the bodies in the physics world
  for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
    if (b->GetUserData() != NULL) {
      // tell entities to update themselves
      Entity* entity = (Entity*)b->GetUserData();
      if ([entity isKindOfClass:[Entity class]]) {
        [entity updatePhysics];
      }
    }
	}
}

/* Draw debugging data
 ******************************************************************************/
#ifdef DEBUG
-(void) draw {
  // Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
  // Needed states:  GL_VERTEX_ARRAY, 
  // Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
  glDisable(GL_TEXTURE_2D);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
  //world->DrawDebugData();
	
  // restore default GL states
  glEnable(GL_TEXTURE_2D);
  glEnableClientState(GL_COLOR_ARRAY);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}
#endif

@end

//
//  BlowholeLayer.h
//  Blowhole
//
//  Created by Jeffrey Cole on 4/23/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "Box2D.h"
#import "CCNodeCategory.h"
#import "CCSpriteCategory.h"
#import "cocos2d.h"
#import "GLES-Render.h"
#import "Player.h"
#import "NPCCache.h"
#import "Utility.h"

typedef enum {
  BlowholeLayerNodeTagInputLayer = 0,
  BlowholeLayerNodeTagSpriteBatch,
  BlowholeLayerNodeTagNPCCache,
  BlowholeLayerNodeTagScoreParticle,
  
  BlowholeLayerNodeTag_MAX
} BlowholeLayerNodeTag;

// BlowholeLayer
@interface BlowholeLayer : CCLayer
{
  GLESDebugDraw* debugDraw;
  Player* player;
  b2World* world;
  NPCCache* npcCache;
  CCLabelBMFont* scoreLabel;
	int score;
}

@property (readonly) Player* player;
@property (readonly) b2World* world;
@property (readonly) NPCCache* npcCache;
@property (readonly) CCLabelBMFont* scoreLabel;
@property int score;

+(CCScene *) scene;
+(BlowholeLayer*) sharedLayer;
+(CGRect) screenRect;
+(float) waterLevel;

-(CCSpriteBatchNode*) getSpriteBatch;

@end

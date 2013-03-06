//
//  NPCCache.h
//  Blowhole
//
//  Created by Jeffrey Cole on 4/30/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"

@interface NPCCache : CCNode 
{
  CCSpriteBatchNode* batch;
  CCArray* npcArray;
	
  int updateCount;
}

+(id) cache;
-(BOOL) isNPCInRect:(CGRect)rect;

@end

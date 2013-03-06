//
//  RingCache.h
//  Blowhole
//
//  Created by Jeffrey Cole on 5/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"

@interface RingCache : NSObject 
{
  CCSpriteBatchNode* leftBatch;
  CCSpriteBatchNode* rightBatch;
  CCArray* ringArray;
	
  int updateCount;
}

+(id) cache;

@end

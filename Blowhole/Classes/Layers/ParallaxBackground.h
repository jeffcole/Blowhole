//
//  ParallaxBackground.m
//  Blowhole
//
//  Created by Jeffrey Cole on 5/8/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"

@interface ParallaxBackground : CCNode 
{
	CCSpriteBatchNode* spriteBatch;

	int numLayers;

	CCArray* speedFactors;
	float scrollSpeed;

	CGSize screenSize;
}

@end

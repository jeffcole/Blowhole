//
//  Entity.h
//  Blowhole
//
//  Created by Jeffrey Cole on 4/23/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "Entity.h"
#import "BlowholeLayer.h"

@class BlowholeLayer;
@implementation Entity

/* Set the Entity's sprite's position while keeping it within the screen
 ******************************************************************************/
-(void) setPosition:(CGPoint)pos
{
	// If the current position is (still) outside the screen no adjustments should be made!
	// This allows entities to move into the screen from outside.
	if (CGRectContainsRect([BlowholeLayer screenRect], [entitySprite boundingBox]))
	{
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		float halfWidth = entitySprite.contentSize.width * 0.5f;
		float halfHeight = entitySprite.contentSize.height * 0.5f;
		
		// Cap the position so the Ship's sprite stays on the screen
		if (pos.x < halfWidth)
		{
			pos.x = halfWidth;
		}
		else if (pos.x > (screenSize.width - halfWidth))
		{
			pos.x = screenSize.width - halfWidth;
		}
		
		if (pos.y < halfHeight)
		{
			pos.y = halfHeight;
		}
		else if (pos.y > (screenSize.height - halfHeight))
		{
			pos.y = screenSize.height - halfHeight;
		}
	}
	
	[entitySprite setPosition:pos];
}

@end
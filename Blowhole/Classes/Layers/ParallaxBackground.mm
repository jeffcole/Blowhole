//
//  ParallaxBackground.mm
//  Blowhole
//
//  Created by Jeffrey Cole on 5/8/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "ParallaxBackground.h"
#import "Utility.h"


@implementation ParallaxBackground

-(id) init {
  
  if ((self = [super init])) {
    
    // The screensize never changes during gameplay, so we can cache it in a member variable.
    screenSize = [[CCDirector sharedDirector] winSize];
		
    // Get the game's texture atlas texture by adding it. Since it's added already it will simply return 
    // the CCTexture2D associated with the texture atlas.
    //NSString* imageName = [Utility platformImageWithName:@"art"];
    NSString* imageName = @"art.png";
    CCTexture2D* gameArtTexture = [[CCTextureCache sharedTextureCache] addImage:imageName];
		
    // Create the background spritebatch
    spriteBatch = [CCSpriteBatchNode batchNodeWithTexture:gameArtTexture];
    [self addChild:spriteBatch];
    
    numLayers = 5;
		
    // Add the 4 different layers and position them on the screen
    for (int i = 0; i < numLayers; i++) {
      //NSString* frameName = [Utility platformImageWithName:
      //                       [NSString stringWithFormat:@"bg%i", i]];
      NSString* frameName = [NSString stringWithFormat:@"bg%i.png", i];
      CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:frameName];
      sprite.anchorPoint = CGPointMake(0, 0.5f);
      sprite.position = CGPointMake(0, screenSize.height / 2);
      [spriteBatch addChild:sprite z:i tag:i];
		}
    
    // Add 4 more layers, flip them and position them next to their neighbor stripe
    for (int i = 0; i < numLayers; i++) {
      //NSString* frameName = [Utility platformImageWithName:
      //                       [NSString stringWithFormat:@"bg%i", i]];
      NSString* frameName = [NSString stringWithFormat:@"bg%i.png", i];
      CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:frameName];
			
      // Position the new sprite one screen width to the right
      sprite.anchorPoint = CGPointMake(0, 0.5f);
      sprite.position = CGPointMake(screenSize.width - 1, screenSize.height / 2);
      
      // Flip the sprite so that it aligns perfectly with its neighbor
      sprite.flipX = YES;
			
      // Add the sprite using the same tag offset by numLayers
      [spriteBatch addChild:sprite z:i tag:i + numLayers];
		}
		
    // Initialize the array that contains the scroll factors for individual layers.
    speedFactors = [[CCArray alloc] initWithCapacity:numLayers];
    [speedFactors addObject:[NSNumber numberWithFloat:0.0f]];
    [speedFactors addObject:[NSNumber numberWithFloat:0.05f]];
    [speedFactors addObject:[NSNumber numberWithFloat:0.1f]];
    [speedFactors addObject:[NSNumber numberWithFloat:0.2f]];
    [speedFactors addObject:[NSNumber numberWithFloat:0.3f]];
    
    if ([speedFactors count] != numLayers) {
      [NSException exceptionWithName:@"ParalaxBackgroundException" 
                              reason:@"speedFactors count does not equal numLayers"
                            userInfo:nil];
    }
    
    scrollSpeed = 1.0f;
    [self scheduleUpdate];
	}
	
  return self;
}

-(void) dealloc
{
  [speedFactors release];
  [super dealloc];
}

-(void) update:(ccTime)delta
{
  CCSprite* sprite;
  CCARRAY_FOREACH([spriteBatch children], sprite)
	{
    //CCLOG(@"tag: %i", sprite.tag);
    NSNumber* factor = [speedFactors objectAtIndex:sprite.zOrder];
		
    CGPoint pos = sprite.position;
    pos.x -= scrollSpeed * [factor floatValue];
		
    // Reposition layers when they're out of bounds
    if (pos.x < -screenSize.width)
		{
      pos.x += (screenSize.width * 2) - 2;
		}
		
    sprite.position = pos;
	}
}

@end

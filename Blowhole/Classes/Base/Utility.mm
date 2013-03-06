//
//  Utility.h
//  Blowhole
//
//  Created by Jeffrey Cole on 4/29/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "Utility.h"

@implementation Utility

// convenience method to convert a CGPoint to a b2Vec2
+(b2Vec2) toMeters:(CGPoint)point
{
	return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

// convenience method to convert a b2Vec2 to a CGPoint
+(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

+(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

+(CGPoint) locationFromTouches:(NSSet*)touches
{
	return [self locationFromTouch:[touches anyObject]];
}

+(CGPoint) screenCenter
{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	return CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);
}

+(NSString*) platformFontWithName:(NSString*)name {
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    return [NSString stringWithFormat:@"%@_iPad.fnt", name];
  } else {
    return [NSString stringWithFormat:@"%@.fnt", name];
  }
}

+(NSString*) platformCoordsWithName:(NSString*)name {
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    return [NSString stringWithFormat:@"%@_iPad.plist", name];
  } else {
    return [NSString stringWithFormat:@"%@.plist", name];
  }
}

+(NSString*) platformImageWithName:(NSString*)name {
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    return [NSString stringWithFormat:@"%@_iPad.png", name];
  } else {
    return [NSString stringWithFormat:@"%@.png", name];
  }
}

+(void) logCGPoint:(CGPoint)point named:(NSString*)name {
  CCLOG(@"%@ = (%f, %f)", name, point.x, point.y);
}

+(void) preloadParticleEffect:(NSString*)particleFile {
  [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:particleFile];
}

@end

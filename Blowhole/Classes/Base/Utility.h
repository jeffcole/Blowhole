//
//  Utility.mm
//  Blowhole
//
//  Created by Jeffrey Cole on 4/29/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "cocos2d.h"
#import "Constants.h"

@interface Utility : NSObject {}

+(b2Vec2) toMeters:(CGPoint)point;
+(CGPoint) toPixels:(b2Vec2)vec;

+(CGPoint) locationFromTouch:(UITouch*)touch;
+(CGPoint) locationFromTouches:(NSSet*)touches;

+(CGPoint) screenCenter;

+(NSString*) platformCoordsWithName:(NSString*)name;
+(NSString*) platformImageWithName:(NSString*)name;
+(NSString*) platformFontWithName:(NSString*)name;

+(void) logCGPoint:(CGPoint)point named:(NSString*)name;

+(void) preloadParticleEffect:(NSString*)particleFile;

@end

//
//  IntensityBar.mm
//  Blowhole
//
//  Created by Jeffrey Cole on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BlowholeLayer.h"
#import "InputLayer.h"
#import "IntensityBar.h"

@interface Player (PrivateMethods)
-(id) initWithParentNode:(CCNode*)parentNode;
-(void) firstUpdate;
-(float) factorWithTouch:(UITouch*)touch;
@end

@implementation IntensityBar

@synthesize gauge;

/* Static autorelease initializer for intensity bar
 ******************************************************************************/
+(id) intensityBarWithParentNode:(CCNode*)parentNode {
  return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

/* Initialize an intensity bar instance
 ******************************************************************************/
-(id) initWithParentNode:(CCNode*)parentNode {
  if ((self = [super init])) {
    inputLayer = (InputLayer*)parentNode;
    
    NSString* frameName = [Utility platformImageWithName:@"intensity_bar"];
    [super createSpriteWithFrameName:frameName parentNode:parentNode];
    
    CGSize screenSize = [BlowholeLayer screenRect].size;
    CGPoint pos = CGPointMake(screenSize.width
                              - sprite.halfWidth - sprite.halfWidth * 0.5f,
                              sprite.halfHeight + sprite.halfHeight * 0.25f);
    sprite.position = pos;
    sprite.opacity = 98;
    
    // this doesn't work (uses entire cache texture?)
//    gauge = [CCProgressTimer progressWithTexture:
//             [[CCSpriteFrameCache sharedSpriteFrameCache]
//              spriteFrameByName:@"intensity_bar.png"].texture];
    gauge = [CCProgressTimer progressWithFile:frameName];
    gauge.type = kCCProgressTimerTypeVerticalBarBT;
    gauge.position = pos;
    gauge.percentage = 0;
    [inputLayer addChild:gauge z:1];
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];
  }
  return self;
}

/* Deallocate the intensity bar
 ******************************************************************************/
-(void) dealloc {
  CCLOG(@"IntensityBar dealloc %@", self);
  
  [[CCScheduler sharedScheduler] unscheduleUpdateForTarget:self];
  [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
  
  [super dealloc];
}

/* Start the chain of scheduled update handlers with an initial wait interval
 ******************************************************************************/
-(void) scheduleUpdates {
  CCScheduler* scheduler = [CCScheduler sharedScheduler];
  
  // unschedule all selectors
  [scheduler unscheduleAllSelectorsForTarget:self];
  
  [scheduler scheduleSelector:@selector(firstUpdate)
                                        forTarget:self 
                                         interval:1.0f
                                           paused:NO];
}

/* First update handler called after an initial interval
 ******************************************************************************/
-(void) firstUpdate {
  CCScheduler* scheduler = [CCScheduler sharedScheduler];

  // unschedule all selectors
  [scheduler unscheduleAllSelectorsForTarget:self];

  // schedule the normal update handler
  [scheduler scheduleUpdateForTarget:self priority:0 paused:NO];
}

/* Scheduled time update handler
 ******************************************************************************/
-(void) update:(ccTime)delta {
  if (gauge.percentage >= 0.000001f) {
    gauge.percentage -= delta * 100;
  } else {
    [[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget:self];
  }
}

/* The portion of the intensity bar covered by a touch
 ******************************************************************************/
-(float) factorWithTouch:(UITouch*)touch {
  CGPoint touchLocation = [Utility locationFromTouch:touch];
  float distance = touchLocation.y - sprite.positionBottom;
  float factor = distance / sprite.height;
  if (factor > 1.0f) factor = 1.0f;
  if (factor < 0.0f) factor = 0.0f;
  return factor;
}

/* Touch began delegate
 ******************************************************************************/
-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event {
  
  // Check if this touch is on the bar's sprite.
  CGPoint touchLocation = [Utility locationFromTouch:touch];
  BOOL isTouchHandled = CGRectContainsPoint([sprite boundingBox], touchLocation);
  if (isTouchHandled) {
    [inputLayer updateGaugeWithFactor:[self factorWithTouch:touch]];
  }
  
  return isTouchHandled;
}

/* Touch moved delegate
 ******************************************************************************/
- (void)ccTouchMoved:(UITouch*)touch withEvent:(UIEvent*)event {
  [inputLayer updateGaugeWithFactor:[self factorWithTouch:touch]];
}

/* Touch ended delegate
 ******************************************************************************/
- (void)ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event {
  float factor = [self factorWithTouch:touch];
  [inputLayer updateGaugeWithFactor:factor];
  [inputLayer sendLaunchWithFactor:factor];
  CCLOG(@"IntensityBar ccTouchEnded factor = %f", factor);
}

/* Touch cancelled delegate
 ******************************************************************************/
- (void)ccTouchCancelled:(UITouch*)touch withEvent:(UIEvent*)event {
  [self ccTouchEnded:touch withEvent:event];
}

@end

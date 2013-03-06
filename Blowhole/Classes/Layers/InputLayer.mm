//
//  InputLayer.mm
//  Blowhole
//
//  Created by Jeffrey Cole on 5/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "BlowholeLayer.h"
#import "InputLayer.h"

@interface InputLayer (PrivateMethods)
-(void) addJoystick;
-(void) addIntensityBar;
@end

@implementation InputLayer

/* Initialize an input layer instance
 ******************************************************************************/
-(id) init {
  if ((self = [super init])) {
    [self addIntensityBar];
    [self addJoystick];
		
    [self scheduleUpdate];
  }
	
  return self;
}

/* Deallocate the input layer
 ******************************************************************************/
-(void) dealloc {
  CCLOG(@"InputLayer dealloc %@", self);
  [super dealloc];
}

/* Add the joystick
 ******************************************************************************/
-(void) addJoystick {

  float stickRadius = 37.5;

  joystick = [SneakyJoystick joystickWithRect:CGRectMake(0, 0, stickRadius, stickRadius)];
  joystick.autoCenter = YES;
	
  SneakyJoystickSkinnedBase* skinStick = [SneakyJoystickSkinnedBase skinnedJoystick];
  skinStick.position = CGPointMake(stickRadius * 1.5f, stickRadius * 1.5f);
  skinStick.backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"circle_gray.png"];
  skinStick.backgroundSprite.color = ccWHITE;
  skinStick.backgroundSprite.opacity = 98;
  
  skinStick.thumbSprite = [CCSprite spriteWithSpriteFrameName:@"circle_gray.png"];
  skinStick.thumbSprite.scale = 0.5f;
  skinStick.thumbSprite.color = ccc3(180, 244, 23);;
  skinStick.thumbSprite.opacity = 98;
  skinStick.joystick = joystick;
  
  [self addChild:skinStick];
}

/* Add the intensity bar
 ******************************************************************************/
-(void) addIntensityBar {
  intensityBar = [IntensityBar intensityBarWithParentNode:self];
}

/* Check if the player has an entity attached before updating the intensity
 * bar's gauge
 ******************************************************************************/
-(void) updateGaugeWithFactor:(float)factor {
  Player* player = [[BlowholeLayer sharedLayer] player];
  if (player.attachedEntity != nil) {
    intensityBar.gauge.percentage = factor * 100;
  }
}

/* Send a launch message to the player
 ******************************************************************************/
-(void) sendLaunchWithFactor:(float)factor {
  Player* player = [[BlowholeLayer sharedLayer] player];
  if (player.attachedEntity != nil) {
    [player launchAttachedWithFactor:factor velocityX:joystick.velocity.x];
    [intensityBar scheduleUpdates];
  }
}

/* Scheduled time update hander
 ******************************************************************************/
-(void) update:(ccTime)delta {

  totalTime += delta;
	
  // moving the player with the thumbstick
  Player* player = [[BlowholeLayer sharedLayer] player];
	
  CGPoint velocity = ccpMult(joystick.velocity, 200);
  if (velocity.x != 0 && velocity.y != 0) {

    CGPoint pPos = player.sprite.position;
    CGPoint position = CGPointMake(pPos.x + velocity.x * delta,
                                   pPos.y + velocity.y * delta);
    [player setPosition:position];
  }
}

@end

//
//  InputLayer.h
//  Blowhole
//
//  Created by Jeffrey Cole on 5/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"

// SneakyInput headers
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"

#import "SneakyCategories.h"
#import "IntensityBar.h"

@interface InputLayer : CCLayer  {
  SneakyJoystick* joystick;
  IntensityBar* intensityBar;
	
  ccTime totalTime;
  ccTime nextShotTime;
}

-(void) updateGaugeWithFactor:(float)factor;
-(void) sendLaunchWithFactor:(float)factor;

@end

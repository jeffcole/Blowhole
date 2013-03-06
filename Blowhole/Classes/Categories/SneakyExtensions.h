//
//  SneakyExtensions.h
//  Blowhole
//
//  Created by Jeffrey Cole on 5/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


#import <Foundation/Foundation.h>

// SneakyInput headers
#import "ColoredCircleSprite.h"
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"

@interface SneakyButton (Extension)
+(id) button;
+(id) buttonWithRect:(CGRect)rect;
@end

@interface SneakyButtonSkinnedBase (Extension)
+(id) skinnedButton;
@end

@interface SneakyJoystick (Extension)
+(id) joystickWithRect:(CGRect)rect;
@end

@interface SneakyJoystickSkinnedBase (Extension)
+(id) skinnedJoystick;
@end


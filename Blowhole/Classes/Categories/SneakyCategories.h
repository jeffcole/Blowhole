//
//  SneakyCategories.h
//  Blowhole
//
//  Created by Jeffrey Cole on 5/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

// SneakyInput headers
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"

@interface SneakyJoystick (Category)
+(id) joystickWithRect:(CGRect)rect;
@end

@interface SneakyJoystickSkinnedBase (Category)
+(id) skinnedJoystick;
@end


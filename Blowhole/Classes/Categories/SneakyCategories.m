//
//  SneakyCategories.m
//  Blowhole
//
//  Created by Jeffrey Cole on 5/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "SneakyCategories.h"

@implementation SneakyJoystick (Category)
+(id) joystickWithRect:(CGRect)rect
{
	return [[[SneakyJoystick alloc] initWithRect:rect] autorelease];
}
@end

@implementation SneakyJoystickSkinnedBase (Category)
+(id) skinnedJoystick
{
	return [[[SneakyJoystickSkinnedBase alloc] init] autorelease];
}
@end


//
//  CCSpriteCategories.h
//  Blowhole
//
//  Created by Jeffrey Cole on 5/25/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"

@interface CCSprite (Category)
-(float) height;
-(float) width;

-(float) halfHeight;
-(float) halfWidth;

-(float) positionTop;
-(float) positionRight;
-(float) positionBottom;
-(float) positionLeft;
@end

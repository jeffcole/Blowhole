//
//  IntensityBar.h
//  Blowhole
//
//  Created by Jeffrey Cole on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@class InputLayer;

@interface IntensityBar : Entity <CCTargetedTouchDelegate> {
  InputLayer* inputLayer;
  CCProgressTimer* gauge;
}

@property(retain, nonatomic) CCProgressTimer* gauge;

+(id) intensityBarWithParentNode:(CCNode*)parentNode;
-(void) scheduleUpdates;

@end

//
//  CCNodeCategory.h
//  Blowhole
//
//  Created by Jeffrey Cole on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface CCNode (Category)
-(void) addParticleWithFile:(NSString*)file
                 atPosition:(CGPoint)position
                 withFactor:(float)factor
                    withTag:(int)tag;
@end

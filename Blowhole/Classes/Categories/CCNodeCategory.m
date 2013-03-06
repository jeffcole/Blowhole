//
//  CCNodeCategory.m
//  Blowhole
//
//  Created by Jeffrey Cole on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCNodeCategory.h"

@implementation CCNode (Category)

/* Create and add a particle effect system
 ******************************************************************************/
-(void) addParticleWithFile:(NSString*)file
                 atPosition:(CGPoint)position
                 withFactor:(float)factor
                    withTag:(int)tag {
  
  CCParticleSystem* sys = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:file];
  sys.positionType = kCCPositionTypeFree;
  sys.autoRemoveOnFinish = YES;
  sys.speed *= factor;
  sys.duration *= factor;
  sys.position = [self convertToNodeSpace:position];
  
  [self addChild:sys z:0 tag:tag];  
}

@end

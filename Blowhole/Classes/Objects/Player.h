//
//  Player.h
//  Blowhole
//
//  Created by Jeffrey Cole on 4/25/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"
#import "Entity.h"

@interface Player : Entity {
  Entity* attachedEntity;
}

@property (readonly) Entity* attachedEntity;

+(id) playerWithParentNode:(CCNode*)parentNode;
-(void) addChild:(Entity*)childEntity;
-(void) collidedWith:(Entity*)entity;
-(void) launchAttachedWithFactor:(float)factor velocityX:(float)velocityX;

@end

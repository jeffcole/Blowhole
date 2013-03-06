//
//  PlayerEntity.h
//  Blowhole
//
//  Created by Jeffrey Cole on 4/25/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"
#import "Entity.h"

@interface PlayerEntity : Entity {
    Entity* attachedEntity;
}

@property (readonly) Entity* attachedEntity;

+(id) player;

@end

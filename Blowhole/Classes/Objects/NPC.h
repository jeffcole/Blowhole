//
//  NPC.h
//  Blowhole
//
//  Created by Jeffrey Cole on 4/29/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"
#import "Entity.h"

typedef enum {
  NPCTypeSeal = 0,
  
  NPCType_MAX
} NPCType;


@interface NPC : Entity {
  NPCType type;
  BOOL hasBreached;
  BOOL hasReentered;
}

@property (readonly) NPCType type;
@property (readonly) BOOL hasReentered;

+(id) npcWithType:(NPCType)npcType
       parentNode:(CCNode*)parentNode;

// sent by Player
-(void) createBody;
// sent by NPCCache
-(void) spawn;

@end

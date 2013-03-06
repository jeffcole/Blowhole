//
//  Ring.h
//  Blowhole
//
//  Created by Jeffrey Cole on 5/11/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "Box2D.h"
#import "cocos2d.h"

typedef enum {
  RingTypeSmall = 0,
  
  RingType_MAX
} RingType;

@interface Ring : NSObject {
  RingType  type;
  CCNode*   leftParent;
  CCNode*   rightParent;
  CCSprite* leftSprite;
  CCSprite* rightSprite;
  b2Body*   topBody;
  b2Body*   bottomBody;
  CGPoint   velocity;
}

@property(readonly) RingType type;
// parents are synthesized; retained due to attribute
@property (retain, nonatomic) CCNode* leftParent;
@property (retain, nonatomic) CCNode* rightParent;
@property (readonly) CCSprite* leftSprite;
@property (readonly) CCSprite* rightSprite;
@property (readonly) b2Body* topBody;
@property (readonly) b2Body* bottomBody;

+(id) ringWithType:(RingType)ringType
    leftParentNode:(CCNode*)leftParentNode
   rightParentNode:(CCNode*)rightParentNode;

// sent by RingCache
-(void) spawn;

@end

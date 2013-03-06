//
//  Entity.h
//  Blowhole
//
//  Created by Jeffrey Cole on 4/23/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "Box2D.h"
#import "cocos2d.h"

@interface Entity : NSObject {
  CCNode*   parent;
  CCSprite* sprite;
  b2Body*   body;
  BOOL      isAttached;
  BOOL      hasBeenLaunched;
}

// parent is synthesized, retained due to attribute
@property (retain, nonatomic) CCNode* parent;
@property (readonly) CCSprite* sprite;
@property (readonly) b2Body*   body;
@property BOOL isAttached;
@property BOOL hasBeenLaunched;

-(void) createSpriteWithFrameName:(NSString*)frameName
                       parentNode:(CCNode*)parentNode;
-(void) createBody;
-(void) createBodyWithBodyDef:(b2BodyDef*)bodyDef
                   fixtureDef:(b2FixtureDef*)fixtureDef;
-(void) setPosition:(CGPoint)pos;
-(void) setInvisible;
-(void) setVisible;
-(void) updatePhysics;
-(void) removeSpriteFromParent;
-(void) removeSprite;
-(void) removeBody;

@end

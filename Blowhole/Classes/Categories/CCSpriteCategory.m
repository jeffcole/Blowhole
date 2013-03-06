//
//  CCSpriteCategories.m
//  Blowhole
//
//  Created by Jeffrey Cole on 5/25/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "CCSpriteCategory.h"

@implementation CCSprite (Category)

-(float) height {
    return self.contentSize.height;
}

-(float) width {
    return self.contentSize.width;
}

-(float) halfHeight {
    return self.contentSize.height * 0.5f;
}

-(float) halfWidth {
    return self.contentSize.width * 0.5f;
}

-(float) positionTop {
    return self.position.y + self.contentSize.height * 0.5f;
}

-(float) positionRight {
    return self.position.x + self.contentSize.width * 0.5f;
}

-(float) positionBottom {
    return self.position.y - self.contentSize.height * 0.5f;
}

-(float) positionLeft {
    return self.position.x - self.contentSize.width * 0.5f;
}

@end

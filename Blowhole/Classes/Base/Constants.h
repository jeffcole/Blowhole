//
//  Constants.h
//  Blowhole
//
//  Created by Jeffrey Cole on 4/29/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// The ratio of water height to total screen height
#define WATER_LEVEL_RATIO 0.3333f

//
//  GameConfig.h
//  Blowhole
//
//  Created by Jeffrey Cole on 4/23/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

//
// Define here the type of autorotation that you want for your game
//
// For iPhone 3GS and newer, slow on older devices
//#define GAME_AUTOROTATION kGameAutorotationUIViewController
// For iPhone 3G and older (runs better)
#define GAME_AUTOROTATION kGameAutorotationCCDirector
//#define GAME_AUTOROTATION kGameAutorotationNone

#endif // __GAME_CONFIG_H
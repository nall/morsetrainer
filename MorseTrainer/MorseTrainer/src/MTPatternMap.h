//
//  MTPatternMap.h
//  MorseTrainer
//
//  Created by Jon Nall on 7/28/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MTPatternMap : NSObject
{
	NSMutableArray* patternArray;
}

// Public static
+(MTPatternMap*)instance;
+(NSString*)getPatternForCharacter:(NSString*)key errorString:(NSString**)theErrorString;
+(NSUInteger)numChars;
+(NSArray*)characters;

+(NSDictionary*)dictForCharType:(NSUInteger)theType;

+(NSUInteger)parseProsign:(NSString*)theText atIndex:(NSUInteger)theIndex
			 finalProsign:(NSMutableString*)theProsign;

@end

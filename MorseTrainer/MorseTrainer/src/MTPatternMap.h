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
// Private
-(void)initLetters;
-(void)initNumbers;
-(void)initPunctuation;
-(void)initProsigns;

// Public static
+(MTPatternMap*)instance;
+(NSString*)getPattern:(NSString*)key;
+(NSUInteger)numChars;

+(NSUInteger)parseProsign:(NSString*)theText atIndex:(NSUInteger)theIndex
			 finalProsign:(NSMutableString*)theProsign;

@end

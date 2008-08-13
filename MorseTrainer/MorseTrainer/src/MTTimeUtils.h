//
//  MTTimeUtils.h
//  MorseTrainer
//
//  Created by Jon Nall on 7/28/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef struct TextAnalysis
{
	NSUInteger numNonPatternDitTimes;
	NSUInteger numPatternDitTimes;
	
	double msPerPatternDit;
	double msPerNonPatternDit;
} TextAnalysis;

@interface MTTimeUtils : NSObject
{

}

// Private

// Public Static
+(NSUInteger)charDits:(NSString*)character;
+(TextAnalysis)textDits:(NSString*)text;
+(TextAnalysis)analyzeText:(NSString*)theText
			 withActualWPM:(NSUInteger)actualWPM
		  withEffectiveWPM:(NSUInteger)effectiveWPM;

@end

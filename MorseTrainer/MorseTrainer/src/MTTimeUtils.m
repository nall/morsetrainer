//
//  MTTimeUtils.m
//  MorseTrainer
//
//  Created by Jon Nall on 7/28/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import "MTTimeUtils.h"
#import "MTPatternMap.h"
#include "MTDefines.h"
#include <wctype.h>

@implementation MTTimeUtils

+(NSUInteger)charDits:(NSString*)character
{
	NSString* pattern = [MTPatternMap getPatternForCharacter:character];
	NSUInteger chardits = 0;
	
	for(NSUInteger idx = 0; idx < [pattern length]; ++idx)
	{
		if(idx != 0)
		{
			chardits += INTER_PATTERN_DITS;
		}
		
		if([pattern characterAtIndex:idx] == '.')
		{
			chardits += DIT_DITS;
		}
		else if([pattern characterAtIndex:idx] == '-')
		{
			chardits += DAH_DITS;
		}
		else
		{
			NSLog(@"ERROR: Found non-dit/dah for letter %c",
				  [pattern characterAtIndex:idx]);
			exit(1);
		}
	}
	
	return chardits;
}

+(TextAnalysis)textDits:(NSString*)text
{
	TextAnalysis analysis = {0, 0};
	BOOL isFirstCharOfWord = YES;
	
	for(NSUInteger idx = 0; idx < [text length]; ++idx)
	{
		const unichar c = [text characterAtIndex:idx];
		if(iswspace(c))
		{
			analysis.numNonPatternDitTimes += INTER_PHRASE_DITS;
			isFirstCharOfWord = YES;
		}
		else
		{
			if(!isFirstCharOfWord)
			{
				analysis.numNonPatternDitTimes += INTER_WORD_DITS;
			}
			
			isFirstCharOfWord = NO;
			
			// Handle prosigns, which have the form: ^XX
			if([text characterAtIndex:idx] == '^')
			{
				NSMutableString* prosign = [NSMutableString string];
				
				idx = [MTPatternMap parseProsign:text atIndex:idx finalProsign:prosign];
				
				analysis.numPatternDitTimes += [self charDits:prosign];
			}
			else{
				analysis.numPatternDitTimes += [self charDits:[text substringWithRange:NSMakeRange(idx, 1)]];
			}			
		}		
	}
	
	return analysis;	
}

+(TextAnalysis)analyzeText:(NSString*)theText
			 withActualWPM:(NSUInteger)actualWPM
		  withEffectiveWPM:(NSUInteger)effectiveWPM
{
	// Get the number of dit times
	TextAnalysis analysis = [MTTimeUtils textDits:theText];
	analysis.numNonPatternDitTimes += INTER_PHRASE_DITS;
	
	// Determine the per-dit ms at actual speed -- this is how fast we send
	// characters
	double totalDitTimes = analysis.numPatternDitTimes + analysis.numNonPatternDitTimes;
	double actualDitMS = 60000. / (actualWPM * totalDitTimes);
	
	// Subtract out the time spent doing dits at that speed
	double effectiveTimePerPhrase = 60000. / effectiveWPM;
	double timeSpentInSpaces = effectiveTimePerPhrase - (actualDitMS * analysis.numPatternDitTimes);
	
	// Now determine the space timing so as to achieve the effective WPM
	double effectiveDitMS = timeSpentInSpaces / (double)analysis.numNonPatternDitTimes;

	analysis.msPerPatternDit = actualDitMS;
	analysis.msPerNonPatternDit = effectiveDitMS;
	
	return analysis;
}

@end

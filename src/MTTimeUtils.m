//
// MTTimeUtils.m
//
// AD5RX Morse Trainer
// Copyright (c) 2008 Jon Nall
// All rights reserved.
//
// LICENSE
// This file is part of AD5RX Morse Trainer.
// 
// AD5RX Morse Trainer is free software: you can redistribute it and/or
// modify it under the terms of the GNU General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
// 
// AD5RX Morse Trainer is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with AD5RX Morse Trainer.  If not, see <http://www.gnu.org/licenses/>.




#import "MTTimeUtils.h"
#import "MTPatternMap.h"
#include "MTDefines.h"
#include <wctype.h>

@implementation MTTimeUtils

+(NSUInteger)charDits:(NSString*)character
{
	NSString* pattern = [MTPatternMap getPatternForCharacter:character errorString:nil];
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
            NSRunAlertPanel(@"Internal Error Occurred",
                            @"ERROR: Found non-dit/dah for letter %c.",
                            @"Quit", nil, nil, [pattern characterAtIndex:idx]);
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

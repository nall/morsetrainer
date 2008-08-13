//
//  MTQRMSource.m
//  MorseTrainer
//
//  Created by Jon Nall on 8/1/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import "MTQRMSource.h"
#import "MTTimeUtils.h"
#import "MTPatternMap.h"
#include "MTDefines.h"


@implementation MTQRMSource

-(id)initWithID:(NSUInteger)theID
{

	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString* qsoPath = [bundle pathForResource:[NSString stringWithFormat:@"QSO%d", theID] ofType:@"txt"];
	if(qsoPath == nil)
	{
		NSLog([NSString stringWithFormat:@"ERROR: Cannot load QSO%d.txt", theID]);
		return nil;
	}	

	NSString* paramString = [self generateParameters];
	
	if([super initWithFile:qsoPath
			 withFrequency:frequency
			withSampleRate:kSampleRate
			 withAmplitude:amplitude
			  withAnalysis:analysis] != nil)
	{
		qrmID = theID;
		sourceName = [NSString stringWithFormat:@"%@ %@",
					  sourceName, paramString];
	}
	
	return self;
}

-(NSString*)generateParameters
{
	NSUInteger baseFreq = [[NSUserDefaults standardUserDefaults] integerForKey:@"tonePitch"];
	NSString* timingPhrase = [[NSUserDefaults standardUserDefaults] stringForKey:@"wpmPhrase"];
	
	NSUInteger wpm = (random() % 40) + 5; // Generate WPM between 5 and 45
	
	// Effective WPM between 1 and wpm
	NSUInteger effectiveWPM = (random() % (wpm - 1)) + 1;
	
	analysis = [MTTimeUtils analyzeText:timingPhrase
									 withActualWPM:wpm
								  withEffectiveWPM:effectiveWPM];
	
	// Generate a random value beteen 0.1 and 0.25
	amplitude = (double)(random() % 100) * 0.0015 + 0.1;
	
	// Generate a random value beteen 0.1 and (0.5 * tonePitch + 0.1), then randomly
	// add or subtract it
	double freqMultiplier = (double)(random() % 100)  * 0.005 + 0.1;
	NSUInteger freqOffset = random() % lrint(((baseFreq / 2) * freqMultiplier));
	frequency = baseFreq + ((random() % 2) ? freqOffset : -freqOffset);
	
	return [NSString stringWithFormat:@"{WPM=%d, EWPM=%d, F=%d, A=%f}",
				  wpm, effectiveWPM, frequency, amplitude];
}


-(NSString*)name
{
	return sourceName;
}

@end

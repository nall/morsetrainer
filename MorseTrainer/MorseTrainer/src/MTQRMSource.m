//
// MTQRMSource.m
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
// Foobar is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with Foobar.  If not, see <http://www.gnu.org/licenses/>.



#import "MTQRMSource.h"
#import "MTTimeUtils.h"
#import "MTPatternMap.h"
#include "MTDefines.h"

@interface MTQRMSource (Private)
-(NSString*)generateParameters;
@end


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
	
    NSURL* qsoURL = [NSURL URLWithString:[[NSString stringWithString:@"file://"]
                                          stringByAppendingString:qsoPath]];
	if([super initWithURL:qsoURL
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


-(NSString*)name
{
	return sourceName;
}

@end

@implementation MTQRMSource (Private)
-(NSString*)generateParameters
{
	NSUInteger baseFreq = [[NSUserDefaults standardUserDefaults] integerForKey:kPrefTonePitch];
	NSString* timingPhrase = [[NSUserDefaults standardUserDefaults] stringForKey:kPrefWPMPhrase];
	
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
@end

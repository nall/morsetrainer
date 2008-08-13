//
//  AppController.m
//  MorseTrainer
//
//  Created by Jon Nall on 7/28/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import "MTController.h"
#import "MTOperationQueue.h"
#import "MTRandomCWSource.h"
#import "MTTimeUtils.h"
#import "MTPatternMap.h"
#include "MTDefines.h"

void textTracker(MTSourcePlayer* player, NSString* textString, void* userData)
{
	MTController* controller = userData;
	[controller updateText:textString];
}

@implementation MTController

-(id)init
{
	if([super init] != nil)
	{
		NSMutableDictionary* defaults = [[NSMutableDictionary alloc] init];
		
		// Source
		[defaults setObject:[NSNumber numberWithInt:2] forKey:@"kochCharacters"];
		
		// Sending 
		[defaults setObject:[NSNumber numberWithInt:20] forKey:@"actualWPM"];
		[defaults setObject:[NSNumber numberWithInt:15] forKey:@"effectiveWPM"];
		[defaults setObject:[NSNumber numberWithInt:600] forKey:@"tonePitch"];
		[defaults setObject:[NSNumber numberWithInt:5] forKey:@"minimumCharsPerGroup"];
		[defaults setObject:[NSNumber numberWithInt:5] forKey:@"maximumCharsPerGroup"];
		[defaults setObject:[NSNumber numberWithInt:5] forKey:@"minutesOfCopy"];
		
		// Noise / QRM
		[defaults setObject:[NSNumber numberWithInt:7] forKey:@"signalStrength"];  // S9
		[defaults setObject:[NSNumber numberWithInt:0] forKey:@"noiseLevel"];      // Off
		[defaults setObject:[NSNumber numberWithInt:0] forKey:@"qrmStations"];

		
		// Preferences not visible to users
		[defaults setValue:@"PARIS" forKey:@"wpmPhrase"];
				
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];	
		
		noiseValues = [NSArray arrayWithObjects:
								[NSNumber numberWithDouble:0.00], // Off
								[NSNumber numberWithDouble:0.50], // S5
								[NSNumber numberWithDouble:0.10], // S1
								[NSNumber numberWithDouble:0.75], // S7
								[NSNumber numberWithDouble:0.25], // S3
								[NSNumber numberWithDouble:1.00], // S9
							nil];
		
		signalStrengthValues = [NSArray arrayWithObjects:
					   [NSNumber numberWithDouble:0.10], // S1
					   [NSNumber numberWithDouble:0.50], // S5
					   [NSNumber numberWithDouble:0.15], // S2
					   [NSNumber numberWithDouble:0.62], // S6
					   [NSNumber numberWithDouble:0.25], // S3
					   [NSNumber numberWithDouble:0.75], // S7
					   [NSNumber numberWithDouble:0.35], // S4
					   [NSNumber numberWithDouble:1.00], // S9
					   nil];
		
		currentChars = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", nil];
		
		{
			NSMutableArray* stations = [NSMutableArray array];
			for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
			{
				[stations addObject:[NSString stringWithFormat:@"%d", i]];
			}
			
			qrmStationValues = [NSArray arrayWithArray:stations];			
		}
		
		kochCharacters = [NSArray arrayWithObjects:
					 @"K", @"M", @"R", @"S", @"U", @"A", @"P", @"T", @"L",
                     @"O", @"W", @"I", @".", @"N", @"J", @"E", @"F", @"0",
                     @"Y", @"V", @",", @"G", @"5", @"/", @"Q", @"9", @"Z",
                     @"H", @"3", @"8", @"B", @"?", @"4", @"2", @"7", @"C",
                     @"1", @"D", @"6", @"X", @"^BT", @"^SK", @"^AR", nil
                    ];
		
		player = [[MTPlayer alloc] init];
		
		minimumWPM = 5;
		maximumWPM = 100;		
		
		minimumGroupChars = 1;
		maximumGroupChars = 10;
		
		minimumMinutes = 1;
		maximumMinutes = 10;
		
		minKochCharacters = 2;
		maxKochCharacters = [kochCharacters count];

		[self setTextFileEnabled:NO];
	}
	
	return self;
}

-(BOOL)textFileEnabled
{
	return textFileEnabled;
}

-(void)setTextFileEnabled:(BOOL)value
{
	textFileEnabled = value;
}

-(void)updateText:(NSString*)theText
{
	NSString* newString = [NSString stringWithFormat:@"%@%@", [textField stringValue], theText];
	[textField setStringValue:newString];
}

-(void)manageSessionTime:(NSNumber*)theMinutes
{
	const NSTimeInterval seconds = [theMinutes unsignedIntValue] * 60;
	
	NSString* totalString = (seconds == 0) ?
		@"" :
		[NSString stringWithFormat:@" / %02d:00", [theMinutes unsignedIntValue]];

	BOOL forever = (seconds == 0);
	for(NSUInteger i = 1; forever || i <= seconds; ++i)
	{
		const NSUInteger elapsedMinutes = i / 60;
		const NSUInteger elapsedSeconds = i % 60;
		
		[NSThread sleepForTimeInterval:1.0];

		if([player stopped])
		{
			break;
		}

		[statusBar setStringValue:[NSString stringWithFormat:@"%@%@",
		 [NSString stringWithFormat:@"%02d:%02d", elapsedMinutes, elapsedSeconds], totalString]];
	}
	
	if(![player stopped])
	{
		[player stop];		
	}
}

-(IBAction)validateTiming:(id)value
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSUInteger actualWPM = [defaults integerForKey:@"actualWPM"];
	NSUInteger effectiveWPM = [defaults integerForKey:@"effectiveWPM"];

	// Check that actual >= effective
	if(effectiveWPM > actualWPM)
	{
		if([value isEqual:actualWPMField])
		{
			// user changed actual -- update effective
			[defaults setInteger:actualWPM forKey:@"effectiveWPM"];
		}
		else
		{
			[defaults setInteger:effectiveWPM forKey:@"actualWPM"];
		}
	}
}

-(IBAction)validateCharGroups:(id)value
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSUInteger minCharsPerWord = [defaults integerForKey:@"minimumCharsPerGroup"];
	NSUInteger maxCharsPerWord = [defaults integerForKey:@"maximumCharsPerGroup"];

	// Check that min <= max
	if(minCharsPerWord > maxCharsPerWord)
	{
		if([value isEqual:minimumCharGroupField])
		{
			// User changed min -- update max
			[defaults setInteger:minCharsPerWord forKey:@"maximumCharsPerGroup"];			
		}
		else
		{
			[defaults setInteger:maxCharsPerWord forKey:@"minimumCharsPerGroup"];			
		}
	}
}

-(IBAction)validateKochCharacters:(id)value
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSUInteger kChars = [defaults integerForKey:@"kochCharacters"];

	if(kChars < minKochCharacters)
	{
		NSBeep();
		[defaults setInteger:minKochCharacters forKey:@"kochCharacters"];
	}
	
	if(kChars > maxKochCharacters)
	{
		NSBeep();
		[defaults setInteger:maxKochCharacters forKey:@"kochCharacters"];
	}
}


-(IBAction)updateCharacterSet:(id)value
{
	NSLog(@"UpdateCharSet: %@", value);
}

-(IBAction)openTextFile:(id)value
{
	NSOpenPanel* dialog = [NSOpenPanel openPanel];
	[dialog setCanChooseFiles:YES];
	[dialog setCanChooseDirectories:NO];
	[dialog setAllowsMultipleSelection:NO];
	const NSInteger result = [dialog runModalForTypes:[NSArray arrayWithObject:@"txt"]];
	
	if(result == NSOKButton)
	{
		textFile = [dialog URL];
		
		NSArray* path = [[textFile path] pathComponents];
		[textFileLabel setStringValue:[path lastObject]];
	}
	
	[self setTextFileEnabled:(textFile != nil)];
}

// Main Window
-(IBAction)startSending:(id)sender
{	
	[textField setStringValue:@""];
	[player stop];
	
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	
	NSUInteger baseFreq = [defaults integerForKey:@"tonePitch"];
	NSUInteger actualWPM = [defaults integerForKey:@"actualWPM"];
	NSUInteger effectiveWPM = [defaults integerForKey:@"effectiveWPM"];
	NSString* phrase = [defaults stringForKey:@"wpmPhrase"];
	NSUInteger minutes = [defaults integerForKey:@"minutesOfCopy"];
	
	TextAnalysis analysis = [MTTimeUtils analyzeText:phrase
									 withActualWPM:actualWPM
								  withEffectiveWPM:effectiveWPM];
	
	NSUInteger numQRMStations = [defaults integerForKey:@"qrmStations"];
	
	const double noiseLevel = [[noiseValues objectAtIndex:[defaults integerForKey:@"noiseLevel"]] doubleValue];
	const double signalStrength = [[signalStrengthValues objectAtIndex:[defaults integerForKey:@"signalStrength"]] doubleValue];
	

	const NSUInteger numKChars = [defaults integerForKey:@"kochCharacters"];
	NSArray* kChars = [kochCharacters subarrayWithRange:NSMakeRange(0, numKChars)];
	MTRandomCWSource* randomSource = [[MTRandomCWSource alloc] initWithCharset:kChars
									withFrequency:baseFreq
								   withSampleRate:kSampleRate
								    withAmplitude:signalStrength
								     withAnalysis:analysis];
	
	[player setQRMStations:numQRMStations];
	[player setNoise:noiseLevel];
	
	[player setTextTrackingCallback:textTracker userData:self];
	
	[player playCW:randomSource];

	{
		NSInvocationOperation* theOp = [[NSInvocationOperation alloc]
										initWithTarget:self
										selector:@selector(manageSessionTime:)
										object:[NSNumber numberWithUnsignedInt:minutes]];
		
		[[MTOperationQueue operationQueue] addOperation:theOp];		
	}	
}

-(IBAction)stopSending:(id)sender
{
	[player stop];
}

@end

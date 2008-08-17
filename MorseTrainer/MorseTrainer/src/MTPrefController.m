//
//  MTPrefController.m
//
//  Created by Jon Nall on 08/13/08.
//  Copyright (c) 2008 STUNTAZ!!! All rights reserved.
//

#import "MTPrefController.h"
#import "MTPatternMap.h"
#include "MTDefines.h"

@implementation MTPrefController


-(NSArray*)makeBindingArrayWithValues:(NSArray*)theValues withLabels:(NSArray*)theLabels
{
    NSMutableArray* theArray = [NSMutableArray array];
    for(NSUInteger i = 0; i < [theValues count]; ++i)
    {
        NSArray* objects = [NSArray arrayWithObjects:[theLabels objectAtIndex:i],
                                                     [theValues objectAtIndex:i],
                                                     nil];

        NSArray* keys = [NSArray arrayWithObjects:@"title", @"value", nil];
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        [theArray addObject:dict];
    }
    
    return theArray;
}

-(NSArray*)makeCharset:(NSUInteger)charType
{
    NSDictionary* charDict = [MTPatternMap dictForCharType:charType];
    NSArray* keys = [[charDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableArray* theArray = [NSMutableArray array];
    for(NSUInteger i = 0; i < [keys count]; ++i)
    {
        NSString* value = [keys objectAtIndex:i];

        NSDictionary* entry = [NSDictionary dictionaryWithObjectsAndKeys:
                               value, @"value",
                               value, @"title",
                               [NSNumber numberWithBool:NO], @"hidden",
                               nil];
        [theArray addObject:entry];
    }
    
    return theArray;
}

-(void)removeUnusedCells:(NSUInteger)charType inMatrix:(NSMatrix*)theMatrix
{
    const NSUInteger validCells = [[MTPatternMap dictForCharType:charType] count];
    NSArray* cells = [theMatrix cells];
        
    for(NSUInteger i = validCells; i < [cells count]; ++i)
    {
        NSCell* blankCell = [[NSCell alloc] init];
        [blankCell setEnabled:NO];
        
        NSInteger theRow, theCol;
        [theMatrix getRow:&theRow column:&theCol ofCell:[cells objectAtIndex:i]];
        
        [theMatrix putCell:blankCell atRow:theRow column:theCol];
    }
}

-(BOOL)textFileEnabled
{
	return textFileEnabled;
}

-(void)setTextFileEnabled:(BOOL)value
{
	textFileEnabled = value;
}

-(void)windowDidLoad
{
    // We layout NSMatrix's in rows/cols, but might not need them all.
    // Remove unused cells before displaying.
    
    [self removeUnusedCells:kPatternLetter inMatrix:letterMatrix];
    [self removeUnusedCells:kPatternNumber inMatrix:numberMatrix];
    [self removeUnusedCells:kPatternPunctuation inMatrix:punctuationMatrix];
    [self removeUnusedCells:kPatternProsign inMatrix:prosignMatrix];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* textURL = [defaults stringForKey:kPrefTextFile];
    [self setTextFileEnabled:(textURL != nil)];

    [textFileLabel setStringValue:(textURL == nil) ? @"[None Selected]" :
        [textURL lastPathComponent]];
}

-(id)init
{
	if([super initWithWindowNibName:@"Preferences"] != nil)
	{
        
		minimumWPM = kPrefMinWPM;
        maximumWPM = kPrefMaxWPM;
		
		minimumGroupChars = kPrefMinGroupChars;
		maximumGroupChars = kPrefMaxGroupChars;
		
		minimumMinutes = kPrefMinMinutes;
		// No maximum minutes
		
        minTonePitch = kPrefMinTonePitch;
        maxTonePitch = kPrefMaxTonePitch;
		
		// Koch characters as defined here:
		// http://www.njqrp.org/rookey/KMMT_Assy_Guide_v1%5B1%5D.0.pdf
		kochCharacters = [NSArray arrayWithObjects:
					 @"K", @"M", @"R", @"S", @"U", @"A", @"P", @"T", @"L",
                     @"O", @"W", @"I", @".", @"N", @"J", @"E", @"F", @"0",
                     @"Y", @"V", @",", @"G", @"5", @"/", @"Q", @"9", @"Z",
                     @"H", @"3", @"8", @"B", @"?", @"4", @"2", @"7", @"C",
                     @"1", @"D", @"6", @"X", @"^BT", @"^SK", @"^AR", nil
                    ];
		
		minKochCharacters = kPrefMinKochChars;
		maxKochCharacters = [kochCharacters count];
        
        
        NSMutableDictionary* defaults = [[NSMutableDictionary alloc] init];
		
		// Source
		[defaults setObject:[NSNumber numberWithInt:2] forKey:kPrefKochChars];
        [defaults setObject:kochCharacters forKey:kPrefKochCharset];
        [defaults setObject:[MTPatternMap characters] forKey:kPrefCharSet];
		
		// Sending 
		[defaults setObject:[NSNumber numberWithInt:20] forKey:kPrefActualWPM];
		[defaults setObject:[NSNumber numberWithInt:15] forKey:kPrefEffectiveWPM];
		[defaults setObject:[NSNumber numberWithInt:600] forKey:kPrefTonePitch];
		[defaults setObject:[NSNumber numberWithInt:5] forKey:kPrefMinimumCharsPerGroup];
		[defaults setObject:[NSNumber numberWithInt:5] forKey:kPrefMaximumCharsPerGroup];
		[defaults setObject:[NSNumber numberWithInt:5] forKey:kPrefMinutesOfCopy];
		
		// Noise / QRM
		[defaults setObject:[NSNumber numberWithInt:7] forKey:kPrefSignalStrength];  // S9
		[defaults setObject:[NSNumber numberWithInt:0] forKey:kPrefNoiseLevel];      // Off
		[defaults setObject:[NSNumber numberWithInt:0] forKey:kPrefNumQRMStations];
        
		
		// Preferences not visible to users
		[defaults setValue:@"PARIS" forKey:kPrefWPMPhrase];
        
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];	

		NSArray* noiseLevelLabels = [NSArray arrayWithObjects:
                                     @"Off", @"S5", @"S1", @"S7", @"S3", @"S9", nil];
        NSArray* noiseLevelValues = [NSArray arrayWithObjects:
                       [NSNumber numberWithDouble:0.00], // Off
                       [NSNumber numberWithDouble:0.50], // S5
                       [NSNumber numberWithDouble:0.10], // S1
                       [NSNumber numberWithDouble:0.75], // S7
                       [NSNumber numberWithDouble:0.25], // S3
                       [NSNumber numberWithDouble:1.00], // S9
                       nil];
        
        noiseLevels = [self makeBindingArrayWithValues:noiseLevelValues withLabels:noiseLevelLabels];
        		
		NSArray* signalStrengthValues = [NSArray arrayWithObjects:
                                         [NSNumber numberWithDouble:0.10], // S1
                                         [NSNumber numberWithDouble:0.50], // S5
                                         [NSNumber numberWithDouble:0.15], // S2
                                         [NSNumber numberWithDouble:0.62], // S6
                                         [NSNumber numberWithDouble:0.25], // S3
                                         [NSNumber numberWithDouble:0.75], // S7
                                         [NSNumber numberWithDouble:0.35], // S4
                                         [NSNumber numberWithDouble:1.00], // S9
                                         nil];
        NSArray* signalStrengthLabels = [NSArray arrayWithObjects:
                                         @"S1", @"S5", @"S2", @"S6", @"S3", @"S7", @"S4", @"S9", nil];
        
        signalStrengths = [self makeBindingArrayWithValues:signalStrengthValues withLabels:signalStrengthLabels];
                                        
		
		{
			NSMutableArray* stations = [NSMutableArray array];
			for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
			{
				[stations addObject:[NSString stringWithFormat:@"%d", i]];
			}
			
			qrmStationValues = [NSArray arrayWithArray:stations];			
		}
        
        charsetLetters = [self makeCharset:kPatternLetter];
        charsetNumbers = [self makeCharset:kPatternNumber];
        charsetPunctuation = [self makeCharset:kPatternPunctuation];
        charsetProsigns = [self makeCharset:kPatternProsign];
	}

	return self;
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

-(IBAction)validateTonePitch:(id)value
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger tonePitch = [defaults integerForKey:@"tonePitch"];
    
    if(tonePitch < minTonePitch)
    {
        NSBeep();
        [defaults setInteger:minTonePitch forKey:@"tonePitch"];
    }
    else if(tonePitch > maxTonePitch)
    {
        NSBeep();
        [defaults setInteger:maxTonePitch forKey:@"tonePitch"];        
    }
}

-(IBAction)validateMinutes:(id)value
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger minutes = [defaults integerForKey:@"minutesOfCopy"];
    
    if(minutes < minimumMinutes)
    {
        NSBeep();
        [defaults setInteger:minimumMinutes forKey:@"minutesOfCopy"];
    }
}

-(IBAction)clearAllLetters:(id)value
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSArray array] forKey:@"letterCharset"];
    [defaults setObject:[NSArray array] forKey:@"numberCharset"];
    [defaults setObject:[NSArray array] forKey:@"punctuationCharset"];
    [defaults setObject:[NSArray array] forKey:@"prosignCharset"];
}

-(IBAction)checkAllLetters:(id)value
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[MTPatternMap dictForCharType:kPatternLetter] allKeys] forKey:@"letterCharset"];
    [defaults setObject:[[MTPatternMap dictForCharType:kPatternNumber] allKeys] forKey:@"numberCharset"];
    [defaults setObject:[[MTPatternMap dictForCharType:kPatternPunctuation] allKeys] forKey:@"punctuationCharset"];
    [defaults setObject:[[MTPatternMap dictForCharType:kPatternProsign] allKeys] forKey:@"prosignCharset"];
}

-(IBAction)copyFromKoch:(id)value
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    const NSUInteger numKChars = [defaults integerForKey:@"kochCharacters"];
    NSArray* allKChars = [defaults arrayForKey:kPrefKochCharset];
    NSArray* kChars = [allKChars subarrayWithRange:NSMakeRange(0, numKChars)];
    [defaults setObject:kChars forKey:@"letterCharset"];
    [defaults setObject:kChars forKey:@"numberCharset"];
    [defaults setObject:kChars forKey:@"punctuationCharset"];
    [defaults setObject:kChars forKey:@"prosignCharset"];
}

-(IBAction)openTextFile:(id)value
{
	NSOpenPanel* dialog = [NSOpenPanel openPanel];
	[dialog setCanChooseFiles:YES];
	[dialog setCanChooseDirectories:NO];
	[dialog setAllowsMultipleSelection:NO];
	const NSInteger result = [dialog runModalForTypes:[NSArray arrayWithObjects:@"txt", @"qso", nil]];
	
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	if(result == NSOKButton)
	{
        NSURL* url = [dialog URL];
        [defaults setObject:[url absoluteString] forKey:kPrefTextFile];
		
		[textFileLabel setStringValue:[[url absoluteString] lastPathComponent]];
        [defaults setObject:[NSNumber numberWithInt:kSourceTypeURL] forKey:kPrefSourceType];
        [self setTextFileEnabled:YES];
	}
}



@end

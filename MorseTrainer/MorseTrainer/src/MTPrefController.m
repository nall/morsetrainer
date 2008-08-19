//
//  MTPrefController.m
//
//  Created by Jon Nall on 08/13/08.
//  Copyright (c) 2008 STUNTAZ!!! All rights reserved.
//

#import "MTPrefController.h"
#import "MTPatternMap.h"
#include "MTDefines.h"

@interface MTPrefController (Private)
    -(void)switchCharsetViewTo:(NSView*)theNewView;
    
    -(NSArray*)makeBindingArrayWithValues:(NSArray*)theValues withLabels:(NSArray*)theLabels;

    -(NSArray*)makeCharsetFromArray:(NSArray*)theCharacters;
    -(NSArray*)makeCharset:(NSUInteger)charType;
    
    -(void)removeUnusedCells:(NSUInteger)numValidCells inMatrix:(NSMatrix*)theMatrix;
@end

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

-(NSArray*)makeCharsetFromArray:(NSArray*)theCharacters
{
    NSMutableArray* theArray = [NSMutableArray array];
    for(NSUInteger i = 0; i < [theCharacters count]; ++i)
    {
        NSString* value = [theCharacters objectAtIndex:i];
        
        NSDictionary* entry = [NSDictionary dictionaryWithObjectsAndKeys:
                               value, @"value",
                               value, @"title",
                               nil];
        [theArray addObject:entry];
    }
    
    return theArray;
}

-(NSArray*)makeCharset:(NSUInteger)charType
{
    NSDictionary* charDict = [MTPatternMap dictForCharType:charType];
    NSArray* keys = [[charDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    return [self makeCharsetFromArray:keys];
}

-(void)removeUnusedCells:(NSUInteger)numValidCells inView:(NSView*)theView
{
    if([theView class] == [NSMatrix class])
    {
        NSMatrix* matrix = (NSMatrix*)theView;
        [self removeUnusedCells:numValidCells inMatrix:matrix];
    }
    else
    {
        for (NSView* v in [theView subviews])
        {
            [self removeUnusedCells:numValidCells inView:v];
        }
    }
}

-(void)removeUnusedCells:(NSUInteger)numValidCells inMatrix:(NSMatrix*)theMatrix
{
    NSArray* cells = [theMatrix cells];
        
    for(NSUInteger i = numValidCells; i < [cells count]; ++i)
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

-(void)updateCellsToUserDefaults:(NSView*)theView
{
    if([theView class] == [NSButtonCell class])
    {
        NSButtonCell* cell = (NSButtonCell*)theView;
        const BOOL checked = [masterCharSet containsObject:[cell title]];
        [cell setState:(checked ? NSOnState : NSOffState)];
    }
    else if([theView class] == [NSMatrix class])
    {
        for(NSView* cell in [(NSMatrix*)theView cells])
        {
            [self updateCellsToUserDefaults:cell];
        }
    }
    else if([theView class] == [NSCell class])
    {
        // Do nothing -- these are empty cells
    }    
    else
    {
        for(NSView* subview in [theView subviews])
        {
            [self updateCellsToUserDefaults:subview];            
        }
    }
}

-(void)windowDidLoad
{
    charsetViews = [NSArray arrayWithObjects:
                    letterBox,
                    numberBox,
                    punctuationBox,
                    prosignBox,
                    kochBox,
                    allCharBox,
                    nil];
    
    // We layout NSMatrix's in rows/cols, but might not need them all.
    // Remove unused cells before displaying.
    {        
        // Check all of those included in masterCharSet
        for(NSView* v in charsetViews)
        {
            [self updateCellsToUserDefaults:v];
        }

        // The All Char Box matrices
        NSUInteger counts[kPrefNumCharBoxes] =
        {
            [[MTPatternMap dictForCharType:kPatternLetter] count],
            [[MTPatternMap dictForCharType:kPatternNumber] count],
            [[MTPatternMap dictForCharType:kPatternPunctuation] count],
            [[MTPatternMap dictForCharType:kPatternProsign] count],
            [kochCharacters count]
        };
        
        const NSUInteger letterCount = [[MTPatternMap dictForCharType:kPatternLetter] count];
        const NSUInteger numberCount = [[MTPatternMap dictForCharType:kPatternNumber] count];
        const NSUInteger punctuationCount = [[MTPatternMap dictForCharType:kPatternPunctuation] count];
        const NSUInteger prosignCount = [[MTPatternMap dictForCharType:kPatternProsign] count];
        
        [self removeUnusedCells:letterCount inMatrix:allCharLetterMatrix];
        [self removeUnusedCells:numberCount inMatrix:allCharNumberMatrix];
        [self removeUnusedCells:punctuationCount inMatrix:allCharPunctuationMatrix];
        [self removeUnusedCells:prosignCount inMatrix:allCharProsignMatrix];
        
        // The individual box matrices -- each of this is a box which contains a matrix
        for(NSUInteger i = 0; i < kPrefNumCharBoxes; ++i)
        {
            [self removeUnusedCells:counts[i] inView:[charsetViews objectAtIndex:i]];
        }
    }
     
    
    // Generate mapping of view strings -> views
    {
        characterViewMap = [NSMutableDictionary dictionaryWithCapacity:[characterViewMapLabels count]];
        [characterViewMap setValue:allCharBox forKey:kCharViewAll];
        [characterViewMap setValue:letterBox forKey:kCharViewLetters];
        [characterViewMap setValue:numberBox forKey:kCharViewNumbers];
        [characterViewMap setValue:punctuationBox forKey:kCharViewPunctuation];
        [characterViewMap setValue:prosignBox forKey:kCharViewProsigns];
        [characterViewMap setValue:kochBox forKey:kCharViewKoch];
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* textURL = [defaults stringForKey:kPrefTextFile];
    [self setTextFileEnabled:(textURL != nil)];

    [textFileLabel setStringValue:(textURL == nil) ? @"[None Selected]" :
        [textURL lastPathComponent]];
    
    currentView = allCharBox;
    [self switchCharsetViewTo:currentView];
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
                     @"1", @"D", @"6", @"X", @"BT", @"SK", @"AR", nil
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
        charsetKoch = [self makeCharsetFromArray:kochCharacters];
        
        masterCharSet = [NSMutableSet setWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:kPrefCharSet]];
        

        characterViewMapLabels = [NSArray arrayWithObjects:kCharViewAll,
                                    kCharViewLetters,
                                    kCharViewNumbers,
                                    kCharViewPunctuation,
                                    kCharViewProsigns,
                                    kCharViewKoch,
                                    nil];
	}

	return self;
}

-(IBAction)validateTiming:(id)value
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSUInteger actualWPM = [defaults integerForKey:kPrefActualWPM];
	NSUInteger effectiveWPM = [defaults integerForKey:kPrefEffectiveWPM];

	// Check that actual >= effective
	if(effectiveWPM > actualWPM)
	{
		if([value isEqual:actualWPMField])
		{
			// user changed actual -- update effective
			[defaults setInteger:actualWPM forKey:kPrefEffectiveWPM];
		}
		else
		{
			[defaults setInteger:effectiveWPM forKey:kPrefActualWPM];
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

-(void)toggleCharsInViewRecursively:(NSView*)theView enableValue:(BOOL)theEnable
{
    if([theView class] == [NSButtonCell class])
    {
        NSButtonCell* cell = (NSButtonCell*)theView;

        if(theEnable == YES)
        {
            [masterCharSet addObject:[cell title]];
        }
        else
        {
            [masterCharSet removeObject:[cell title]];
        }
    }
    else if([theView class] == [NSMatrix class])
    {
        for(NSView* cell in [(NSMatrix*)theView cells])
        {
            [self toggleCharsInViewRecursively:cell enableValue:theEnable];
        }
    }
    else if([theView class] == [NSCell class])
    {
        // Do nothing -- these are empty cells
    }
    else
    {
        for (NSView* subview in [theView subviews])
        {
            [self toggleCharsInViewRecursively:subview enableValue:theEnable];
        }
    }
}

-(IBAction)clearCharsInView:(id)value
{
    [self toggleCharsInViewRecursively:currentView enableValue:NO];
    [[NSUserDefaults standardUserDefaults] setObject:[masterCharSet allObjects] forKey:kPrefCharSet];
    
    for(NSView* v in charsetViews)
    {
        [self updateCellsToUserDefaults:v];
    }
}

-(IBAction)checkCharsInView:(id)value
{
    [self toggleCharsInViewRecursively:currentView enableValue:YES];
    [[NSUserDefaults standardUserDefaults] setObject:[masterCharSet allObjects] forKey:kPrefCharSet];

    for(NSView* v in charsetViews)
    {
        [self updateCellsToUserDefaults:v];
    }
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

-(IBAction)updateCharset:(id)value
{
    NSMatrix* matrix = value;

    for (NSButtonCell* cell in [matrix cells])
    {
        NSString* character = [cell title];
        if([cell state] == NSOnState)
        {
            [masterCharSet addObject:character];
        }
        else
        {
            [masterCharSet removeObject:character];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[masterCharSet allObjects]
                                              forKey:kPrefCharSet];
    for(NSView* v in charsetViews)
    {
        [self updateCellsToUserDefaults:v];
    }    
}

-(void)dumpViews:(NSView*)theView withSpace:(NSString*)spaces
{
    NSRect f = [theView frame];
    NSLog(@"%@VIEW: (%fx%f) @ (%fx%f) %@", spaces, f.size.width, f.size.height, f.origin.x, f.origin.y, theView);
    
    for(NSView* subView in [theView subviews])
    {
        NSString* newSpaces = [spaces stringByAppendingString:@"    "];
        [self dumpViews:subView withSpace:newSpaces];
    }
}

-(void)switchCharsetViewTo:(NSView*)theNewView
{    
    if(currentView == theNewView) return;
    
    //[self dumpViews:currentView withSpace:@""];
    //[self dumpViews:theNewView withSpace:@""];
    NSRect oldBoxFrame = [currentView frame];
    NSRect newBoxFrame = [theNewView frame];
    
    // The origin of the new frame should be identical to the old
    newBoxFrame.origin = oldBoxFrame.origin;
    
    NSWindow* window = [currentView window];
    NSRect oldWinFrame = [window frame];
    NSRect newWinFrame = oldWinFrame;
    

    newBoxFrame.origin = oldBoxFrame.origin;
    newBoxFrame.size.width = oldBoxFrame.size.width;
    
    const double heightDiff = (newBoxFrame.size.height - oldBoxFrame.size.height);
    newWinFrame.size.height += heightDiff;
    
    NSMutableDictionary* boxDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [boxDict setObject:currentView forKey:@"NSViewAnimationTargetKey"];
    [boxDict setObject:[NSValue valueWithRect:oldBoxFrame] forKey:@"NSViewAnimationStartFrameKey"];
    [boxDict setObject:[NSValue valueWithRect:newBoxFrame] forKey:@"NSViewAnimationEndFrameKey"];
    
    NSMutableDictionary* winDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [winDict setObject:window forKey:@"NSViewAnimationTargetKey"];
    [winDict setObject:[NSValue valueWithRect:oldWinFrame] forKey:@"NSViewAnimationStartFrameKey"];
    [winDict setObject:[NSValue valueWithRect:newWinFrame] forKey:@"NSViewAnimationEndFrameKey"];
    
    NSViewAnimation* animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:boxDict, winDict, nil]];
    [animation setDuration:0.2];
    [animation setAnimationCurve:NSAnimationLinear];
    [animation setAnimationBlockingMode:NSAnimationBlocking];

    NSView* blankView = [[NSView alloc] initWithFrame:oldBoxFrame];
    [[currentView superview] replaceSubview:currentView with:blankView];
    [animation startAnimation];
    [theNewView setFrame:newBoxFrame];
    [[blankView superview] replaceSubview:blankView with:theNewView];
    [[theNewView superview] setNeedsDisplay:YES];
    
    [currentView setFrame:oldBoxFrame]; // use its original size -- not the resized version
    currentView = theNewView;
}

-(IBAction)changeCharView:(id)value
{
    NSPopUpButton* button = value;
    NSView* theView = [characterViewMap objectForKey:[button titleOfSelectedItem]];
    
    [self switchCharsetViewTo:theView];
}

@end

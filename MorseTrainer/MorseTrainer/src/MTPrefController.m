//
//  MTPrefController.m
//
//  Created by Jon Nall on 08/13/08.
//  Copyright (c) 2008 STUNTAZ!!! All rights reserved.
//

#import "MTPrefController.h"
#import "MTPatternMap.h"
#import "Sparkle/SUUpdater.h"
#include "MTDefines.h"

@interface MTPrefController (Private)
    -(void)initPrefPane;

    -(NSArray*)makeBindingArrayWithValues:(NSArray*)theValues withLabels:(NSArray*)theLabels;

    -(NSArray*)makeCharsetFromArray:(NSArray*)theCharacters;
    -(NSArray*)makeCharset:(NSUInteger)charType;

    -(void)removeUnusedCells:(NSUInteger)numValidCells inView:(NSView*)theView;
    -(void)removeUnusedCells:(NSUInteger)numValidCells inMatrix:(NSMatrix*)theMatrix;

    -(void)updateCellsToUserDefaults:(NSView*)theView;

    -(void)dumpViews:(NSView*)theView withSpace:(NSString*)spaces;
    -(void)switchCharsetViewTo:(NSView*)theNewView;


@end

@implementation MTPrefController

-(id)init
{
    if([super init] != nil)
    {
        // Koch characters as defined here:
		// http://www.njqrp.org/rookey/KMMT_Assy_Guide_v1%5B1%5D.0.pdf
		kochCharacters = [NSArray arrayWithObjects:
                          @"K", @"M", @"R", @"S", @"U", @"A", @"P", @"T", @"L",
                          @"O", @"W", @"I", @".", @"N", @"J", @"E", @"F", @"0",
                          @"Y", @"V", @",", @"G", @"5", @"/", @"Q", @"9", @"Z",
                          @"H", @"3", @"8", @"B", @"?", @"4", @"2", @"7", @"C",
                          @"1", @"D", @"6", @"X", @"BT", @"SK", @"AR", nil
                          ];
		        
		minimumWPM = kPrefMinWPM;
        maximumWPM = kPrefMaxWPM;
		
		minimumGroupChars = kPrefMinGroupChars;
		maximumGroupChars = kPrefMaxGroupChars;
		
		minimumMinutes = kPrefMinMinutes;
		// No maximum minutes
		
        minTonePitch = kPrefMinTonePitch;
        maxTonePitch = kPrefMaxTonePitch;
		
		minKochCharacters = kPrefMinKochChars;
		maxKochCharacters = [kochCharacters count];
        
        
        NSMutableDictionary* defaults = [[NSMutableDictionary alloc] init];
		
		// Source
        [defaults setObject:kochCharacters forKey:kPrefKochCharset];
        [defaults setObject:[MTPatternMap characters] forKey:kPrefCharSet];
        
        sourceValues = [self makeBindingArrayWithValues:[NSArray arrayWithObjects:
                                                   [NSNumber numberWithUnsignedInt:kSourceTypeURL],
                                                   [NSNumber numberWithUnsignedInt:kSourceTypeCustom]]
                                             withLabels:[NSArray arrayWithObjects:@"Play from text file named:",@"Generate Random Groups",nil]];
        
		// Sending 
		[defaults setObject:[NSNumber numberWithInt:20] forKey:kPrefActualWPM];
		[defaults setObject:[NSNumber numberWithInt:15] forKey:kPrefEffectiveWPM];
		[defaults setObject:[NSNumber numberWithInt:550] forKey:kPrefTonePitch];
		[defaults setObject:[NSNumber numberWithInt:3] forKey:kPrefMinimumCharsPerGroup];
		[defaults setObject:[NSNumber numberWithInt:6] forKey:kPrefMaximumCharsPerGroup];
		[defaults setObject:[NSNumber numberWithInt:3] forKey:kPrefMinutesOfCopy];
		
		// Noise / QRM
		[defaults setObject:@"S9" forKey:kPrefSignalStrength];  // S9
		[defaults setObject:@"0.0" forKey:kPrefNoiseLevel];      // Off
		[defaults setObject:[NSNumber numberWithInt:0] forKey:kPrefNumQRMStations];
        
		// Updates
        [defaults setObject:[NSNumber numberWithBool:FALSE] forKey:@"SUHasLaunchedBefore"];
        
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

    [self initPrefPane];
	return self;
}

-(void)setSignalStrengths:(id)value
{
    NSLog(@"setSignalStrengths: %@", value);
}

-(IBAction)validateTiming:(id)value
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSInteger actualWPM = [defaults integerForKey:kPrefActualWPM];
	NSInteger effectiveWPM = [defaults integerForKey:kPrefEffectiveWPM];

    if(actualWPM < kPrefMinWPM)
    {
        [defaults setInteger:kPrefMinWPM forKey:kPrefActualWPM];
    }
    else if(actualWPM > kPrefMaxWPM)
    {
        [defaults setInteger:kPrefMaxWPM forKey:kPrefActualWPM];        
    }

    if(effectiveWPM < kPrefMinWPM)
    {
        [defaults setInteger:kPrefMinWPM forKey:kPrefEffectiveWPM];
    }
    else if(effectiveWPM > kPrefMaxWPM)
    {
        [defaults setInteger:kPrefMaxWPM forKey:kPrefEffectiveWPM];        
    }
    
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
	NSInteger minCharsPerWord = [defaults integerForKey:kPrefMinimumCharsPerGroup];
	NSInteger maxCharsPerWord = [defaults integerForKey:kPrefMaximumCharsPerGroup];

    if(minCharsPerWord < minimumGroupChars)
    {
        [defaults setInteger:minimumGroupChars forKey:kPrefMinimumCharsPerGroup];
    }
    else if(minCharsPerWord > maximumGroupChars)
    {
        [defaults setInteger:maximumGroupChars forKey:kPrefMinimumCharsPerGroup];
    }

    if(maxCharsPerWord < minimumGroupChars)
    {
        [defaults setInteger:minimumGroupChars forKey:kPrefMaximumCharsPerGroup];
    }
    else if(maxCharsPerWord > maximumGroupChars)
    {
        [defaults setInteger:maximumGroupChars forKey:kPrefMaximumCharsPerGroup];
    }
    
	// Check that min <= max
	if(minCharsPerWord > maxCharsPerWord)
	{
		if([value isEqual:minimumCharGroupField])
		{
			// User changed min -- update max
			[defaults setInteger:minCharsPerWord forKey:kPrefMaximumCharsPerGroup];			
		}
		else
		{
			[defaults setInteger:maxCharsPerWord forKey:kPrefMinimumCharsPerGroup];			
		}
	}
}

-(IBAction)validateTonePitch:(id)value
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger tonePitch = [defaults integerForKey:kPrefTonePitch];
    
    if(tonePitch < minTonePitch)
    {
        NSBeep();
        [defaults setInteger:minTonePitch forKey:kPrefTonePitch];
    }
    else if(tonePitch > maxTonePitch)
    {
        NSBeep();
        [defaults setInteger:maxTonePitch forKey:kPrefTonePitch];        
    }
}

-(IBAction)validateMinutes:(id)value
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger minutes = [defaults integerForKey:kPrefMinutesOfCopy];
    
    if(minutes < minimumMinutes)
    {
        NSBeep();
        [defaults setInteger:minimumMinutes forKey:kPrefMinutesOfCopy];
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
    [self toggleCharsInViewRecursively:currentCharacterView enableValue:NO];
    [[NSUserDefaults standardUserDefaults] setObject:[masterCharSet allObjects] forKey:kPrefCharSet];
    
    for(NSView* v in charsetViews)
    {
        [self updateCellsToUserDefaults:v];
    }
}

-(IBAction)checkCharsInView:(id)value
{
    [self toggleCharsInViewRecursively:currentCharacterView enableValue:YES];
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

-(IBAction)changeCharView:(id)value
{
    NSPopUpButton* button = value;
    NSView* theView = [characterViewMap objectForKey:[button titleOfSelectedItem]];
    
    [self switchCharsetViewTo:theView];
}

-(IBAction)checkForUpdates:(id)value
{
    [[SUUpdater sharedUpdater] checkForUpdates:value];
}

-(IBAction)showToolbarPane:(id)value
{
    NSToolbarItem* item = value;
    const NSUInteger tag = [item tag];
    
    NSView* v = [toolbarViews objectAtIndex:tag];
    
    NSRect winFrame = [prefWindow frame];
    NSRect winContentRect = [prefWindow contentRectForFrameRect:winFrame];

    NSRect viewRect = [v frame];
    
    const double widthDiff = viewRect.size.width - winContentRect.size.width;
    const double heightDiff = viewRect.size.height - winContentRect.size.height;

    winFrame.size.height += heightDiff;
    winFrame.size.width += widthDiff;
    
    // Grow down and to the right unless we would go off the screen, then up/left
    if(winFrame.origin.y - heightDiff >= 0)
    {
        winFrame.origin.y -= heightDiff;        
    }
    
    NSRect screenRect = [[prefWindow screen] frame];
    if(winFrame.origin.x + winFrame.size.width + widthDiff >= screenRect.size.width)
    {
        winFrame.origin.x -= widthDiff;        
    }
    
    NSView* blankView = [[NSView alloc] initWithFrame:viewRect];
    [prefWindow setContentView:blankView];
    [prefWindow setFrame:winFrame display:YES animate:YES];
    [prefWindow setContentView:v];
}

-(void)showPreferences:(id)value
{
    [prefWindow makeKeyAndOrderFront:value];
}

-(BOOL)textFileEnabled
{
	return textFileEnabled;
}

-(void)setTextFileEnabled:(BOOL)value
{
	textFileEnabled = value;
}


@end

@implementation MTPrefController (Private)
-(void)initPrefPane
{
    if([NSBundle loadNibNamed:@"Preferences" owner:self] == NO)
    {
        NSLog(@"Error: couldn't load Preferences");
    }
    
    charsetViews = [NSArray arrayWithObjects:
                    letterBox,
                    numberBox,
                    punctuationBox,
                    prosignBox,
                    kochBox,
                    allCharBox,
                    nil];
    
    toolbarViews = [NSArray arrayWithObjects:
                    sourceView,
                    sendingView,
                    noiseQRMView,
                    updateView,
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
    
    BOOL fileExists = TRUE;
    if(textURL == nil)
    {
        fileExists = FALSE;
    }
    else
    {
        NSURL* url = [NSURL URLWithString:textURL];
        
        if([url isFileURL])
        {
            NSString* path = [url path];
            fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
        }        
    }
    
    [self setTextFileEnabled:fileExists];
    
    [textFileLabel setStringValue:fileExists ? [textURL lastPathComponent] :
     @"[None Selected]"];
    
    if(![self textFileEnabled])
    {
        // Automatically enable random code generation
        [defaults setInteger:kSourceTypeCustom forKey:kPrefSourceType];
    }
    
    currentCharacterView = allCharBox;
    [self switchCharsetViewTo:currentCharacterView];
    
    
    [self showToolbarPane:[[[prefWindow toolbar] items] objectAtIndex:0]];
}

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
    if(currentCharacterView == theNewView) return;
    
    // [self dumpViews:[currentCharacterView superview] withSpace:@"super: "];
    // [self dumpViews:theNewView withSpace:@""];
    
    NSRect oldBoxFrame = [currentCharacterView frame];
    NSRect newBoxFrame = [theNewView frame];
    
    // The origin & width of the new frame should be identical to the old
    newBoxFrame.origin = oldBoxFrame.origin;
    newBoxFrame.size.width = oldBoxFrame.size.width;
    
    const double heightDiff = (newBoxFrame.size.height - oldBoxFrame.size.height);
    
    NSWindow* window = [currentCharacterView window];
    NSRect oldWinFrame = [window frame];
    NSRect newWinFrame = oldWinFrame;    
    
    newWinFrame.size.height += heightDiff;
    
    // Grow down unless we would go off the screen, then grow up
    if(newWinFrame.origin.y - heightDiff >= 0)
    {
        newWinFrame.origin.y -= heightDiff;        
    }
    
    NSMutableDictionary* boxDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [boxDict setObject:currentCharacterView forKey:@"NSViewAnimationTargetKey"];
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
    [[currentCharacterView superview] replaceSubview:currentCharacterView with:blankView];
    [animation startAnimation];
    [theNewView setFrame:newBoxFrame];
    [[blankView superview] replaceSubview:blankView with:theNewView];
    [[theNewView superview] setNeedsDisplay:YES];
    
    [currentCharacterView setFrame:oldBoxFrame]; // use its original size -- not the resized version
    currentCharacterView = theNewView;
}


@end

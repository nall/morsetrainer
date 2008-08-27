//
//  MTController.m
//  MorseTrainer
//
//  Created by Jon Nall on 7/28/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import "MTController.h"
#import "MTOperationQueue.h"
#import "MTURLSource.h"
#import "MTRandomCWSource.h"
#import "MTTimeUtils.h"
#import "MTPatternMap.h"
#include "MTDefines.h"

@interface MTController (Private)
    -(void)startSending;
    -(void)updateText:(NSString*)theText;
    -(void)textTracker:(id)object;
    -(void)manageSessionTime:(NSNumber*)theMinutes;
@end

@implementation MTController

-(id)init
{
	if([super init] != nil)
	{		
        prefController = [[MTPrefController alloc] init];
		player = [[MTPlayer alloc] init];
	}
	
	return self;
}

-(IBAction)showPreferencePanel:(id)sender
{
    [prefController showPreferences:sender];
}

-(IBAction)playOrPause:(id)sender
{
    NSString* newLabel = nil;
    if([player stopped])
    {
        [self startSending];
        newLabel = @"Pause";
    }
    else if([player paused])
    {
        [player play];
        newLabel = @"Pause";
    }
    else
    {
        [player pause];
        newLabel = @"Play";
    }
    
    NSButton* button = sender;
    [button setTitle:newLabel];
}

-(IBAction)stopSending:(id)sender
{
	[player stop];
}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender willSpeakWord:(NSRange)wordToSpeak ofString:(NSString *)text
{
    NSLog(@"reading '%@'", [text substringWithRange:wordToSpeak]);
}

-(IBAction)speakBuffer:(id)sender
{
    NSString* text = [textField stringValue];

    /*
    NSMutableString* spacedOut = [NSMutableString stringWithCapacity:[text length] * 2];
    for(NSUInteger i = 0; i < [text length]; ++i)
    {
        [spacedOut appendString:[text substringWithRange:NSMakeRange(i, 1)]];
        [spacedOut appendString:@". "];
    }
    */
    
    NSSpeechSynthesizer* synth = [[NSSpeechSynthesizer alloc] initWithVoice:[NSSpeechSynthesizer defaultVoice]];
    [synth setRate:100];
    [synth setDelegate:self];
    
    
    [synth startSpeakingString:text];
    
    while([synth isSpeaking])
    {
        [NSThread sleepForTimeInterval:0.25];
    }
}

@end

@implementation MTController (Delegate)
-(BOOL)windowShouldClose:(id)window
{
    return NO;
}
@end

@implementation MTController (Private)

-(void)updateText:(NSString*)theText
{
	NSString* newString = [NSString stringWithFormat:@"%@%@", [textField stringValue], theText];
	[textField setStringValue:newString];
}

-(void)textTracker:(id)object
{
    NSNotification* notification = object;
	[self updateText:[[notification userInfo] objectForKey:kNotifTextKey]];
}

-(void)manageSessionTime:(NSNumber*)theMinutes
{
	const NSTimeInterval seconds = [theMinutes unsignedIntValue] * 60;
	
	NSString* totalString = (seconds == 0) ? @"" :
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

-(void)startSending
{	
	[textField setStringValue:@""];
	[player stop];
	
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	
	NSUInteger baseFreq = [defaults integerForKey:kPrefTonePitch];
	NSUInteger actualWPM = [defaults integerForKey:kPrefActualWPM];
	NSUInteger effectiveWPM = [defaults integerForKey:kPrefEffectiveWPM];
	NSString* phrase = [defaults stringForKey:kPrefWPMPhrase];
	NSUInteger minutes = [defaults integerForKey:kPrefMinutesOfCopy];
	
	TextAnalysis analysis = [MTTimeUtils analyzeText:phrase
                                       withActualWPM:actualWPM
                                    withEffectiveWPM:effectiveWPM];
	
	NSUInteger numQRMStations = [defaults integerForKey:kPrefNumQRMStations];
	
    const double noiseLevel = [defaults doubleForKey:kPrefNoiseLevel];
    const double signalStrength = [defaults doubleForKey:kPrefSignalStrength];
    
    // Create correct sound source
    id<MTSoundSource> soundSource = nil;
    {
        const NSUInteger type = [defaults integerForKey:kPrefSourceType];
        switch(type)
        {
            case kSourceTypeCustom:
            {
                NSArray* chars = [defaults arrayForKey:kPrefCharSet];                
                soundSource = [[MTRandomCWSource alloc] initWithCharset:chars
                                                          withFrequency:baseFreq
                                                         withSampleRate:kSampleRate
                                                          withAmplitude:signalStrength
                                                           withAnalysis:analysis];
                break;
            }
            case kSourceTypeURL:
            {
                NSString* textURLString = [defaults stringForKey:kPrefTextFile];
                
                if(textURLString == nil)
                {
                    // TBD: Alert
                    NSBeep();
                    NSLog(@"Internal ERROR -- option should have been disabled");
                }
                else
                {
                    NSURL* textURL = [NSURL URLWithString:textURLString];
                    soundSource = [[MTURLSource alloc] initWithURL:textURL
                                                     withFrequency:baseFreq 
                                                    withSampleRate:kSampleRate
                                                     withAmplitude:signalStrength
                                                      withAnalysis:analysis];
                }
                break;
            }
            default:
            {
                NSLog(@"Internal error: Unexpected source type: %d", type);                
            }
        }
    }
    
    if(soundSource == nil)
    {
        // Don't play anything -- an error occurred and the subsystem should
        // have alerted the user.
        return;
    }
    
    //[soundSource dumpAU:@"/Users/nall/data.au"];
	
	[player setQRMStations:numQRMStations];
	[player setNoise:noiseLevel];
	
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textTracker:)
                                                 name:kNotifTextWasPlayed
                                               object:player];
	
	[player playCW:soundSource];
    
	{
		NSInvocationOperation* theOp = [[NSInvocationOperation alloc]
										initWithTarget:self
										selector:@selector(manageSessionTime:)
										object:[NSNumber numberWithUnsignedInt:minutes]];
		
		[[MTOperationQueue operationQueue] addOperation:theOp];		
	}
}


@end




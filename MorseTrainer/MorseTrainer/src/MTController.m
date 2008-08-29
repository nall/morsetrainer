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
        
        aboutText = [NSString stringWithString:@"\
AD5RX Morse Code Trainer\n\
Copyright © 2008 Jon Nall\n\
All rights reserved.\n\
\n\n\
LICENSE\n\
This program is free software: you can redistribute it and/or modify\n\
it under the terms of the GNU General Public License as published by\n\
the Free Software Foundation, either version 3 of the License, or\n\
(at your option) any later version.\n\
\n\
This program is distributed in the hope that it will be useful,\n\
but WITHOUT ANY WARRANTY; without even the implied warranty of\n\
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n\
GNU General Public License for more details.\n\
\n\
You should have received a copy of the GNU General Public License\n\
along with this program.  If not, see <http://www.gnu.org/licenses/>.\n\
\n\
Contains source code from Noise application. The below is the required\n\
copyright notice. See NoiseLicense.pdf in this distribution for the\n\
details of that license.\n\
\n\
http://www.blackholemedia.com/noise\n\
Copyright © 2001, Blackhole Media\n\
All rights reserved.\n\
"];
	}
	
	return self;
}

-(void)awakeFromNib
{
    [stopButton setEnabled:NO];
    [talkButton setEnabled:NO];
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
        [stopButton setEnabled:YES];
        [talkButton setEnabled:NO];
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
    
    [playPauseButton setTitle:newLabel];
}

-(IBAction)stopSending:(id)sender
{
	[player stop];
    [stopButton setEnabled:NO];
    [talkButton setEnabled:YES];
    [playPauseButton setTitle:@"Play"];
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




//
// MTController.m
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
        speechSynth = [[NSSpeechSynthesizer alloc] initWithVoice:[NSSpeechSynthesizer defaultVoice]];
        [speechSynth setRate:110];
        [speechSynth setDelegate:self];
        keepTalking = NO;
        
        aboutText = @"\
AD5RX Morse Code Trainer\n\
Copyright © 2008-2014 Jon Nall\n\
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
\n\
Uses the Sparkle Framework Copyright © 2006 Andy Matuschak\n\
See SparkleLicense.txt in the distribution for the details\n\
of that license.\n\
";
	}
	
	return self;
}

-(void)awakeFromNib
{
    // Window has loaded. We can now access objects in the NIB
    [stopButton setEnabled:NO];
    [talkButton setEnabled:NO];
    
    playImage = [playPauseButton image];
    pauseImage = [playPauseButton alternateImage];
}

-(IBAction)showPreferencePanel:(id)sender
{
    [prefController showPreferences:sender];
}

-(IBAction)playOrPause:(id)sender
{
    BOOL showPlay = NO;
    NSString* tooltip = @"BUG: Report Me!!";
    if([player stopped])
    {
        [self startSending];
        [stopButton setEnabled:YES];
        [talkButton setEnabled:NO];
        showPlay = NO;
        tooltip = @"Pause morse code";
    }
    else if([player paused])
    {
        [player play];
        showPlay = NO;
        tooltip = @"Pause morse code";
    }
    else
    {
        [player pause];
        showPlay = YES;
        tooltip = @"Resume morse code";
    }
    
    [playPauseButton setImage:(showPlay ? playImage : pauseImage)];
    [playPauseButton setToolTip:tooltip];
    [stopButton setToolTip:@"Stop playback"];
}

-(IBAction)stopSending:(id)sender
{
    // This will initiate a message that invokes cwComplete
	[player stop];
}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender willSpeakWord:(NSRange)wordToSpeak ofString:(NSString *)text
{
    if(keepTalking == NO)
    {
        [sender stopSpeaking];
    }
}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didFinishSpeaking:(BOOL)success
{
    [stopButton setEnabled:NO];
    [playPauseButton setEnabled:YES];
}


-(void)speechThread:(NSString*)theText
{
    // Insert a . after every character to ensure the synth doesn't try to
    // pronounce phenomes.
    NSMutableString* spacedOut = [NSMutableString stringWithCapacity:[theText length] * 2];
    for(NSUInteger i = 0; i < [theText length]; ++i)
    {
     [spacedOut appendString:[theText substringWithRange:NSMakeRange(i, 1)]];
     [spacedOut appendString:@". "];
    }
     
    
    keepTalking = YES;
    [stopButton setToolTip:@"Stop speaking"];
    [stopButton setEnabled:YES];
    [speechSynth startSpeakingString:spacedOut];    
}

-(IBAction)speakBuffer:(id)sender
{
    // Don't speak in this thread to avoid blocking the UI.
    // Just setup a simple operation to do it for us.
    // Real work happens in MTController::speechThread
    
    NSInvocationOperation* theOp = [[NSInvocationOperation alloc]
                                    initWithTarget:self
                                    selector:@selector(speechThread:)
                                    object:[textField stringValue]];
    
    [[MTOperationQueue operationQueue] addOperation:theOp];		    
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

-(void)cwComplete:(id)object
{
    // Kill talking and sound player, whichever is active
    keepTalking = NO;
    
    [stopButton setEnabled:NO];
    [talkButton setEnabled:YES];
    
    // Force play
    [playPauseButton setImage:playImage];
}

-(void)manageSessionTime:(NSNumber*)theMinutes
{
	const NSTimeInterval seconds = [theMinutes unsignedIntValue] * 60;
	
    const BOOL hideTotalTime = (seconds == 0) ||
        [[NSUserDefaults standardUserDefaults] integerForKey:kPrefSourceType] == kSourceTypeURL;
    
	NSString* totalString = hideTotalTime ? @"" :
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
        else if([player paused])
        {
            // Keep looping, but keep i constant.
            // Decrement to offset increment in for loop
            --i;
        }
        
		[statusBar setStringValue:[NSString stringWithFormat:@"%@%@",
                                   [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)elapsedMinutes, (unsigned long)elapsedSeconds], totalString]];
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
                NSLog(@"Internal ERROR: Unexpected source type: %lu", (unsigned long)type);                
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cwComplete:)
                                                 name:kNotifSoundPlayerComplete
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




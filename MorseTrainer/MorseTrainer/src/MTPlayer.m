//
// MTPlayer.m
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



#import "MTPlayer.h"
#import "MTFifoSource.h"
#import "MTNoiseSource.h"
#import "MTQRMSource.h"

#define CHECK_ERR(err, msg) \
if((err) != noErr)\
{\
    NSLog(@"ERROR: Error 0x%x (%d) occurred during AU operation: %@", (err), (err), (msg));\
}

static const NSUInteger cwMixerElement = 0;
static const NSUInteger noiseMixerElement = 1;
static const NSUInteger baseQRMElement = 2;

@interface MTPlayer (Private)
    -(void)initGraph;
    -(void)setVolume:(AudioUnitElement)theElement withValue:(AudioUnitParameterValue)theValue;
    -(void)CWComplete:(id)object;
    -(void)textTracker:(id)object;


@end

@implementation MTPlayer

-(id)init
{
	if([super init] != nil)
	{
		[self initGraph];
		
		isStopped = YES;
		isPaused = NO;
        isPlaying = NO;
        
		cwPlayer = [[MTSourcePlayer alloc] initWithAU:cwUnit];		

		// Setup Noise Source
        noisePlayer = [[MTSourcePlayer alloc] initWithAU:noiseUnit];
        
        MTNoiseSource* noiseSource = [[MTNoiseSource alloc] init];
        if([[NSUserDefaults standardUserDefaults] boolForKey:kPrefWhiteNoise] == YES)
        {
            [noiseSource goWhite];
        }
            
        [noiseSource reset];
        [noisePlayer setSource:noiseSource];
		
        // Setup QRM Source
		for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
		{
			qrmPlayer[i] = [[MTSourcePlayer alloc] initWithAU:qrmUnit[i]];

            MTQRMSource* qrmSource = [[MTQRMSource alloc] initWithID:i];
            [qrmSource reset];
            [qrmPlayer[i] setSource:qrmSource];
		}
                
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(CWComplete:)
                                                     name:kNotifSoundPlayerComplete
                                                   object:cwPlayer];
	
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textTracker:)
                                                     name:kNotifTextWasPlayed
                                                   object:cwPlayer];
                
		[self setQRMStations:0];
		[self setNoise:0.0];		
	}
	
	return self;
}

-(void)setQRMStations:(NSUInteger)numStations
{
	for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
	{
		AudioUnitParameterValue value;
		BOOL enabled;
		if(i < numStations)
		{
			value = 1.0;
			enabled = YES;
		}
		else
		{
			value = 0.0;
			enabled = NO;
		}
		[qrmPlayer[i] setEnabled:enabled];
		[self setVolume:(baseQRMElement + i) withValue:value];			
	}
}

-(void)setNoise:(double)noiseLevel
{
	if(noiseLevel > 0.0)
	{
		[noisePlayer setEnabled:YES];
        NSLog(@"enabled");
	}
	else
	{
		[noisePlayer setEnabled:NO];
	}
    
	[self setVolume:noiseMixerElement withValue:noiseLevel];
}

-(void)playCW:(id<MTSoundSource>)theSource
{
	isStopped = NO;
    isPaused = NO;
    isPlaying = YES;

	[theSource setTextTracking:YES];
	[theSource reset];
	[cwPlayer setSource:theSource];
    
    [noisePlayer reset];
    for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
    {
        [qrmPlayer[i] reset];
    }
	
	AUGraphStart(graph);	
	// CAShow(graph);
	
	[cwPlayer setEnabled:YES];
	[cwPlayer start];
	[noisePlayer start];
	for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
	{
		[qrmPlayer[i] start];
	}
}	

-(BOOL)stopped
{
	return isStopped;
}

-(void)stop
{
    isPaused = NO;
    isPlaying = NO;
	isStopped = YES;
	AUGraphStop(graph);
	
	[cwPlayer stop];
	[noisePlayer stop];
	for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
	{
		[qrmPlayer[i] stop];
	}
}

-(BOOL)playing
{
    return isPlaying;
}

-(void)play
{
    if(![self paused])
    {
        NSLog(@"Internal Error -- Bad state in MTPlayer::play");
        NSRunAlertPanel(@"Internal Error", @"Internal Error -- Bad state in MTPlayer::play", @"Quit", nil, nil);
        exit(1);
    }
    
    isStopped = NO;
    isPaused = NO;
    isPlaying = YES;
    
    AUGraphStart(graph);    
}

-(BOOL)paused
{
    return isPaused;
}

-(void)pause
{
    if(![self playing])
    {
        NSLog(@"Internal Error -- Bad state in MTPlayer::pause");
        NSRunAlertPanel(@"Internal Error", @"Internal Error -- Bad state in MTPlayer::pause", @"Quit", nil, nil);
        exit(1);
    }
        
    isStopped = NO;
    isPlaying = NO;
    isPaused = YES;
    
    AUGraphStop(graph);    
}

@end

@implementation MTPlayer (Private)
-(void)initGraph
{
	NewAUGraph(&graph);
	
	ComponentDescription cd;
	cd.componentManufacturer = kAudioUnitManufacturer_Apple;
	cd.componentFlags = 0;
	cd.componentFlagsMask = 0;
	
	// Default Output
	AUNode outputNode;
	cd.componentType = kAudioUnitType_Output;
	cd.componentSubType = kAudioUnitSubType_DefaultOutput;
	AUGraphAddNode(graph, &cd, &outputNode);
    
	// Mixer
	AUNode mixerNode;
	cd.componentType = kAudioUnitType_Mixer;
	cd.componentSubType = kAudioUnitSubType_StereoMixer;
	AUGraphAddNode(graph, &cd, &mixerNode);
	AUGraphConnectNodeInput(graph, mixerNode, 0, outputNode, 0);
	
	// CW
    AUNode cwConverterNode;
    cd.componentType = kAudioUnitType_FormatConverter;
    cd.componentSubType = kAudioUnitSubType_AUConverter;
    AUGraphAddNode(graph, &cd, &cwConverterNode);
    AUGraphConnectNodeInput(graph, cwConverterNode, 0, mixerNode, cwMixerElement);

	AUNode cwNode;
	cd.componentType = kAudioUnitType_Generator;
	cd.componentSubType = kAudioUnitSubType_ScheduledSoundPlayer;
	AUGraphAddNode(graph, &cd, &cwNode);
	AUGraphConnectNodeInput(graph, cwNode, 0, cwConverterNode, 0);
    
    
	// Noise
    AUNode noiseConverterNode;
    cd.componentType = kAudioUnitType_FormatConverter;
    cd.componentSubType = kAudioUnitSubType_AUConverter;
    AUGraphAddNode(graph, &cd, &noiseConverterNode);
    AUGraphConnectNodeInput(graph, noiseConverterNode, 0, mixerNode, noiseMixerElement);
        
	AUNode noiseNode;
	cd.componentType = kAudioUnitType_Generator;
	cd.componentSubType = kAudioUnitSubType_ScheduledSoundPlayer;
	AUGraphAddNode(graph, &cd, &noiseNode);
	AUGraphConnectNodeInput(graph, noiseNode, 0, noiseConverterNode, 0);
	
    AUNode qrmConverter[kMaxQRMStations];
	AUNode qrmNode[kMaxQRMStations];
	for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
	{
        cd.componentType = kAudioUnitType_FormatConverter;
        cd.componentSubType = kAudioUnitSubType_AUConverter;
        AUGraphAddNode(graph, &cd, &(qrmConverter[i]));
        AUGraphConnectNodeInput(graph, qrmConverter[i], 0, mixerNode, baseQRMElement + i);
        
        
		cd.componentType = kAudioUnitType_Generator;
		cd.componentSubType = kAudioUnitSubType_ScheduledSoundPlayer;
		AUGraphAddNode(graph, &cd, &(qrmNode[i]));
		AUGraphConnectNodeInput(graph, qrmNode[i], 0, qrmConverter[i], 0);
	}
	
	AUGraphOpen(graph);
	
    AUGraphNodeInfo(graph, cwConverterNode, 0, &cwConverterUnit);
	AUGraphNodeInfo(graph, cwNode, 0, &cwUnit);
    AUGraphNodeInfo(graph, noiseConverterNode, 0, &noiseConverterUnit);
    AUGraphNodeInfo(graph, noiseNode, 0, &noiseUnit);
	AUGraphNodeInfo(graph, mixerNode, 0, &mixerUnit);
	AUGraphNodeInfo(graph, outputNode, 0, &outputUnit);
	
	for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
	{
        AUGraphNodeInfo(graph, qrmConverter[i], 0, &(qrmConverterUnit[i]));
        AUGraphNodeInfo(graph, qrmNode[i], 0, &(qrmUnit[i]));
	}
	
	AudioStreamBasicDescription aa;
	UInt32 size = sizeof(aa);
	ComponentResult err = AudioUnitGetProperty(cwUnit, 
                                               kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &aa, &size);
	CHECK_ERR(err, @"Getting StreamFormat Property from cwUnit");
	
	// Get Info from cwUnit and modify the channels to be 1 and the correct
    // sample rate. Then apply that to everything else.
	aa.mChannelsPerFrame = 1;
    aa.mSampleRate = kSampleRate;
    
	err = AudioUnitSetProperty(cwUnit, 
							   kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &aa, size);
	CHECK_ERR(err, @"Setting StreamFormat Property for cwUnit/Output");
    
	err = AudioUnitSetProperty(cwConverterUnit, 
							   kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &aa, size);
	CHECK_ERR(err, @"Setting StreamFormat Property for cwConverterUnit/Input");
    
	err = AudioUnitSetProperty(noiseUnit, 
							   kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &aa, size);
	CHECK_ERR(err, @"Setting StreamFormat Property for noiseUnit/Output");
    

    err = AudioUnitSetProperty(noiseConverterUnit, 
							   kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &aa, size);
	CHECK_ERR(err, @"Setting StreamFormat Property for noiseConverterUnit/Input");
    
    
	for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
	{
		err = AudioUnitSetProperty(qrmUnit[i], 
								   kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &aa, size);
		CHECK_ERR(err, @"Setting StreamFormat Property for qrmUnit /Output");	
        
        err = AudioUnitSetProperty(qrmConverterUnit[i], 
                                   kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &aa, size);
        CHECK_ERR(err, @"Setting StreamFormat Property for qrmConverterUnit/Input");
                
	}
    
	err = AudioUnitSetProperty(outputUnit, 
							   kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &aa, size);
	CHECK_ERR(err, @"Setting StreamFormat Property for outputUnit/Input");
	
	AUGraphInitialize(graph);
    // CAShow(graph);
    
}

-(void)setVolume:(AudioUnitElement)theElement withValue:(AudioUnitParameterValue)theValue
{
	ComponentResult err = AudioUnitSetParameter(mixerUnit,
												kStereoMixerParam_Volume,
												kAudioUnitScope_Input,
												theElement, theValue, 0);
	
	NSString* errMsg = [NSString stringWithFormat:
						@"Setting volume of mixer input %d to %f", theElement, theValue];
	CHECK_ERR(err, errMsg);
}


-(void)CWComplete:(id)object
{
    NSNotification* notification = object;
	NSLog(@"CW COMPLETE! [%@]", [[notification object] name]);
	
	if(![self stopped])
	{
		[self stop];		
	}
}

-(void)textTracker:(id)object
{
    // Re-Post for UI objects that don't have access to SoundPlayers
    NSNotification* notification = object;
    [[NSNotificationCenter defaultCenter] postNotificationName:[notification name]
                                                        object:self
                                                      userInfo:[notification userInfo]];
}

@end

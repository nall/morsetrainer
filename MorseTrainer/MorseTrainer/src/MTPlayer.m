//
//  MTPlayer.m
//  MorseTrainer
//
//  Created by Jon Nall on 7/30/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

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


void CWComplete(MTSourcePlayer* soundPlayer, void* userData)
{
	NSLog(@"CW COMPLETE! [%@]", [soundPlayer name]);
	MTPlayer* player = userData;
	
	if(![player stopped])
	{
		[player stop];		
	}
}

@implementation MTPlayer

-(id)init
{
	if([super init] != nil)
	{
		[self initGraph];
		
		isStopped = YES;
		
		cwPlayer = [[MTSourcePlayer alloc] initWithAU:cwUnit];		
		noisePlayer = [[MTSourcePlayer alloc] initWithAU:noiseUnit];
		
		for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
		{
			qrmPlayer[i] = [[MTSourcePlayer alloc] initWithAU:qrmUnit[i]];
		}
	
		[self setQRMStations:0];
		[self setNoise:NO];		
	}
	
	return self;
}

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
	AUNode cwNode;
	cd.componentType = kAudioUnitType_Generator;
	cd.componentSubType = kAudioUnitSubType_ScheduledSoundPlayer;
	AUGraphAddNode(graph, &cd, &cwNode);
	AUGraphConnectNodeInput(graph, cwNode, 0, mixerNode, cwMixerElement);
	
	// Noise
	AUNode noiseNode;
	cd.componentType = kAudioUnitType_Generator;
	cd.componentSubType = kAudioUnitSubType_ScheduledSoundPlayer;
	AUGraphAddNode(graph, &cd, &noiseNode);
	AUGraphConnectNodeInput(graph, noiseNode, 0, mixerNode, noiseMixerElement);
	
	AUNode qrmNode[kMaxQRMStations];
	for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
	{
		cd.componentType = kAudioUnitType_Generator;
		cd.componentSubType = kAudioUnitSubType_ScheduledSoundPlayer;
		AUGraphAddNode(graph, &cd, &(qrmNode[i]));
		AUGraphConnectNodeInput(graph, qrmNode[i], 0, mixerNode, baseQRMElement + i);
	}
	
	AUGraphOpen(graph);
	
	AUGraphNodeInfo(graph, cwNode, 0, &cwUnit);
	AUGraphNodeInfo(graph, noiseNode, 0, &noiseUnit);
	AUGraphNodeInfo(graph, mixerNode, 0, &mixerUnit);
	AUGraphNodeInfo(graph, outputNode, 0, &outputUnit);
	
	for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
	{
		AUGraphNodeInfo(graph, qrmNode[i], 0, &(qrmUnit[i]));
	}
	
	AudioStreamBasicDescription aa;
	UInt32 size = sizeof(aa);
	ComponentResult err = AudioUnitGetProperty(cwUnit, 
							   kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &aa, &size);
	CHECK_ERR(err, @"Getting StreamFormat Property from cwUnit");
	
	// Get Info from cwUnit and modify the channels to be 1. Then apply that to
	// everything else.
	aa.mChannelsPerFrame = 1;

	err = AudioUnitSetProperty(cwUnit, 
							   kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &aa, size);
	CHECK_ERR(err, @"Setting StreamFormat Property for cwUnit/Output");

	err = AudioUnitSetProperty(noiseUnit, 
							   kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &aa, size);
	CHECK_ERR(err, @"Setting StreamFormat Property for noiseUnit/Output");

	
	for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
	{
		err = AudioUnitSetProperty(qrmUnit[i], 
								   kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &aa, size);
		CHECK_ERR(err, @"Setting StreamFormat Property for qrmUnit /Output");		
	}
		
	err = AudioUnitSetProperty(outputUnit, 
							   kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &aa, size);
	CHECK_ERR(err, @"Setting StreamFormat Property for outputUnit/Input");
	
	AUGraphInitialize(graph);

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
	}
	else
	{
		[noisePlayer setEnabled:NO];
	}
	[self setVolume:noiseMixerElement withValue:noiseLevel];
}

-(BOOL)stopped
{
	return isStopped;
}

-(void)playCW:(id<MTSoundSource>)theSource
{
	isStopped = NO;

	[theSource setTextTracking:YES];
	[theSource reset];
	[cwPlayer setSource:theSource];
	[cwPlayer registerCompletionCallback:CWComplete userData:self];
	
	MTNoiseSource* noiseSource = [[MTNoiseSource alloc] init];
	[noiseSource reset];
	[noisePlayer setSource:noiseSource];
	
	for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
	{
		MTQRMSource* qrmSource = [[MTQRMSource alloc] initWithID:i];
		[qrmSource reset];
		
		[qrmPlayer[i] setSource:qrmSource];
	}
	
	AUGraphStart(graph);	
	CAShow(graph);
	
	[cwPlayer setEnabled:YES];
	[cwPlayer start];
	[noisePlayer start];
	for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
	{
		[qrmPlayer[i] start];
	}
}	

-(void)stop
{
	isStopped = YES;
	AUGraphStop(graph);
	
	[cwPlayer stop];
	[noisePlayer stop];
	for(NSUInteger i = 0; i < kMaxQRMStations; ++i)
	{
		[qrmPlayer[i] stop];
	}
}

-(void)setTextTrackingCallback:(TextTrackingCallback)theCallback userData:(void*)theData;
{
	[cwPlayer registerTextTrackingCallback:theCallback userData:theData];
}

@end

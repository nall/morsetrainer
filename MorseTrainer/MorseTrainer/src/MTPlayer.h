//
//  MTPlayer.h
//  MorseTrainer
//
//  Created by Jon Nall on 7/30/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <AudioToolbox/AudioToolbox.h>
#import "MTSourcePlayer.h"
#include "MTDefines.h"

@interface MTPlayer : NSObject
{
	AUGraph graph;

	AudioUnit cwUnit;
    AudioUnit cwConverterUnit;
	AudioUnit noiseUnit;
    AudioUnit noiseConverterUnit;
	AudioUnit mixerUnit;
	AudioUnit outputUnit;
	AudioUnit qrmUnit[kMaxQRMStations];
	AudioUnit qrmConverterUnit[kMaxQRMStations];
	
	MTSourcePlayer* cwPlayer;
	MTSourcePlayer* qrmPlayer[kMaxQRMStations];
	MTSourcePlayer* noisePlayer;
	
	BOOL isStopped;
    BOOL isPaused;
    BOOL isPlaying;
}

-(void)playCW:(id<MTSoundSource>)theSource;
-(BOOL)paused;
-(void)pause;
-(BOOL)playing;
-(void)play;
-(BOOL)stopped;
-(void)stop;

-(void)setQRMStations:(NSUInteger)numStations;
-(void)setNoise:(double)noiseLevel;
@end

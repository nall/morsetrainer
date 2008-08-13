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

#define kMaxQRMStations 3 // define instead of const int to be used in array decls

@interface MTPlayer : NSObject
{
	AUGraph graph;

	AudioUnit cwUnit;
	AudioUnit noiseUnit;
	AudioUnit mixerUnit;
	AudioUnit outputUnit;
	AudioUnit qrmUnit[kMaxQRMStations];
	
	MTSourcePlayer* cwPlayer;
	MTSourcePlayer* qrmPlayer[kMaxQRMStations];
	MTSourcePlayer* noisePlayer;
	
	BOOL isStopped;
}
// Private
-(void)initGraph;

// Public
-(BOOL)stopped;
-(void)playCW:(id<MTSoundSource>)theSource;
-(void)stop;

-(void)setQRMStations:(NSUInteger)numStations;
-(void)setNoise:(double)noiseLevel;

-(void)setTextTrackingCallback:(TextTrackingCallback)theCallback userData:(void*)theData;
@end

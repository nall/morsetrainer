//
//  SoundPlayer.h
//  MorseTrainer
//
//  Created by Jon Nall on 7/29/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <AudioToolbox/AudioToolbox.h>
#import "MTSoundSource.h"

@class MTSourcePlayer;

@interface MTSourcePlayer : NSObject
{	
	id<MTSoundSource> source;
	
	NSUInteger offset;
	AudioUnit unit;
	
	struct ScheduledAudioSlice* sliceRing;
	NSUInteger slicesInProgress;
	
	BOOL enabled;
}

// Private
-(NSUInteger)scheduleSlices;

// Friendly (used by callbacks)
-(void)sliceCompleted:(ScheduledAudioSlice*)theSlice;

// Public
-(id)initWithAU:(AudioUnit)theUnit;
-(id)initWithSource:(id<MTSoundSource>)theSource withAU:(AudioUnit)theUnit;
-(void)setSource:(id<MTSoundSource>)theSource;
-(NSString*)name;
-(void)reset;
-(void)start;
-(void)stop;

-(void)setEnabled:(BOOL)isEnabled;
-(BOOL)enabled;

@end

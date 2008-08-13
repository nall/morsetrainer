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

typedef void(*SourcePlayerCompletionCallback)(MTSourcePlayer* player, void* userData);
typedef void(*TextTrackingCallback)(MTSourcePlayer* player, NSString* textString, void* userData);

@interface MTSourcePlayer : NSObject
{	
	id<MTSoundSource> source;
	
	NSUInteger offset;
	AudioUnit unit;
	
	struct ScheduledAudioSlice* sliceRing;
	NSUInteger slicesInProgress;
	
	BOOL enabled;
	
	SourcePlayerCompletionCallback completionCallback;
	void* completionCallbackData;
	
	TextTrackingCallback textCallback;
	void* textCallbackData;
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
-(void)start;
-(void)stop;

-(void)setEnabled:(BOOL)isEnabled;
-(BOOL)enabled;

-(void)registerCompletionCallback:(SourcePlayerCompletionCallback)theCallback
						 userData:(void*)theData;
-(void)registerTextTrackingCallback:(TextTrackingCallback)theCallback
						   userData:(void*)theData;


@end

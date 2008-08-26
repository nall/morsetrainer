//
//  MTSourcePlayer.m
//  MorseTrainer
//
//  Created by Jon Nall on 7/29/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import "MTOperationQueue.h"
#import "MTSourcePlayer.h"
#include "MTDefines.h"

void sourcePlayerCompleteProc(void* arg, ScheduledAudioSlice* slice)
{
	static NSUInteger count = 0;
	++count;
	
	MTSourcePlayer* player = arg;

	// NSLog(@"%@: completionCallback for offset %f", [player name], slice->mTimeStamp.mSampleTime);
	if(slice->mFlags & kScheduledAudioSliceFlag_BeganToRenderLate)
	{
		NSLog([NSString stringWithFormat:@"WARNING: Late render on %@", [player name]]);
	}
	
	[player sliceCompleted:slice];
}

@interface MTSourcePlayer (Private)
-(NSUInteger)scheduleSlices;
-(void)invokeTextTrackingCallback:(NSString*)theText;
@end

@implementation MTSourcePlayer

-(id)initWithAU:(AudioUnit)theUnit
{
	unit = theUnit;
	offset = 0;
	
	enabled = NO;
	
	
	slicesInProgress = 0;
	
	sliceRing = (struct ScheduledAudioSlice*)calloc(kNumSlices, sizeof(struct ScheduledAudioSlice));
	bzero(sliceRing, sizeof(struct ScheduledAudioSlice) * kNumSlices);
	
	AudioTimeStamp timestamp;
	bzero(&timestamp, sizeof(timestamp));
	timestamp.mFlags = kAudioTimeStampSampleTimeValid;
	timestamp.mSampleTime = -1.; // Play immediately
	
	for(NSUInteger s = 0; s < kNumSlices; ++s)
	{
		sliceRing[s].mTimeStamp = timestamp;
		sliceRing[s].mCompletionProc = sourcePlayerCompleteProc;
		sliceRing[s].mCompletionProcUserData = self;
		
		sliceRing[s].mNumberFrames = kMaxFrameSize;
		sliceRing[s].mFlags = kScheduledAudioSliceFlag_Complete;
		sliceRing[s].mReserved = 0;
		
		
		AudioBuffer buffer;
		bzero(&buffer, sizeof(buffer));
		buffer.mNumberChannels = 1;
		buffer.mDataByteSize = kMaxFrameSize * sizeof(float);		
		buffer.mData = calloc(kMaxFrameSize, sizeof(float));
		
		AudioBufferList* bufferList = (AudioBufferList*)malloc(sizeof(AudioBufferList));
		bzero(bufferList, sizeof(bufferList));
		bufferList->mNumberBuffers = 1;
		bufferList->mBuffers[0] = buffer;
		
		sliceRing[s].mBufferList = bufferList;
	}
	
	return self;
}

-(void)dealloc
{
	if(sliceRing != nil)
	{
		for(int s = 0; s < kNumSlices; ++s)
		{
			for(int b = 0; b < sliceRing[s].mBufferList->mNumberBuffers; ++b)
			{
				free(sliceRing[s].mBufferList->mBuffers[b].mData);
			}
		}
        
		free(sliceRing);
		sliceRing = nil;
	}
	
	[super dealloc];
}

-(void)setSource:(id<MTSoundSource>)theSource
{
	source = theSource;
}

-(void)setEnabled:(BOOL)isEnabled
{
	enabled = isEnabled;
}

-(BOOL)enabled
{
	return enabled;
}

-(NSString*)name
{
	return [source name];
}

-(void)sliceCompleted:(ScheduledAudioSlice*)theSlice;
{
	--slicesInProgress;
	
	if([source supportsTextTracking])
	{
		NSString* text = [source getTextForTime:theSlice->mTimeStamp.mSampleTime];
		if([text length] > 0)
		{
			NSInvocationOperation* theOp = [[NSInvocationOperation alloc]
											initWithTarget:self
											selector:@selector(invokeTextTrackingCallback:)
											object:text];	
			
			[[MTOperationQueue operationQueue] addOperation:theOp];
		}		
	}
	
    if(slicesInProgress == 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifSoundPlayerComplete object:self];
    }
    
    
	// If player becomes disabled, don't schedule any more
	if([self enabled])
	{
		[self scheduleSlices];
	}    
}


-(void)reset
{
    [source reset];
}

-(void)start
{
	if(![self enabled])
	{
		return;
	}
	
	AudioTimeStamp timestamp;
	bzero(&timestamp, sizeof(timestamp));
	timestamp.mFlags = kAudioTimeStampSampleTimeValid;
	timestamp.mSampleTime = -1.; // Play immediately
	
	ComponentResult err = noErr;
	err = AudioUnitSetProperty(unit, kAudioUnitProperty_ScheduleStartTimeStamp,
							   kAudioUnitScope_Global, 0, &timestamp, sizeof(timestamp));
	if(err != noErr)
	{
		NSLog(@"ERROR: Can't set unit start time stamp");
	}		
	else
	{
		
		NSUInteger scheduledSlices = 0;
		do
		{
			scheduledSlices = [self scheduleSlices];
		}
		while(scheduledSlices == 0);
	}
}

-(void)stop
{
	[self setEnabled:NO];
	offset = 0;
	ComponentResult err = AudioUnitReset(unit, kAudioUnitScope_Global, 0);
	if(err != noErr)
	{
		NSLog(@"ERROR: Couldn't reset audio unit");
	}
}
@end

@implementation MTSourcePlayer (Private)

-(NSUInteger)scheduleSlices
{
	// Iterate through the slices and find any that are free. Fill those with
	// data from our data, schedule them, and update our bookkeeping.
    
	int freeSlices = 0;
	int scheduledSlices = 0;
	for(NSUInteger s = 0; s < kNumSlices; ++s)
	{
		if(!(sliceRing[s].mFlags & kScheduledAudioSliceFlag_Complete))
		{
			// Don't bother with slices that still need to be played
			continue;
		}
		
		++freeSlices;
		
		// Setup frame request and issue to the sound source
		sliceRing[s].mBufferList->mBuffers[0].mDataByteSize = (kMaxFrameSize * sizeof(float));
		const NSUInteger numFrames = [source populateSlice:&(sliceRing[s])];
        
		if(numFrames == 0)
		{
			continue;
		}
		
		// Continue filling out slice, based on response from source
		sliceRing[s].mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
		sliceRing[s].mTimeStamp.mSampleTime = offset;
		sliceRing[s].mNumberFrames = numFrames;
		sliceRing[s].mBufferList->mBuffers[0].mDataByteSize = numFrames * sizeof(float);
        
		offset += numFrames;
		
		++slicesInProgress;
		++scheduledSlices;
		// NSLog(@"%@: scheduled @ %d", [self name], offset);
		ComponentResult err = AudioUnitSetProperty(unit,
												   kAudioUnitProperty_ScheduleAudioSlice,
												   kAudioUnitScope_Global,
												   0,
												   &(sliceRing[s]),
												   sizeof(struct ScheduledAudioSlice));
		if(err != noErr)
		{
			NSLog(@"ERROR: Can't schedule slice %d to play", s);
			return (kNumSlices - freeSlices);
		}			
	}
	
	if(freeSlices == 0)
	{
		NSLog(@"WARNING: No free slices were available");
	}
	
	// Return the number of scheduled slices
	return scheduledSlices;
}

-(void)invokeTextTrackingCallback:(NSString*)theText
{
    if([self enabled])
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setObject:theText forKey:kNotifTextKey];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifTextWasPlayed object: self userInfo:dict];        
    }
}

@end
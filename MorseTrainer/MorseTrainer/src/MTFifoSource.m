//
//  MTFifoSource.m
//  MorseTrainer
//
//  Created by Jon Nall on 7/30/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import "MTFifoSource.h"
#import "MTOperationQueue.h"
#include "MTDefines.h"

@implementation MTFifoSource

-(id)init
{
	if([super init] != nil)
	{
		// Empty level is 2 slices
		fifo = [[MTFIFO alloc] initWithSize:kFifoDepth withEmptyLevel:kFifoPartialEmpty];
	}
	
	return self;
	
}

-(NSData*)generateData:(NSNumber*)floatsAvailable
{
	// It is an error to run this...
	assert(0);
	
	return nil;
}

-(void)dataFill:(NSNumber*)floatsAvailable
{
	NSData* theData = [self generateData:floatsAvailable];
	
	@synchronized(fifo)
	{
		[fifo pushData:theData];		
	}
}

-(void)initiateDataFill
{
	// Create the NSOperation to fill the FIFO and set theOp as a dependency
	NSInvocationOperation* theOp = [[NSInvocationOperation alloc]
									initWithTarget:self
									selector:@selector(dataFill:)
									object:[NSNumber numberWithUnsignedInt:[fifo floatsAvailable]]];	

	[[MTOperationQueue operationQueue] addOperation:theOp];
}

-(NSString*)name
{
	return @"MTFifoSource";
}

-(void)reset
{
	@synchronized(fifo)
	{
		[fifo drain];		
	}
	
	[self dataFill:[NSNumber numberWithUnsignedInt:[fifo floatsAvailable]]];
}

-(NSInteger)populateSlice:(ScheduledAudioSlice*)theSlice
{
	NSUInteger frames = 0;
	@synchronized(fifo)
	{
		const NSUInteger framesLeft = [fifo count];
		
		if(framesLeft == 0)
		{
			return 0;
		}
		
		float* buffer = theSlice->mBufferList->mBuffers[0].mData;
		NSUInteger bufferSize = theSlice->mBufferList->mBuffers[0].mDataByteSize;
		NSUInteger numChannels = theSlice->mBufferList->mBuffers[0].mNumberChannels;
		NSUInteger bufferSamples = bufferSize / sizeof(float);
		NSUInteger bufferFrames = bufferSamples / numChannels;
		
		if(numChannels > 1)
		{
			NSLog(@"WARNING: MTFifoSource only supports 1 channel");
			return 0;
		}
		
		frames = (framesLeft < bufferFrames) ? framesLeft : bufferFrames;
		const NSUInteger numBytes = frames * sizeof(float);
		
		
		NSData* frameData = [fifo popData:frames];
		memcpy(buffer, [frameData bytes], numBytes);
		
		if([fifo isPartiallyEmpty])
		{
			[self initiateDataFill];
		}
	}
	
	return frames;	
}

-(void)setTextTracking:(BOOL)isEnabled
{
	
}

-(BOOL)supportsTextTracking
{
	return NO;
}

-(NSString*)getTextForTime:(Float64)theTime
{
	return nil;
}

@end

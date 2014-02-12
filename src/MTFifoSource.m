//
// MTFifoSource.m
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




#import "MTFifoSource.h"
#import "MTOperationQueue.h"
#include "MTDefines.h"

@interface MTFifoSource (Private)
    -(void)dataFill:(NSNumber*)floatsAvailable;
    -(void)initiateDataFill;
@end

@implementation MTFifoSource

-(id)init
{
	if([super init] != nil)
	{
		fifo = [[MTFIFO alloc] initWithSize:kFifoDepth withEmptyLevel:kFifoPartialEmpty];
        auFile = nil;
	}
	
	return self;	
}

-(void)dealloc
{
    if(auFile != nil)
    {
        [auFile closeFile];        
    }
}

-(void)dumpAU:(NSString*)theFilename
{
    auFile = [NSFileHandle fileHandleForWritingAtPath:theFilename]; 
    
    NSMutableData* header = [[NSMutableData alloc] initWithLength:(6 * sizeof(float))];
    float* data = [header mutableBytes];
    data[0] = htonl(0x2e736e64);	// magic
    data[1] = htonl(24);			// bytes until data
    data[2] = htonl(~0);			// data size unknown
    data[3] = htonl(6);				// data is 32 bit floating values
    data[4] = htonl(kSampleRate);	// sample rate
    data[5] = htonl(1);				// channels	
    
    [auFile writeData:header];
}


-(NSData*)generateData:(NSNumber*)floatsAvailable
{
	// It is an error to run this...
    NSLog(@"Internal Error. MTFifoSource::generateData was called");
    NSRunAlertPanel(@"Internal Error Occurred",
                    @"MTFifoSource::generateData was called",
                    @"Quit", nil, nil);
    exit(1);
	
	return nil;
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
		
        if(auFile != nil)
        {
            [auFile writeData:frameData];
        }
        
		if([fifo isPartiallyEmpty])
		{
			[self initiateDataFill];
		}
	}
	
	return frames;	
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

@implementation MTFifoSource (Private)
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


@end

//
// MTNoiseSource.m
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

// Contains source code from Noise application. The below is the required
// copyright notice. See NoiseLicense.pdf in this distribution for the
// details of that license.
// http://www.blackholemedia.com/noise
// Copyright © 2001, Blackhole Media
// All rights reserved.


#import "MTNoiseSource.h"


static unsigned long GenerateRandomNumber()
{
	static unsigned long randSeed = 22222;  /* Change this for different random sequences. */
	randSeed = (randSeed * 196314165) + 907633515;
	return randSeed;
}

@interface MTNoiseSource (Private)
- (void)initRandomEnv:(long)numRows;
@end

@implementation MTNoiseSource

-(id)init
{
	if([super init] != nil)
	{
		[self initRandomEnv:5];
	}
	
	return self;
}

- (void)goPink
{
	noise.goWhite = NO;
}

- (void)goWhite
{
	noise.goWhite = YES;
}

-(NSString*)name
{
	return @"MTNoiseSource";
}

-(void)reset
{
	// Nothing to do
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

-(NSInteger)populateSlice:(ScheduledAudioSlice*)theSlice
{
	float* buffer = theSlice->mBufferList->mBuffers[0].mData;
	NSUInteger bufferSize = theSlice->mBufferList->mBuffers[0].mDataByteSize;
	NSUInteger numChannels = theSlice->mBufferList->mBuffers[0].mNumberChannels;
	NSUInteger bufferSamples = bufferSize / sizeof(float);
	NSUInteger bufferFrames = bufferSamples / numChannels;
	
	// White Noise
	if(noise.goWhite)
	{
		for(NSUInteger sampleIndex = 0; sampleIndex < bufferFrames; ++sampleIndex)
		{
			const float sample = ((long)GenerateRandomNumber()) * (float)(1.0f / 0x7FFFFFFF);
			for(NSUInteger channel = 0; channel < numChannels; ++channel)
			{
				*buffer++ = sample;				
			}
		}
		return bufferFrames;
	}
	
	// Pink Noise
	for(NSUInteger sampleIndex = 0; sampleIndex < bufferFrames; ++sampleIndex)
	{
		long newRandom;
		
		// Increment and mask index
		noise.pinkIndex = (noise.pinkIndex + 1) & noise.pinkIndexMask;
		
		// If index is zero, don't update any random values
		if(noise.pinkIndex)
		{
			int numZeros = 0;
			int n = noise.pinkIndex;
			
			// Determine how many trailing zeros in pinkIndex
			// this will hang if n == 0 so test first
			while((n & 1) == 0)
			{
				n = n >> 1;
				++numZeros;
			}
			
			// Replace the indexed rows random value
			// Subtract and add back to pinkRunningSum instead of adding all 
			// the random values together. only one changes each time
			noise.pinkRunningSum -= noise.pinkRows[numZeros];
			newRandom = ((long)GenerateRandomNumber()) >> kPinkRandomShift;
			noise.pinkRunningSum += newRandom;
			noise.pinkRows[numZeros] = newRandom;
		}
		
		// Add extra white noise value
		newRandom = ((long)GenerateRandomNumber()) >> kPinkRandomShift;
		long sum = noise.pinkRunningSum + newRandom;
		
		// Scale to range of -1.0 to 0.999 and factor in volume
		const float sample = noise.pinkScalar * sum;
		
		// Write to all channels
		for(NSUInteger channel = 0; channel < numChannels; ++channel)
		{
			*buffer++ = sample;			
		}
	}
	
	return bufferFrames;
}

-(void)dumpAU:(NSString*)theFilename
{
    NSRunAlertPanel(@"Unsupported Operation", @"Dumping AU Files isn't supported for MTNoiseSource", @"OK", nil, nil);
}
@end

@implementation MTNoiseSource (Private)
- (void)initRandomEnv:(long)numRows
{
    int index;
	long pmax;
	
	noise.pinkIndex = 0;
	noise.pinkIndexMask = (1 << numRows) - 1;
	noise.goWhite = NO;
	
	// Calculate max possible signed random value. extra 1 for white noise always added
	pmax = (numRows + 1) * (1 << (kPinkRandomBits-1));
	noise.pinkScalar = 1.0f / pmax;
	
	// Initialize rows
	for( index = 0; index < numRows; index++ )
	{
		noise.pinkRows[index] = 0;		
	}
	noise.pinkRunningSum = 0;
}
@end
//
//  BufferGen.h
//  MorseTrainer
//
//  Created by Jon Nall on 7/28/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MTFifoSource.h"
#import "MTTimeUtils.h"

@interface MTCWSource : MTFifoSource
{
	BOOL genAU;
    
    BOOL lastGenerationWasCharacter;
	
	uint32_t samplerate;
	NSUInteger frequency;
	double amplitude;
	TextAnalysis analysis;
	
	BOOL trackingEnabled;
	Float64 currentSampleTime;
	NSMutableArray* sampleTimeChars;
	NSMutableArray* sampleTimeTimes;
	
	NSUInteger samplesPerPatternDit;
	NSUInteger samplesPerNonPatternDit;
	
	NSMutableString* morseText;
}

// Protected
-(NSData*)generateData:(NSNumber*)floatsAvailable;
-(NSUInteger)numCharsToGenerate;

// Public
-(id)initWithFrequency:(NSUInteger)theFrequency
		withSampleRate:(double)theRate
		 withAmplitude:(double)theAmplitude
		  withAnalysis:(TextAnalysis)theAnalysis;

-(void)appendText:(NSString*)theText;

@end

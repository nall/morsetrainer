//
// MTCWSource.h
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

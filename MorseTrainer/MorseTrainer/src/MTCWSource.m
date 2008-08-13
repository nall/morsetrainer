//
//  MTCWSource.m
//  MorseTrainer
//
//  Created by Jon Nall on 7/28/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import "MTCWSource.h"
#import "MTTimeUtils.h"
#import "MTPatternMap.h"
#include "MTDefines.h"
#include <arpa/inet.h> // endian routines
#include <wctype.h>

@implementation MTCWSource

-(id)initWithFrequency:(NSUInteger)theFrequency
		withSampleRate:(double)theRate
		 withAmplitude:(double)theAmplitude
		  withAnalysis:(TextAnalysis)theAnalysis
{
	if([super init] != nil)
	{
		genAU = NO;
		samplerate = theRate;
		frequency = theFrequency;
		amplitude = theAmplitude;
		analysis = theAnalysis;
		
		samplesPerPatternDit = 0;
		samplesPerNonPatternDit = 0;

		trackingEnabled = NO;
		currentSampleTime = 0.0;
		sampleTimeChars = [NSMutableArray array];
		sampleTimeTimes = [NSMutableArray array];
		
		morseText = [NSMutableString string];		
	}
	
	return self;
}

-(NSUInteger)generateSilence:(NSUInteger)numDits
				  withBuffer:(float*)buffer
			  usingActualWPM:(BOOL)useActualWPM
{
	const double samplesPerDit = (useActualWPM ? samplesPerPatternDit : samplesPerNonPatternDit);
	
	for(NSUInteger i = 0; i < (numDits * samplesPerDit); ++i)
	{
		buffer[i] = 0;
	}
	
	currentSampleTime += (numDits * samplesPerDit);
	return (numDits * samplesPerDit);
}

-(NSUInteger)generateTone:(NSUInteger)numDits withBuffer:(float*)buffer
{	
	uint32_t *bufbuf = (uint32_t*)buffer;
	
	double msPerDit = analysis.msPerPatternDit;
	double secondsPerDit = msPerDit / 1000.;
	double period = 1. / frequency;
	double totalSeconds = numDits * secondsPerDit;
	double totalCycles = frequency * totalSeconds;
	double fullCycles = floor(totalCycles);
	
	double soundDuration = fullCycles * period;
	NSUInteger soundSamples = soundDuration * samplerate;
	
	double val = 0.0;
	double increment = (fullCycles * 2. * M_PI) / soundSamples;

	// Emperical test says we need about 1ms of fade in fade out to avoid
	// popping, so we'll do 2ms. @ 100wpm PARIS timing this is 25% of a dit.
	double fadeTime = (2. * samplerate / 1000.);	
	double fadeInComplete = fadeTime;
	double fadeOutStart = (soundSamples - fadeTime);
	double fadeLevel = 0.0;
	
	for(NSUInteger i = 0; i <= soundSamples; ++i)
	{
		// Fade-In / Fade-Out
		if(i == 0 || i == (soundSamples - 1))
		{
			fadeLevel = 0.0;
		}
		else if((float)i <= fadeInComplete)
		{
			fadeLevel += 1.0 / fadeInComplete;
		}
		else if((float)i >= fadeOutStart)
		{
			fadeLevel -= 1.0 / fadeInComplete;
		}
		else
		{
			// No fading
			fadeLevel = 1.0;
		}
		
		buffer[i] = fadeLevel * amplitude * sin(val);
		
		if(genAU == YES)
		{
			bufbuf[i] = htonl(bufbuf[i]);
		}
		
		val += increment;			
	}
	
	// Fill up to the required samples with silence
	for(NSUInteger i = soundSamples + 1; i < (numDits * samplesPerPatternDit); ++i)
	{
		buffer[i] = 0;
	}
	
	currentSampleTime += (numDits * samplesPerPatternDit);

	return (numDits * samplesPerPatternDit);	
}

-(NSUInteger)generateChar:(NSString*)character withBuffer:(float*)buffer
{
	float* curBuf = buffer;
	NSString* pattern = [MTPatternMap getPattern:character];
	const NSUInteger length = [pattern length];
	
	for(NSUInteger i = 0; i < length; ++i)
	{
		const unichar c = [pattern characterAtIndex:i];
		if(i != 0)
		{
			curBuf += [self generateSilence:INTER_PATTERN_DITS
								 withBuffer:curBuf
							 usingActualWPM:YES];
		}
		
		if(c == '.')
		{
			curBuf += [self generateTone:DIT_DITS withBuffer:curBuf];
		}
		else if(c == '-')
		{
			curBuf += [self generateTone:DAH_DITS withBuffer:curBuf];			
		}
		else
		{
			NSLog(@"ERROR: Non-dit/dah found in pattern %@", pattern);
			exit(1);
		}
	}
	
	NSString* string = [character length] == 1 ? character : [NSString stringWithFormat:@"(%@)", character];
	
	[sampleTimeChars addObject:string];
	[sampleTimeTimes addObject:[NSNumber numberWithFloat:currentSampleTime]];
	
	return (curBuf - buffer);
}

-(NSUInteger)generateText:(NSString*)text withBuffer:(float*)buffer
{
	const NSUInteger length = [text length];
	
	float* curBuf = buffer;
	BOOL isFirstCharInWord = YES;
	for(NSUInteger i = 0; i < length; ++i)
	{
		const unichar c = [text characterAtIndex:i];
		if(iswspace(c))
		{
			curBuf += [self generateSilence:INTER_PHRASE_DITS
								 withBuffer:curBuf
							 usingActualWPM:NO];
			isFirstCharInWord = YES;

			[sampleTimeChars addObject:[NSString stringWithFormat:@"%c", c]];
			[sampleTimeTimes addObject:[NSNumber numberWithFloat:currentSampleTime]];
		}
		else
		{
			if(isFirstCharInWord == NO)
			{
				curBuf += [self generateSilence:INTER_WORD_DITS
									 withBuffer:curBuf
								 usingActualWPM:NO];
			}
			isFirstCharInWord = NO;
			
			// Handle prosigns, which have the form: ^XX
			if([text characterAtIndex:i] == '^')
			{
				NSMutableString* prosign = [NSMutableString string];
				
				i = [MTPatternMap parseProsign:text atIndex:i finalProsign:prosign];
				
				curBuf += [self generateChar:prosign withBuffer:curBuf];			
			}
			else{
				curBuf += [self generateChar:[text substringWithRange:NSMakeRange(i, 1)] withBuffer:curBuf];			
			}
			
		}
	}
	
	return (curBuf - buffer);
}

-(NSData*)generate:(NSString*)theText
{
	const NSUInteger headerBytes = genAU ? 6 : 0;

	TextAnalysis textAnalysis = [MTTimeUtils textDits:theText];
	
	{
		const double msPerDit = analysis.msPerPatternDit;
		samplesPerPatternDit = (samplerate / 1000.) * msPerDit;		
	}
	{
		const double msPerDit = analysis.msPerNonPatternDit;
		samplesPerNonPatternDit = (samplerate / 1000.) * msPerDit;		
	}
	
	NSUInteger totalSamples = (samplesPerPatternDit * textAnalysis.numPatternDitTimes) + 
		(samplesPerNonPatternDit * textAnalysis.numNonPatternDitTimes);
		
	const NSUInteger bytesRequired = (totalSamples * sizeof(float)) + (headerBytes * sizeof(uint32_t));
	
	if(bytesRequired == 0)
	{
		return [[NSData alloc] init];
	}
	

	NSMutableData* nsdata = [NSMutableData dataWithLength:bytesRequired];
	uint32_t* data = [nsdata mutableBytes];
	
	if(genAU == YES)
	{
		data[0] = htonl(0x2e736e64);	// magic
		data[1] = htonl(24);			// bytes until data
		data[2] = htonl(~0);			// data size unknown
		data[3] = htonl(6);				// data is 32 bit floating values
		data[4] = htonl(samplerate);	// sample rate
		data[5] = htonl(1);				// channels		
	}
	
	
	float* fdata = (float*)(&data[headerBytes]);

	NSUInteger bytesWritten = headerBytes * sizeof(uint32_t);
	bytesWritten += [self generateText:theText withBuffer:fdata] * sizeof(float);
	
	if(bytesWritten != bytesRequired)
	{
		NSLog(@"INTERNAL ERROR: bytesRequired: %d, bytesWritten: %d", bytesRequired, bytesWritten);
	}
	
	NSLog(@"generated %d bytes (%d floats) (%f is sample)", [nsdata length], ([nsdata length] / sizeof(float)), currentSampleTime);
	return nsdata;
}

-(NSUInteger)determineNumChars:(NSUInteger)floatsAvailable
{
	NSString* theText = [NSString stringWithString:morseText];
	
	while(TRUE)
	{
		const TextAnalysis textAnalysis = [MTTimeUtils textDits:theText];
		const double totalTimeInMS = (analysis.msPerPatternDit * textAnalysis.numPatternDitTimes) +
			(analysis.msPerNonPatternDit * textAnalysis.numNonPatternDitTimes);
		const double samplesPerMS = (samplerate / 1000.);
		
		const NSUInteger totalSamples = totalTimeInMS * samplesPerMS;
		
		// 1 sample == 1 float
		if(totalSamples <= floatsAvailable)
		{
			return [theText length];
		}
		else
		{
			// Try again with half the length
			theText = [theText substringFromIndex:([theText length] / 2)];
		}
	}
}

-(NSData*)generateData:(NSNumber*)floatsAvailable;
{
	// Generate more data based on morseText
	const NSUInteger numChars = [self determineNumChars:[floatsAvailable unsignedIntValue]];
	NSString* textToGenerate = [morseText substringToIndex:numChars];
	morseText = [NSMutableString stringWithString:[morseText substringFromIndex:numChars]];
	
	NSData* theData = [self generate:textToGenerate];	
	return theData;
}

-(NSUInteger)numCharsToGenerate
{
	return ([morseText length] > 0) ? 
			kCharsToFillCWSource :
			kCharsToFillCWSourceInitial;
}


-(void)appendText:(NSString*)theText
{
	[morseText appendString:theText];
}

-(NSString*)getTextForTime:(Float64)theTime
{
	NSMutableString* buf = [NSMutableString string];
	NSUInteger usedIndices = 0;
	for(NSUInteger i = 0; i < [sampleTimeTimes count]; ++i)
	{
		if(theTime >= [[sampleTimeTimes objectAtIndex:i] floatValue])
		{
			[buf appendString:[sampleTimeChars objectAtIndex:i]];
			++usedIndices;
		}
		else
		{
			break;
		}
	}
	
	[sampleTimeTimes removeObjectsInRange:NSMakeRange(0, usedIndices)];
	[sampleTimeChars removeObjectsInRange:NSMakeRange(0, usedIndices)];
	
	return buf;
}

-(void)setTextTracking:(BOOL)isEnabled
{
	trackingEnabled = isEnabled;
}

-(BOOL)supportsTextTracking
{
	return trackingEnabled;
}


@end

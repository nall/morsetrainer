//
//  MTFileSource.m
//  MorseTrainer
//
//  Created by Jon Nall on 8/7/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import "MTFileSource.h"
#include "MTDefines.h"

@implementation MTFileSource

-(id)initWithFile:(NSString*)theFilename
	withFrequency:(NSUInteger)theFrequency
   withSampleRate:(double)theRate
	withAmplitude:(double)theAmplitude
	 withAnalysis:(TextAnalysis)theAnalysis;
{
	if([super initWithFrequency:theFrequency
				 withSampleRate:theRate
				  withAmplitude:theAmplitude
				   withAnalysis:theAnalysis] != nil)
	{		
		file = [NSFileHandle fileHandleForReadingAtPath:theFilename];
		
		sourceName = [NSString stringWithFormat:@"FileSource{%@}", [theFilename lastPathComponent]];
	}
	
	return self;
}

-(NSFileHandle*)fileHandle
{
	return file;
}

-(NSData*)generateData:(NSNumber*)floatsAvailable
{
	NSData* fileData = [file readDataOfLength:[self numCharsToGenerate]];
	NSString* text = [[NSString alloc] initWithData:fileData encoding:NSASCIIStringEncoding];
	[self appendText:text];
	return [super generateData:floatsAvailable];
}

-(NSString*)name
{
	return sourceName;
}

-(void)reset
{
	[file seekToFileOffset:0];
	[super reset];
}

@end

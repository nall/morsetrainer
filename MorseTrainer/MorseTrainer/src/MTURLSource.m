//
//  MTURLSource.m
//  MorseTrainer
//
//  Created by Jon Nall on 8/7/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import "MTURLSource.h"
#include "MTDefines.h"

@implementation MTURLSource

-(id)initWithURL:(NSURL*)theURL
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
		url = theURL;
        
        // Currently only support files
        // TODO: FUll URL support
        assert([url isFileURL]);
        
        NSLog(@"path: %@", [url path]);
        theFile = [NSFileHandle fileHandleForReadingAtPath:[url path]];
		sourceName = [NSString stringWithFormat:@"FileSource{%@}", url];
	}
	
	return self;
}

-(NSData*)generateData:(NSNumber*)floatsAvailable
{
    NSData* buffer = [theFile readDataOfLength:[self numCharsToGenerate]];
    NSString* text = [[NSString alloc] initWithData:buffer encoding:NSASCIIStringEncoding];
    [self appendText:text];
    return [super generateData:floatsAvailable];                
}

-(NSString*)name
{
	return sourceName;
}

-(void)reset
{
    [theFile seekToFileOffset:0];
	[super reset];
}

@end

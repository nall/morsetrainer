//
//  MTRandomCWSource.m
//  MorseTrainer
//
//  Created by Jon Nall on 8/8/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import "MTRandomCWSource.h"
#import "MTDefines.h"

@implementation MTRandomCWSource
-(id)initWithCharset:(NSArray*)theCharset
	withFrequency:(NSUInteger)theFrequency
   withSampleRate:(double)theRate
	withAmplitude:(double)theAmplitude
	 withAnalysis:(TextAnalysis)theAnalysis
{	
	if([super initWithFrequency:theFrequency
				 withSampleRate:theRate
				  withAmplitude:theAmplitude
				   withAnalysis:theAnalysis] != nil)
	{
		charSet = [NSArray arrayWithArray:theCharset];
	}
	
	return self;
}

-(NSString*)name
{
	return @"Random CW Source";
}

-(void)reset
{
	// Nothing special to do here
	[super reset];
}

-(NSData*)generateData:(NSNumber*) floatsAvailable
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	
	const NSUInteger minCharsPerWord = [defaults integerForKey:@"minimumCharsPerGroup"];
	const NSUInteger maxCharsPerWord = [defaults integerForKey:@"maximumCharsPerGroup"];
	
	NSMutableString* sentence = [NSMutableString string];	
	const NSUInteger range = maxCharsPerWord - minCharsPerWord + 1;
	
	while(TRUE)
	{
		const NSUInteger groupLength = (random() % range) + minCharsPerWord;
		
		for(NSUInteger i = 0; i < groupLength; ++i)
		{
			const NSUInteger randIdx = random() % [charSet count];
			[sentence appendString:[charSet objectAtIndex:randIdx]];
		}
		[sentence appendString:@" "];
		
		if([sentence length] > [self numCharsToGenerate])
		{
			break;
		}
	}
		
	[self appendText:sentence];
	return [super generateData:floatsAvailable];
}


@end

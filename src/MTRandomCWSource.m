//
// MTRandomCWSource.m
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
	[super reset];
}

-(NSData*)generateData:(NSNumber*) floatsAvailable
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	
	const NSUInteger minCharsPerWord = [defaults integerForKey:kPrefMinimumCharsPerGroup];
	const NSUInteger maxCharsPerWord = [defaults integerForKey:kPrefMaximumCharsPerGroup];
	
	NSMutableString* sentence = [NSMutableString string];	
	const NSUInteger range = maxCharsPerWord - minCharsPerWord + 1;
	
	while(TRUE)
	{
		const NSUInteger groupLength = (random() % range) + minCharsPerWord;
		
		for(NSUInteger i = 0; i < groupLength; ++i)
		{
			const NSUInteger randIdx = random() % [charSet count];
            NSString* character = [charSet objectAtIndex:randIdx];
            if([character length] > 1)
            {
                character = [@"^" stringByAppendingString:character];
            }
            
			[sentence appendString:character];
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

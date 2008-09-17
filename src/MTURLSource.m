//
// MTURLSource.m
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
        if(![url isFileURL])
        {
            NSRunAlertPanel(@"URLs are not yet supported", @"Currently non-file URLs are unsupported. Please choose a regular file", @"OK", nil, nil);
            return nil;
        }
        
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

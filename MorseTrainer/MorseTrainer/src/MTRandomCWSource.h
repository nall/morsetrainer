//
//  MTRandomCWSource.h
//  MorseTrainer
//
//  Created by Jon Nall on 8/8/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MTCWSource.h"

@interface MTRandomCWSource : MTCWSource
{
	NSArray* charSet;
}

-(id)initWithCharset:(NSArray*)theCharset
	withFrequency:(NSUInteger)theFrequency
   withSampleRate:(double)theRate
	withAmplitude:(double)theAmplitude
	 withAnalysis:(TextAnalysis)theAnalysis;
@end

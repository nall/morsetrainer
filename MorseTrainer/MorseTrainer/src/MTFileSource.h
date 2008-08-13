//
//  MTFileSource.h
//  MorseTrainer
//
//  Created by Jon Nall on 8/7/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MTSoundSource.h"
#import "MTCWSource.h"

@interface MTFileSource : MTCWSource
{
	NSFileHandle* file;
	NSString* sourceName;
}
-(NSData*)generateData:(NSNumber*)floatsAvailable;

// Public
-(id)initWithFile:(NSString*)theFilename
	withFrequency:(NSUInteger)theFrequency
   withSampleRate:(double)theRate
	withAmplitude:(double)theAmplitude
	 withAnalysis:(TextAnalysis)theAnalysis;
@end

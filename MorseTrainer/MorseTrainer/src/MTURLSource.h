//
//  MTURLSource.h
//  MorseTrainer
//
//  Created by Jon Nall on 8/7/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MTSoundSource.h"
#import "MTCWSource.h"

@interface MTURLSource : MTCWSource
{
	NSURL* url;
    NSFileHandle* theFile;
	NSString* sourceName;
}
-(NSData*)generateData:(NSNumber*)floatsAvailable;

// Public
-(id)initWithURL:(NSURL*)theURL
	withFrequency:(NSUInteger)theFrequency
   withSampleRate:(double)theRate
	withAmplitude:(double)theAmplitude
	 withAnalysis:(TextAnalysis)theAnalysis;
@end

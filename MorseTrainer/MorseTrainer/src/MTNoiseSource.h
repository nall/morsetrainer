//
//  MTNoiseSource.h
//  MorseTrainer
//
//  Created by Jon Nall on 7/30/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//
//  Contains source code from Noise application. The below is the required
//  copyright notice. See NoiseLicense.pdf in the source distribution for the
//  details of that license.
//
//  Copyright (c) 2001, Blackhole Media
//  All rights reserved.


#import <Cocoa/Cocoa.h>
#import <CoreAudio/CoreAudio.h>
#import "MTSoundSource.h"


#define kPinkMaxRandomRows 32
#define kPinkRandomBits    30
#define kPinkRandomShift   ((sizeof(long)*8)-kPinkRandomBits)

typedef struct
{
    long pinkRows[kPinkMaxRandomRows];
    long pinkRunningSum;    // Used to optimize summing of generators
    int  pinkIndex;         // Incremented each sample
    int  pinkIndexMask;     // Index wrapped by &ing with this mask
    float pinkScalar;       // Used to scale within range of -1.0 to 1.0
    BOOL goWhite;
}PinkNoise;

@interface MTNoiseSource : NSObject<MTSoundSource>
{
    PinkNoise noise;
}
-(void)goPink;
-(void)goWhite;
@end

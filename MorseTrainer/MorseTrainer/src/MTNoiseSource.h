//
// MTNoiseSource.h
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

// Contains source code from Noise application. The below is the required
// copyright notice. See NoiseLicense.pdf in this distribution for the
// details of that license.
// http://www.blackholemedia.com/noise
// Copyright © 2001, Blackhole Media
// All rights reserved.



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

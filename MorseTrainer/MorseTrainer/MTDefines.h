/*
 *  MTDefines.h
 *  MorseTrainer
 *
 *  Created by Jon Nall on 7/28/08.
 *  Copyright 2008 STUNTAZ!!!. All rights reserved.
 *
 */

#ifndef __DEFINES_H_
#define __DEFINES_H_

#define DIT_DITS 1 
#define DAH_DITS 3 
#define INTER_PATTERN_DITS 1 
#define INTER_WORD_DITS 3 
#define INTER_PHRASE_DITS 7 

// Max wpm we'll support is 100wpm. At PARIS timing, this means 1 dittime is
// 12ms. At 44.1kHz, this means 1 dit will contain 529 samples @ 4 bytes each.
// This is 2.1kB. If a frame is 2kB, this gives us a granularity of 1 dit per
// completion @ 100wpm. This is acceptable to update a display with the
// character that completed.

#define kSampleRate 44100
#define kNumSlices 64
#define kMaxFrameSize 0x800 // 2kb

#define kFifoDepth 0x1000000 // 16Mb

// Set FIFO partial empty to 4 slices
#define kFifoPartialEmpty 0x2000

// Specify how many characters to append to a MTCWSource at a time
// Initial is shorter to speed up playing sound
#define kCharsToFillCWSourceInitial 20
#define kCharsToFillCWSource 80

// # Koch chars as defined here:
// http://www.njqrp.org/rookey/KMMT_Assy_Guide_v1%5B1%5D.0.pdf
#define kNumKochChars 43

#endif // __DEFINES_H_
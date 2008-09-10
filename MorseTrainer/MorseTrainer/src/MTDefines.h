//
// MTDefines.h
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

#include <Cocoa/Cocoa.h>

extern const NSUInteger kPatternLetter;
extern const NSUInteger kPatternNumber;
extern const NSUInteger kPatternPunctuation;
extern const NSUInteger kPatternProsign;
extern const NSUInteger kMaxPatternTypes;


extern const NSUInteger DIT_DITS;
extern const NSUInteger DAH_DITS;
extern const NSUInteger INTER_PATTERN_DITS;
extern const NSUInteger INTER_WORD_DITS;
extern const NSUInteger INTER_PHRASE_DITS; 

extern const NSUInteger kSampleRate;
extern const NSUInteger kNumSlices;
extern const NSUInteger kMaxFrameSize; // 2kb

extern const NSUInteger kFifoDepth; // 16Mb

// Set FIFO partial empty to 4 slices
extern const NSUInteger kFifoPartialEmpty;

// Specify how many characters to append to a MTCWSource at a time
// Initial is shorter to speed up playing sound
extern const NSUInteger kCharsToFillCWSourceInitial;
extern const NSUInteger kCharsToFillCWSource;

// Notification strings
extern NSString* const kNotifSoundPlayerComplete;
extern NSString* const kNotifTextWasPlayed;
extern NSString* const kNotifTextKey;
extern NSString* const kNotifCWComplete;

#define kSourceTypeURL    0
#define kSourceTypeCustom 1

// Preferences
extern NSString* const kPrefSourceType;
extern NSString* const kPrefTextFile;
extern NSString* const kPrefCharSet;
extern NSString* const kPrefKochCharset;
extern NSString* const kPrefActualWPM;
extern NSString* const kPrefEffectiveWPM;
extern NSString* const kPrefTonePitch;
extern NSString* const kPrefMinimumCharsPerGroup;
extern NSString* const kPrefMaximumCharsPerGroup;
extern NSString* const kPrefMinutesOfCopy;
extern NSString* const kPrefSignalStrength;
extern NSString* const kPrefNoiseLevel;
extern NSString* const kPrefNumQRMStations;
extern NSString* const kPrefWPMPhrase;

extern NSString* const kPrefWhiteNoise;

// Preference defaults
#define kMaxQRMStations 3 // define instead of const int to be used in array decls

extern const NSInteger kPrefMinWPM;
extern const NSInteger kPrefMaxWPM;
extern const NSInteger kPrefMinGroupChars;
extern const NSInteger kPrefMaxGroupChars;
extern const NSInteger kPrefMinMinutes;
extern const NSInteger kPrefMinTonePitch;
extern const NSInteger kPrefMaxTonePitch;
extern const NSInteger kPrefMinKochChars;

// Character Views
#define kPrefNumCharBoxes 5 // Number of views that are comprised of the form: NSBox -> NSMatrix

// Preference Panel Views
extern const NSUInteger kViewSource;
extern const NSUInteger kViewSending;
extern const NSUInteger kViewNoiseQRM;
extern const NSUInteger kViewUpdate;

extern NSString* const kCharViewAll;
extern NSString* const kCharViewLetters;
extern NSString* const kCharViewNumbers;
extern NSString* const kCharViewPunctuation;
extern NSString* const kCharViewProsigns;
extern NSString* const kCharViewKoch;

#endif // __DEFINES_H_
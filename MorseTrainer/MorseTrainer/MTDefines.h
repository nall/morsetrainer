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

// Max wpm we'll support is 100wpm. At PARIS timing, this means 1 dittime is
// 12ms. At 44.1kHz, this means 1 dit will contain 529 samples @ 4 bytes each.
// This is 2.1kB. If a frame is 2kB, this gives us a granularity of 1 dit per
// completion @ 100wpm. This is acceptable to update a display with the
// character that completed.

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

#define kSourceTypeCustom 0
#define kSourceTypeURL    1

// Preferences
extern NSString* const kPrefSourceType;
extern NSString* const kPrefTextFile;
extern NSString* const kPrefCharSet;
extern NSString* const kPrefKochCharset;
extern NSString* const kPrefKochChars;
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

// Preference defaults
#define kMaxQRMStations 3 // define instead of const int to be used in array decls

extern const NSUInteger kPrefMinWPM;
extern const NSUInteger kPrefMaxWPM;
extern const NSUInteger kPrefMinGroupChars;
extern const NSUInteger kPrefMaxGroupChars;
extern const NSUInteger kPrefMinMinutes;
extern const NSUInteger kPrefMinTonePitch;
extern const NSUInteger kPrefMaxTonePitch;
extern const NSUInteger kPrefMinKochChars;

// Character Views
#define kPrefNumCharBoxes 5 // Number of views that are comprised of the form: NSBox -> NSMatrix

extern NSString* const kCharViewAll;
extern NSString* const kCharViewLetters;
extern NSString* const kCharViewNumbers;
extern NSString* const kCharViewPunctuation;
extern NSString* const kCharViewProsigns;
extern NSString* const kCharViewKoch;

#endif // __DEFINES_H_
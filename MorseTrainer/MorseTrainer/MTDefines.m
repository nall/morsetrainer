//
//  MTDefines.m
//  MorseTrainer
//
//  Created by Jon Nall on = 8/15/08.
//  Copyright = 2008 STUNTAZ!!!. All rights reserved.
//

#include "MTDefines.h"

const NSUInteger kPatternLetter = 0;
const NSUInteger kPatternNumber = 1;
const NSUInteger kPatternPunctuation = 2;
const NSUInteger kPatternProsign = 3;
const NSUInteger kMaxPatternTypes = 4;

const NSUInteger DIT_DITS = 1;
const NSUInteger DAH_DITS = 3;
const NSUInteger INTER_PATTERN_DITS = 1;
const NSUInteger INTER_WORD_DITS = 3;
const NSUInteger INTER_PHRASE_DITS = 7; 

// Max wpm we'll support is 100wpm. At PARIS timing, this means 1 dittime is
// 12ms. At 44.1kHz, this means 1 dit will contain 529 samples @ 4 bytes each.
// This is 2.1kB. If a frame is 2kB, this gives us a granularity of 1 dit per
// completion @ 100wpm. This is acceptable to update a display with the
// character that completed.

const NSUInteger kSampleRate = 44100;
const NSUInteger kNumSlices = 64;
const NSUInteger kMaxFrameSize = 0x800; // 2kb

const NSUInteger kFifoDepth = 0x1000000; // 16Mb

// Set FIFO partial empty to = 4 slices
const NSUInteger kFifoPartialEmpty = 0x2000;

// Specify how many characters to append to a MTCWSource at a time
// Initial is shorter to speed up playing sound
const NSUInteger kCharsToFillCWSourceInitial = 10;
const NSUInteger kCharsToFillCWSource = 80;

NSString* const kNotifSoundPlayerComplete = @"MTNotifSoundPlayerComplete";
NSString* const kNotifTextWasPlayed = @"MTNotifTextWasPlayed";
NSString* const kNotifTextKey = @"text";

// Preferences
NSString* const kPrefSourceType = @"sourceType";
NSString* const kPrefTextFile = @"textFile";
NSString* const kPrefCharSet = @"charSet";
NSString* const kPrefKochCharset = @"kochCharset";
NSString* const kPrefActualWPM = @"actualWPM";
NSString* const kPrefEffectiveWPM = @"effectiveWPM";
NSString* const kPrefTonePitch = @"tonePitch";
NSString* const kPrefMinimumCharsPerGroup = @"minimumCharsPerGroup";
NSString* const kPrefMaximumCharsPerGroup = @"maximumCharsPerGroup";
NSString* const kPrefMinutesOfCopy = @"minutesOfCopy";
NSString* const kPrefSignalStrength = @"signalStrength";
NSString* const kPrefNoiseLevel = @"noiseLevel";
NSString* const kPrefNumQRMStations = @"qrmStations";
NSString* const kPrefWPMPhrase = @"wpmPhrase";

const NSUInteger kViewSource = 0;
const NSUInteger kViewSending = 1;
const NSUInteger kViewNoiseQRM = 2;
const NSUInteger kViewUpdate = 3;

// Preference defaults
const NSInteger kPrefMinWPM = 5;
const NSInteger kPrefMaxWPM = 100;
const NSInteger kPrefMinGroupChars = 1;
const NSInteger kPrefMaxGroupChars = 10;
const NSInteger kPrefMinMinutes = 0;
const NSInteger kPrefMinTonePitch = 300;
const NSInteger kPrefMaxTonePitch = 800;
const NSInteger kPrefMinKochChars = 2;      // K & M

NSString* const kCharViewAll = @"All Characters";
NSString* const kCharViewLetters = @"Letters";
NSString* const kCharViewNumbers = @"Numbers";
NSString* const kCharViewPunctuation = @"Punctuation";
NSString* const kCharViewProsigns = @"Prosigns";
NSString* const kCharViewKoch = @"Koch Characters";

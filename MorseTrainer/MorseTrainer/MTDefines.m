//
// MTDefines.m
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
// Foobar is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with Foobar.  If not, see <http://www.gnu.org/licenses/>.



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
//
// Compare to 8kHz where 1 dit contains 96 samples of 4 bytes each (384 bytes).
// In this case, we could play 2-3 E's before updating the display, so we should
// dial down the slice size to 512.


// const NSUInteger kSampleRate = 44100;
// const NSUInteger kMaxFrameSize = 2048;

const NSUInteger kSampleRate = 8000;
const NSUInteger kMaxFrameSize = 512;

const NSUInteger kNumSlices = 64;

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
NSString* const kPrefWhiteNoise = @"useWhiteNoise";

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

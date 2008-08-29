//
// MTTimeUtils.h
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



#import <Cocoa/Cocoa.h>

typedef struct TextAnalysis
{
	NSUInteger numNonPatternDitTimes;
	NSUInteger numPatternDitTimes;
	
	double msPerPatternDit;
	double msPerNonPatternDit;
} TextAnalysis;

@interface MTTimeUtils : NSObject
{

}

// Private

// Public Static
+(NSUInteger)charDits:(NSString*)character;
+(TextAnalysis)textDits:(NSString*)text;
+(TextAnalysis)analyzeText:(NSString*)theText
			 withActualWPM:(NSUInteger)actualWPM
		  withEffectiveWPM:(NSUInteger)effectiveWPM;

@end

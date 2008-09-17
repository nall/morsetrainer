//
// MTSoundSource.h
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
 *  MTSoundSource.h
 *  MorseTrainer
 *
 *  Created by Jon Nall on 7/30/08.
 *  Copyright 2008 STUNTAZ!!!. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
#include <AudioToolbox/AudioToolbox.h>

@protocol MTSoundSource
@required

// Populate the mData member of the given slice. The size of the request is
// specified in mDataByteSize. The actual number of frames written should
// be returned.
-(NSInteger)populateSlice:(ScheduledAudioSlice*)theSlice;
-(NSString*)name;
-(void)reset;

-(void)setTextTracking:(BOOL)isEnabled;
-(BOOL)supportsTextTracking;
-(NSString*)getTextForTime:(Float64)theTime;

-(void)dumpAU:(NSString*)theFilename;
@end
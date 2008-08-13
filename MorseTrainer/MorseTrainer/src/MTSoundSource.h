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

@end
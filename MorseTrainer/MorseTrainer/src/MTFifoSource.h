//
//  MTFifoSource.h
//  MorseTrainer
//
//  Created by Jon Nall on 7/30/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MTSoundSource.h"
#import "MTFIFO.h"

@class MTFifoSource;

@interface MTFifoSource : NSObject<MTSoundSource>
{
	MTFIFO* fifo;
}

// Private
-(void)initiateDataFill;

// Protected
-(NSData*)generateData:(NSNumber*)floatsAvailable;

-(NSInteger)populateSlice:(ScheduledAudioSlice*)theSlice;
-(NSString*)name;
-(void)reset;

// Public


@end

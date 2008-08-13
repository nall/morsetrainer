//
//  MTFIFO.h
//  MorseTrainer
//
//  Created by Jon Nall on 8/7/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MTFIFO : NSObject
{
	float* data;
	NSUInteger dataLength;
	NSUInteger rdPtr;		// Points to the next byte to be read
	NSUInteger endPtr;		// Points to the first invalid byte
	// FIFO is empty when rdPtr == endPtr	

	NSUInteger emptyLevel;
}
-(id)initWithSize:(NSUInteger)theSize withEmptyLevel:(NSUInteger)theEmptyLevel;
-(BOOL)isEmpty;
-(BOOL)isPartiallyEmpty;
-(NSUInteger)count;
-(void)drain;
-(NSUInteger)floatsAvailable;
-(NSData*)popData:(NSUInteger)numFloats;
-(void)pushData:(NSData*)theData;

@end

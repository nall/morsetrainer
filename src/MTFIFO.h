//
// MTFIFO.h
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

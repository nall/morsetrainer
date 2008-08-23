//
//  FIFO.m
//  MorseTrainer
//
//  Created by Jon Nall on 8/7/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import "MTFIFO.h"

@interface MTFIFO (Private)
-(void)checkConsistency;
@end

@implementation MTFIFO
-(id)init
{
	if([super init] != nil)
	{
		data = NULL;
		rdPtr = 0;
		endPtr = 0;
		emptyLevel = 0;
	}
	
	return self;
}

-(id)initWithSize:(NSUInteger)theSize withEmptyLevel:(NSUInteger)theEmptyLevel
{
	if([self init] != nil)
	{
		dataLength = theSize;
		emptyLevel = emptyLevel;
		rdPtr = 0;
		endPtr = 0;
		data = calloc(dataLength, sizeof(float));
		
		if(data == NULL)
		{
			NSLog([NSString stringWithFormat:@"ERROR: Cannot allocate %d floats", dataLength]);
			return nil;
		}
	}
	
	return self;
}

-(void)dealloc
{
	if(data != NULL)
	{
		free(data);
		data = NULL;
	}
	
	[super dealloc];
}

-(NSUInteger)count
{
	//   R   E			// E - R
	// * * * * * * *
	
	//   E     R        // E + (length - R + 1)
	// * * * * * * *
	
	const NSUInteger count = (rdPtr <= endPtr) ? (endPtr - rdPtr) :
			(endPtr + (dataLength - rdPtr + 1));
	
	return count;
}

-(BOOL)isEmpty
{
	return rdPtr == endPtr;
}

-(BOOL)isPartiallyEmpty
{
	return [self isEmpty] || [self count] <= emptyLevel;
}

-(NSUInteger)floatsAvailable
{
	return dataLength - [self count];
}

-(void)drain
{
	rdPtr = 0;
	endPtr = 0;
}

-(void)pushData:(NSData*)theData
{
	const NSUInteger numFloats = [theData length] / sizeof(float);

	const float* floats = (const float*)[theData bytes];
	const NSUInteger floatsAtEnd = dataLength - endPtr;

	const NSUInteger remainingEntries = dataLength - [self count];
	if(numFloats > remainingEntries)
	{
		NSLog(@"ERROR: Trying to push more data that FIFO can hold (pushing %d bytes with %d available)", numFloats, remainingEntries);
		return;
	}
	
	if((rdPtr <= endPtr) && floatsAtEnd >= numFloats)
	{
		// Easy case. RD <= END && (END + PUSH <= LENGTH)
		memcpy(&(data[endPtr]), floats, [theData length]);		
		endPtr += numFloats;
	}
	else if((rdPtr <= endPtr) && floatsAtEnd < numFloats)
	{
		// RD <= END && (END + PUSH > LENGTH)
		// Copy from endPtr to dataLength
		memcpy(&(data[endPtr]), floats, floatsAtEnd * sizeof(float));
		memcpy(&(data[0]), &(floats[floatsAtEnd]), (numFloats - floatsAtEnd) * sizeof(float));

        // endPtr wraps around in this case
		endPtr = (numFloats - floatsAtEnd);
	}
	else if((rdPtr > endPtr) && (endPtr + numFloats < rdPtr))
	{
		// RD > END && (END + PUSH < RD)
		// Basically the same as case #1
		memcpy(&(data[endPtr]), floats, [theData length]);
		endPtr += numFloats;
	}
	else
	{
        NSLog(@"Internal Error. Invalid FIFO condition (rdPtr = %d, endPtr = %d, numFloats = %d)",
              rdPtr, endPtr, numFloats);
        NSRunAlertPanel(@"Internal Error",
                        @"Internal Error. Invalid FIFO condition (rdPtr = %d, endPtr = %d, numFloats = %d)",
                        @"Quit", nil, nil, rdPtr, endPtr, numFloats);
        exit(1);
	}

    [self checkConsistency];
}

-(NSData*)popData:(NSUInteger)numFloats
{
	if(numFloats > [self count])
	{
		NSLog(@"ERROR: Trying to pop more floats than exist in FIFO");
		return nil;
	}
	else
	{
		NSMutableData* nsdata = [NSMutableData dataWithLength:(numFloats * sizeof(float))];
		float* floats = (float*)[nsdata mutableBytes];
		if(rdPtr < endPtr)
		{
			memcpy(floats, &data[rdPtr], (numFloats * sizeof(float)));		
			rdPtr += numFloats;
		}
        else if((rdPtr > endPtr) && (rdPtr + numFloats) <= dataLength)
        {
            // RD > END && (RD + POP <= LENGTH)
			memcpy(floats, &data[rdPtr], (numFloats * sizeof(float)));		
			rdPtr += numFloats;
        }
		else
		{
			// RD > END && (RD + POP > LENGTH)
			// Have to do the wraparound
			const NSUInteger floatsAtEnd = dataLength - rdPtr;
			memcpy(floats, &(data[rdPtr]), floatsAtEnd * sizeof(float));
			memcpy(&(floats[floatsAtEnd]), &(data[0]), (numFloats - floatsAtEnd) * sizeof(float));
            
            rdPtr = (numFloats - floatsAtEnd);
		}
        
        [self checkConsistency];
		
		return nsdata;
	}
}

@end

@implementation MTFIFO (Private)
-(void)checkConsistency
{
    if([self count] == 0)
    {
        assert(rdPtr == endPtr);
    }
    
    if([self floatsAvailable] == 0)
    {
        assert((endPtr == rdPtr - 1) || (rdPtr == 0 && endPtr == (dataLength - 1)));
    }
    
    assert(endPtr < dataLength);
    assert(rdPtr < dataLength);
    assert([self count] <= dataLength);
}
@end

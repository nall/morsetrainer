//
//  MTOperationQueue.m
//  MorseTrainer
//
//  Created by Jon Nall on 8/12/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import "MTOperationQueue.h"


@implementation MTOperationQueue
+(NSOperationQueue*)operationQueue
{
	static NSOperationQueue* queue = nil;
	
	if(queue == nil)
	{
		queue = [[NSOperationQueue alloc] init];
	}
	
	return queue;
}

@end

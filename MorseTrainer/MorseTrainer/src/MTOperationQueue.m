//
// MTOperationQueue.m
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

//
//  MTQRMSource.h
//  MorseTrainer
//
//  Created by Jon Nall on 8/1/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MTSoundSource.h"
#import "MTFileSource.h"

@interface MTQRMSource : MTFileSource
{
	NSUInteger qrmID;	
}
// Private
-(NSString*)generateParameters;

// Public
-(id)initWithID:(NSUInteger)theID;

@end

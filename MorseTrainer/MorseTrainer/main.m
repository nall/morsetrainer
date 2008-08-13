//
//  main.m
//  MorseTrainer
//
//  Created by Jon Nall on 7/28/08.
//  Copyright STUNTAZ!!! 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MTPlayer.h"

int main(int argc, char *argv[])
{
#if 0
	BufferGen* bg = [[BufferGen alloc] init];
	NSData* data = [bg generate:@"eT" formatAsAU:TRUE];
	FILE* f = fopen("/Users/nall/data.au", "wb");
	fwrite([data bytes], sizeof(char), [data length], f);
	fclose(f);
	return 0;
#endif
//	MTPlayer* sp = [[MTPlayer alloc] init];
//	[sp playCW:data withQRM:NO withNoise:NO];

	//NSLog(@"THREAD: %@", [NSThread currentThread]);
	
   return NSApplicationMain(argc,  (const char **) argv);
}

//
//  MTSLevels.m
//  MorseTrainer
//
//  Created by Jon Nall on 8/25/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import "MTSLevels.h"


@implementation MTSLevels
+(double)getSLevelValue:(NSString*)theSLevel
{
    static NSMutableDictionary* theDict = nil;
    
    if(theDict == nil)
    {
        theDict = [NSMutableDictionary dictionary];
        [theDict setObject:[NSNumber numberWithDouble:0.000] forKey:@"Off"];
        [theDict setObject:[NSNumber numberWithDouble:0.100] forKey:@"S1"];
        [theDict setObject:[NSNumber numberWithDouble:0.150] forKey:@"S2"];
        [theDict setObject:[NSNumber numberWithDouble:0.250] forKey:@"S3"];
        [theDict setObject:[NSNumber numberWithDouble:0.375] forKey:@"S4"];
        [theDict setObject:[NSNumber numberWithDouble:0.500] forKey:@"S5"];
        [theDict setObject:[NSNumber numberWithDouble:0.625] forKey:@"S6"];
        [theDict setObject:[NSNumber numberWithDouble:0.750] forKey:@"S7"];
        [theDict setObject:[NSNumber numberWithDouble:0.900] forKey:@"S8"];
        [theDict setObject:[NSNumber numberWithDouble:1.000] forKey:@"S9"];
    }

    if([[theDict allKeys] containsObject:theSLevel])
    {
        return [[theDict objectForKey:theSLevel] doubleValue];
    }
    else
    {
        NSLog(@"ERROR: An unexpected S-Level found: %@", theSLevel);
        NSRunAlertPanel(@"Internal Error", @"Error: An unexpected S Level Found: %@", @"Quit", nil, nil, theSLevel);
        exit(1);
    }
}

@end

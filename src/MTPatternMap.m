//
// MTPatternMap.m
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




#include "MTDefines.h"
#import "MTPatternMap.h"
#include <wctype.h>

@interface MTPatternMap (Private)
-(void)initLetters;
-(void)initNumbers;
-(void)initPunctuation;
-(void)initProsigns;
@end


@implementation MTPatternMap

-(id)init
{
	if([super init] != nil)
	{
		patternArray = [[NSMutableArray alloc] initWithCapacity:kMaxPatternTypes];
		[self initLetters];
		[self initNumbers];
		[self initPunctuation];
		[self initProsigns];
	}
	
	return self;
}

+(MTPatternMap*)instance
{
	static MTPatternMap* map = nil;
	
	if(map == nil)
	{
		map = [[MTPatternMap alloc] init];
	}
	return map;
}

+(NSDictionary*)dictForCharType:(NSUInteger)theType
{
    MTPatternMap* map = [MTPatternMap instance];
    return [map->patternArray objectAtIndex:theType];
}


+(NSString*)getPatternForCharacter:(NSString*)key errorString:(NSString**)theErrorString
{
	MTPatternMap* map = [MTPatternMap instance];
	
	id value = nil;
	if([key characterAtIndex:0] == '^')
	{
		// This is a prosign -- go ahead and handle it
		NSString* prosign = [key substringFromIndex:1];
		value = [[map->patternArray objectAtIndex:kPatternProsign] valueForKey:[prosign uppercaseString]];
		
	}
	else
	{
		for(NSUInteger i = 0; i < [map->patternArray count]; ++i)
		{
			value = [[map->patternArray objectAtIndex:i] valueForKey:[key uppercaseString]];
			if(value != nil)
			{
				break;
			}
		}		
	}
	
	if(value == nil)
	{
		NSLog(@"ERROR: Couldn't find pattern for requested key [%@]", key);
        if(theErrorString != nil)
        {
            *theErrorString = @"(ERR)";
        }
        return @"......";
	}
	else
	{
		return value;
	}
}

+(BOOL)isProsign:(NSString*)theString
{
	MTPatternMap* map = [MTPatternMap instance];

	id value = [[map->patternArray objectAtIndex:kPatternProsign]
				valueForKey:[theString uppercaseString]];
			
	return (value != nil);
}

+(NSUInteger)numChars
{
	MTPatternMap* map = [MTPatternMap instance];
	
	
	NSUInteger count = 0;
	
	for (NSDictionary* dict in map->patternArray)
	{
		count += [dict count];
	}
	
	return count;
}

+(NSArray*)characters
{
	MTPatternMap* map = [MTPatternMap instance];

    NSMutableArray* characters = [NSMutableArray array];
    
	for(NSUInteger i = 0; i < [map->patternArray count]; ++i)
    {
        NSDictionary* dict = [map->patternArray objectAtIndex:i];
        [characters addObjectsFromArray:[dict allKeys]];
    }
    
    return characters;
}


+(NSUInteger)parseProsign:(NSString*)theText atIndex:(NSUInteger)theIndex 
			 finalProsign:(NSMutableString*)theProsign
{
	NSUInteger lastCharacterConsumed = theIndex;
	
	[theProsign setString:@""];
	
	// Handle prosigns, which have the form: ^XX
	if([theText characterAtIndex:theIndex] != '^')
	{
		NSLog(@"WARNING: Asked to parse a non-prosign");
		return lastCharacterConsumed;
	}
	else		
	{
		// Strip off the '^', passing the rest of the prosign to charDits
		// Note we keep parsing until we run out of text to parse, or
		// we match any prosign. Note this means that ^SO can't be a
		// prosign if ^SOS is one.
		
		NSMutableString* currentProsign = [NSMutableString string];
		for(NSUInteger i = theIndex + 1; i < [theText length]; ++i)
		{
			NSString* curChar = [theText substringWithRange:NSMakeRange(i, 1)];
			if(iswspace([curChar characterAtIndex:0]))
			{
				NSLog(@"WARNING: Found whitespace without matching a prosign. [Text leading to this was: [%@]", currentProsign);
				break;
			}
			
			NSString* potentialProsign = [currentProsign stringByAppendingString:curChar];
			
			BOOL foundMatch = [MTPatternMap isProsign:potentialProsign];

			[currentProsign setString:potentialProsign];
			
			if(foundMatch)
			{
				lastCharacterConsumed = i;
				[theProsign setString:currentProsign];
				break;
			}
		}
	}
	
	return lastCharacterConsumed;
}
@end

@implementation MTPatternMap (Private)
-(void)initLetters
{
	NSMutableDictionary* patterns = [NSMutableDictionary dictionary];
    
	[patterns setValue:@".-" forKey:@"A"];
	[patterns setValue:@"-..." forKey:@"B"];
	[patterns setValue:@"-.-." forKey:@"C"];
	[patterns setValue:@"-.." forKey:@"D"];
	[patterns setValue:@"." forKey:@"E"];
	[patterns setValue:@"..-." forKey:@"F"];
	[patterns setValue:@"--." forKey:@"G"];
	[patterns setValue:@"...." forKey:@"H"];
	[patterns setValue:@".." forKey:@"I"];
	[patterns setValue:@".---" forKey:@"J"];
	[patterns setValue:@"-.-" forKey:@"K"];
	[patterns setValue:@".-.." forKey:@"L"];
	[patterns setValue:@"--" forKey:@"M"];
	[patterns setValue:@"-." forKey:@"N"];
	[patterns setValue:@"---" forKey:@"O"];
	[patterns setValue:@".--." forKey:@"P"];
	[patterns setValue:@"--.-" forKey:@"Q"];
	[patterns setValue:@".-." forKey:@"R"];
	[patterns setValue:@"..." forKey:@"S"];
	[patterns setValue:@"-" forKey:@"T"];
	[patterns setValue:@"..-" forKey:@"U"];
	[patterns setValue:@"...-" forKey:@"V"];
	[patterns setValue:@".--" forKey:@"W"];
	[patterns setValue:@"-..-" forKey:@"X"];
	[patterns setValue:@"-.--" forKey:@"Y"];
	[patterns setValue:@"--.." forKey:@"Z"];
	
	[patternArray insertObject:patterns atIndex:kPatternLetter];
}

-(void)initNumbers
{
	NSMutableDictionary* patterns = [NSMutableDictionary dictionary];
    
	[patterns setValue:@"-----" forKey:@"0"];
	[patterns setValue:@".----" forKey:@"1"];
	[patterns setValue:@"..---" forKey:@"2"];
	[patterns setValue:@"...--" forKey:@"3"];
	[patterns setValue:@"....-" forKey:@"4"];
	[patterns setValue:@"....." forKey:@"5"];
	[patterns setValue:@"-...." forKey:@"6"];
	[patterns setValue:@"--..." forKey:@"7"];
	[patterns setValue:@"---.." forKey:@"8"];
	[patterns setValue:@"----." forKey:@"9"];
	
	[patternArray insertObject:patterns atIndex:kPatternNumber];
}

-(void)initPunctuation
{
	NSMutableDictionary* patterns = [NSMutableDictionary dictionary];
    
	[patterns setValue:@".-.-.-" forKey:@"."];
	[patterns setValue:@"--..--" forKey:@","];
	[patterns setValue:@"..--.." forKey:@"?"];
	[patterns setValue:@".----." forKey:@"!"];
	[patterns setValue:@"-..-." forKey:@"/"];
	[patterns setValue:@"-.--." forKey:@"("];
	[patterns setValue:@"-.--.-" forKey:@")"];
	[patterns setValue:@".-..." forKey:@"&"];
	[patterns setValue:@"---..." forKey:@":"];
	[patterns setValue:@"-.-.-." forKey:@";"];
	[patterns setValue:@"-...-" forKey:@"="];
	[patterns setValue:@".-.-." forKey:@"+"];
	[patterns setValue:@"-....-" forKey:@"-"];
	[patterns setValue:@"..--.-" forKey:@"_"];
	[patterns setValue:@".-..-." forKey:@"\""];
	[patterns setValue:@"...-..-" forKey:@"$"];
	[patterns setValue:@".--.-." forKey:@"@"];
	
	[patternArray insertObject:patterns atIndex:kPatternPunctuation];
}

-(void)initProsigns
{
	NSMutableDictionary* patterns = [NSMutableDictionary dictionary];
	
	[patterns setValue:@".--.-." forKey:@"AC"];
	[patterns setValue:@".-.-." forKey:@"AR"];
	[patterns setValue:@".-..." forKey:@"AS"];
	[patterns setValue:@"-...-.-" forKey:@"BK"];
	[patterns setValue:@"-...-" forKey:@"BT"];
	[patterns setValue:@"-.-..-.." forKey:@"CL"];
	[patterns setValue:@"-..---" forKey:@"DO"];
	[patterns setValue:@"-.--." forKey:@"KN"];
	[patterns setValue:@"...-.-" forKey:@"SK"];
	[patterns setValue:@"...---..." forKey:@"SOS"];
	[patterns setValue:@"...-.-" forKey:@"VA"];		// synonym for SK
	
	[patternArray insertObject:patterns atIndex:kPatternProsign];
    
}

@end
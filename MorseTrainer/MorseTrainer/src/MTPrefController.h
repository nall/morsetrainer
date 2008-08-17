//
//  MTPrefController.h
//
//  Created by Jon Nall on 08/13/08.
//  Copyright (c) 2008 STUNTAZ!!! All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MTPrefController : NSWindowController
{
    // Need these outlets for validation routines
	IBOutlet NSTextField* actualWPMField;
	IBOutlet NSTextField* effectiveWPMField;
	IBOutlet NSTextField* minimumCharGroupField;
	IBOutlet NSTextField* maximumCharGroupField;
	
    IBOutlet NSMatrix* letterMatrix;
    IBOutlet NSMatrix* numberMatrix;
    IBOutlet NSMatrix* punctuationMatrix;
    IBOutlet NSMatrix* prosignMatrix;
    
    IBOutlet NSTextField* textFileLabel;
	
	NSURL* textFile;
	BOOL textFileEnabled;
    
    NSArray* noiseLevels;
    NSArray* signalStrengths;
	NSArray* qrmStationValues;
	
    NSArray* charsetLetters;
    NSArray* charsetNumbers;
    NSArray* charsetPunctuation;
    NSArray* charsetProsigns;
    
	NSArray* currentChars;
    
	
	NSUInteger minimumMinutes;
    // No maximum minutes
    
	NSUInteger minimumWPM;
	NSUInteger maximumWPM;
	
	NSUInteger minimumGroupChars;
	NSUInteger maximumGroupChars;
	
	NSArray* kochCharacters;
	NSUInteger minKochCharacters;
	NSUInteger maxKochCharacters;
    
	NSUInteger minTonePitch;
	NSUInteger maxTonePitch;    
}
-(IBAction)validateTiming:(id)value;
-(IBAction)validateCharGroups:(id)value;
-(IBAction)validateKochCharacters:(id)value;
-(IBAction)validateTonePitch:(id)value;
-(IBAction)validateMinutes:(id)value;

-(IBAction)clearAllLetters:(id)value;
-(IBAction)checkAllLetters:(id)value;
-(IBAction)copyFromKoch:(id)value;

-(IBAction)openTextFile:(id)value;

// KVC
-(BOOL)textFileEnabled;
-(void)setTextFileEnabled:(BOOL)value;



@end

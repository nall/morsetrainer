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

	// Label to update with current text file name
    IBOutlet NSTextField* textFileLabel;
    
    // The various source views
    IBOutlet NSView* allCharBox;
    IBOutlet NSMatrix* allCharLetterMatrix;
    IBOutlet NSMatrix* allCharNumberMatrix;
    IBOutlet NSMatrix* allCharPunctuationMatrix;
    IBOutlet NSMatrix* allCharProsignMatrix;
    IBOutlet NSView* letterBox;
    IBOutlet NSView* numberBox;
    IBOutlet NSView* punctuationBox;
    IBOutlet NSView* prosignBox;
    IBOutlet NSView* kochBox;
    NSView* currentView;
    NSArray* charsetViews;
	
    NSDictionary* characterViewMap;
    NSArray* characterViewMapLabels;
    
	NSURL* textFile;
	BOOL textFileEnabled;
    
    NSArray* noiseLevels;
    NSArray* signalStrengths;
	NSArray* qrmStationValues;
	
    NSArray* charsetLetters;
    NSArray* charsetNumbers;
    NSArray* charsetPunctuation;
    NSArray* charsetProsigns;
    NSArray* charsetKoch;
    
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
    
    NSMutableSet* masterCharSet;
}
// Public
-(IBAction)validateTiming:(id)value;
-(IBAction)validateCharGroups:(id)value;
-(IBAction)validateKochCharacters:(id)value;
-(IBAction)validateTonePitch:(id)value;
-(IBAction)validateMinutes:(id)value;

-(IBAction)clearCharsInView:(id)value;
-(IBAction)checkCharsInView:(id)value;

-(IBAction)openTextFile:(id)value;

-(IBAction)updateCharset:(id)value;
-(IBAction)changeCharView:(id)value;

// KVC
-(BOOL)textFileEnabled;
-(void)setTextFileEnabled:(BOOL)value;



@end

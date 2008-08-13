//
//  AppController.h
//  MorseTrainer
//
//  Created by Jon Nall on 7/28/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MTPlayer.h"


@interface MTController : NSWindowController
{
	IBOutlet NSTextField* actualWPMField;
	IBOutlet NSTextField* effectiveWPMField;
	IBOutlet NSTextField* minimumCharGroupField;
	IBOutlet NSTextField* maximumCharGroupField;
	
	IBOutlet NSTextField* textField;
	IBOutlet NSTextField* textFileLabel;
	
	IBOutlet NSTextField* statusBar;

	NSArray* noiseValues;
	NSArray* signalStrengthValues;
	NSArray* qrmStationValues;
	
	NSArray* kochCharacters;
	
	NSUInteger minimumWPM;
	NSUInteger maximumWPM;
	NSUInteger minimumGroupChars;
	NSUInteger maximumGroupChars;
	NSUInteger minimumMinutes;
	NSUInteger maximumMinutes;
	NSUInteger minKochCharacters;
	NSUInteger maxKochCharacters;
	
	NSArray* currentChars;
	
	
	NSURL* textFile;
	BOOL textFileEnabled;
	
	MTPlayer* player;
}
-(void)updateText:(NSString*)theText;

// KVC
-(BOOL)textFileEnabled;
-(void)setTextFileEnabled:(BOOL)value;

-(IBAction)validateTiming:(id)value;
-(IBAction)validateCharGroups:(id)value;
-(IBAction)validateKochCharacters:(id)value;

-(IBAction)updateCharacterSet:(id)value;

-(IBAction)openTextFile:(id)value;

// Main Window
-(IBAction)startSending:(id)sender;
-(IBAction)stopSending:(id)sender;

@end

//
//  MTPrefController.h
//
//  Created by Jon Nall on 08/13/08.
//  Copyright (c) 2008 STUNTAZ!!! All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MTPrefController : NSObject
{
    // Pref window and the various toolbar panes
    IBOutlet NSWindow* prefWindow;
    IBOutlet NSView* sourceView;
    IBOutlet NSView* sendingView;
    IBOutlet NSView* noiseQRMView;
    IBOutlet NSView* updateView;
    
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
    
    // An array of all character views used in sourceView
    NSArray* charsetViews;
    
    // A Mapping from kCharView* constants to their NSViews
    NSDictionary* characterViewMap;

    // The labels used in the sourceView character view drop down menu
    NSArray* characterViewMapLabels;
    
    // The current character view selected in sourceView
    NSView* currentCharacterView;
    
    // An array of all preference toolbar views
    NSArray* toolbarViews;
    
    // The source URL (can be nil)
	NSURL* textFile;
    
    // True if textFile is non-nil and exists
    // Follows KVC and used by IB to enable URL source option
	BOOL textFileEnabled;
    
    // Internal set of all selected random mode characters
    NSMutableSet* masterCharSet;
    
    ///////////////////////////////
    // Binding Arrays used in IB //
    ///////////////////////////////
    //
    // Binding array of values for source type radio buttons
    NSArray* sourceValues;
    
    // Binding array of values for noise level options
    NSArray* noiseLevels;
    
    // Binding array of values for signal strength options
    NSArray* signalStrengths;
    
    // Binding array of values for number of QRM stations drop-down
	NSArray* qrmStationValues;
    
    // Binding arrays for charsets in IB
    NSArray* charsetLetters;
    NSArray* charsetNumbers;
    NSArray* charsetPunctuation;
    NSArray* charsetProsigns;
    NSArray* charsetKoch;

    ////////////////////////
    // Absolute Min/Max vals
    // Used to set absolute min/max values for these fields
    // Use signed values to account for user putting in -1
	NSInteger minTonePitch;
	NSInteger maxTonePitch;
	NSInteger minimumWPM;
	NSInteger maximumWPM;
	NSInteger minimumGroupChars;
	NSInteger maximumGroupChars;
	NSInteger minimumMinutes;
    // No maximum minutes
	NSInteger minKochCharacters;
	NSInteger maxKochCharacters;
    ////////////////////////
	

	// The list of characters used in the Koch method, in the order they're
    // to be learned
	NSArray* kochCharacters;
    
    
}
-(void)showPreferences:(id)value;

// Public
-(IBAction)validateTiming:(id)value;
-(IBAction)validateCharGroups:(id)value;
-(IBAction)validateTonePitch:(id)value;
-(IBAction)validateMinutes:(id)value;

-(IBAction)clearCharsInView:(id)value;
-(IBAction)checkCharsInView:(id)value;

-(IBAction)openTextFile:(id)value;

-(IBAction)updateCharset:(id)value;

-(IBAction)checkForUpdates:(id)value;

// KVC
-(BOOL)textFileEnabled;
-(void)setTextFileEnabled:(BOOL)value;

-(IBAction)showToolbarPane:(id)value;
-(IBAction)changeCharView:(id)value;


@end

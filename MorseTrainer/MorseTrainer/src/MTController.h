//
//  AppController.h
//  MorseTrainer
//
//  Created by Jon Nall on 7/28/08.
//  Copyright 2008 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MTPlayer.h"
#import "MTPrefController.h"


@interface MTController : NSWindowController
{
	IBOutlet NSTextField* textField;
	IBOutlet NSTextField* statusBar;
	
	MTPlayer* player;
    MTPrefController* prefController;
}
-(void)updateText:(NSString*)theText;

// Main Window
-(IBAction)startSending:(id)sender;
-(IBAction)stopSending:(id)sender;
-(IBAction)speakBuffer:(id)sender;

-(IBAction)showPreferencePanel:(id)sender;

@end

//
// MTController.h
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
// Foobar is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with Foobar.  If not, see <http://www.gnu.org/licenses/>.



#import <Cocoa/Cocoa.h>
#import "MTPlayer.h"
#import "MTPrefController.h"


@interface MTController : NSWindowController
{
	IBOutlet NSTextField* textField;
	IBOutlet NSTextField* statusBar;
    
    IBOutlet NSButton* stopButton;
    IBOutlet NSButton* playPauseButton;
    IBOutlet NSButton* talkButton;
	
    NSString* aboutText;
	MTPlayer* player;
    MTPrefController* prefController;
}

// Main Window
-(IBAction)playOrPause:(id)sender;
-(IBAction)stopSending:(id)sender;
-(IBAction)speakBuffer:(id)sender;

-(IBAction)showPreferencePanel:(id)sender;

@end

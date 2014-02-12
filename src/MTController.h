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
// AD5RX Morse Trainer is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with AD5RX Morse Trainer.  If not, see <http://www.gnu.org/licenses/>.




#import <Cocoa/Cocoa.h>
#import "MTPlayer.h"
#import "MTPrefController.h"


@interface MTController : NSWindowController<NSSpeechSynthesizerDelegate>
{
    // The textfield where displayed characters show up
	IBOutlet NSTextField* textField;
    
    // Status bar used to display elapsed time
	IBOutlet NSTextField* statusBar;
    
    // Buttons to control playback
    IBOutlet NSButton* stopButton;
    IBOutlet NSButton* playPauseButton;
    IBOutlet NSButton* talkButton;
    
    // Play/Pause image references so we can swap them out based on state
    NSImage* playImage;
    NSImage* pauseImage;
    
    // Speech synth stuff
	NSSpeechSynthesizer* speechSynth;
    
    // Boolean set to TRUE when we start speaking. Pressing "Stop" sets it to
    // NO to stop speech
    BOOL keepTalking;

    // Text shown in the about dialog
    NSString* aboutText;
    
    // The sound player, including mixer, sources, etc
	MTPlayer* player;
    
    // The preference pane controller
    MTPrefController* prefController;
}

// Play or pause, based on state
-(IBAction)playOrPause:(id)sender;

// Stop playback or speech, based on state
-(IBAction)stopSending:(id)sender;

// Start speaking
-(IBAction)speakBuffer:(id)sender;

// Show the preferences
-(IBAction)showPreferencePanel:(id)sender;

@end

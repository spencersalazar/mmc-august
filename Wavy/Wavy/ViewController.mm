//
//  ViewController.m
//  Wavy
//
//  Created by Spencer Salazar on 8/14/12.
//  Copyright (c) 2012 Spencer Salazar. All rights reserved.
//

#import "ViewController.h"
#import "Audio.h"

@interface ViewController ()
{
    Audio * audio;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    audio = new Audio;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)play:(id)sender
{
    audio->play();
}

- (IBAction)recordStart:(id)sender
{
    audio->recordStart();
}

- (IBAction)recordStop:(id)sender
{
    audio->recordStop();
}

@end

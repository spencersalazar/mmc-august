//
//  ViewController.m
//  Complication
//
//  Created by Spencer Salazar on 8/13/12.
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
    
    audio = new Audio();
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

- (IBAction)changeFreq:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    audio->setFreq(220+slider.value*220);
}














@end

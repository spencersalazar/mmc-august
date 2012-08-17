//
//  ViewController.m
//  iTunesPicker
//
//  Created by Mark Cerqueira on 8/17/12.
//  Copyright (c) 2012 Mark Cerqueira. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()

@property (strong, nonatomic) MPMusicPlayerController *musicPlayerController;

// IB stuff
@property (strong, nonatomic) IBOutlet UIImageView *albumImageView;
@property (strong, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *songArtistLabel;
@property (strong, nonatomic) IBOutlet UILabel *albumArtistLabel;
@property (strong, nonatomic) IBOutlet UISlider *volumeSlider;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;

- (IBAction)showMediaPickerPressed:(id)sender;
- (IBAction)rewingPressed:(id)sender;
- (IBAction)playPressed:(id)sender;
- (IBAction)fastForwardPressed:(id)sender;
- (IBAction)sliderValueChanged:(id)sender;

@end

@implementation ViewController

@synthesize musicPlayerController;

@synthesize albumImageView;
@synthesize songTitleLabel;
@synthesize songArtistLabel;
@synthesize albumArtistLabel;
@synthesize volumeSlider;
@synthesize playPauseButton;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.musicPlayerController = [MPMusicPlayerController iPodMusicPlayer];
    
    // register for a bunch of music player notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nowPlayingItemChanged:)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                           selector: @selector (playbackStateChanged:)
                               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                           selector: @selector (volumeChanged:)
                               name: MPMusicPlayerControllerVolumeDidChangeNotification
                             object:nil];
    
    // set the initial volume
    [self.volumeSlider setValue:[self.musicPlayerController volume]];
    
    // [self.musicPlayerController volume] =
    // self.musicPlayerController.volume =
    // [self.musicPlayerController getVolume]
    //
    // BUT NOT self.musicPlayerController.volume = 0.5 =
    // [self.musicPlayerController setVolume:0.5]
    
    // have to explicitly turn on notification dispatching for the music player
    [self.musicPlayerController beginGeneratingPlaybackNotifications];
}

- (void)playbackStateChanged:(NSNotification *)notification
{
    MPMusicPlaybackState playbackState = [self.musicPlayerController playbackState];
    
    if (playbackState == MPMusicPlaybackStatePaused)
    {
        [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    else if (playbackState == MPMusicPlaybackStatePlaying)
    {
        [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else if (playbackState == MPMusicPlaybackStateStopped)
    {
        [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];

        [self.musicPlayerController stop];
    }
}

- (void)volumeChanged:(NSNotification *)notification
{
    [self.volumeSlider setValue:[self.musicPlayerController volume]];
}

- (void)nowPlayingItemChanged:(NSNotification *)notification
{
    MPMediaItem *currentItem = [self.musicPlayerController nowPlayingItem];
    
    // loading an image in case we don't have artwork in iTunes
    UIImage *artworkImage = [UIImage imageNamed:@"crazyforyou"];
    
    // trying to get the artwork from the actual iTunes media file
    MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
    
    // was there an image in the iTunes library?
    if (artwork)
    {
        // overwrite our hasselhoff default with the proper artwork
        artworkImage = [artwork imageWithSize:CGSizeMake(200, 200)];
    }
    
    // setting the outlet imageview in our xib to be our artworkImage
    [self.albumImageView setImage:artworkImage];
    
    NSString *titleString = [currentItem valueForProperty:MPMediaItemPropertyTitle];
    if (titleString) {
        self.songTitleLabel.text = [NSString stringWithFormat:@"Title: %@",titleString];
    } else {
        self.songTitleLabel.text = @"Title: Unknown title";
    }
    
    NSString *artistString = [currentItem valueForProperty:MPMediaItemPropertyArtist];
    if (artistString) {
        self.songArtistLabel.text = [NSString stringWithFormat:@"Artist: %@",artistString];
    } else {
        self.songArtistLabel.text = @"Artist: Unknown artist";
    }
    
    NSString *albumString = [currentItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    if (albumString) {
        self.albumArtistLabel.text = [NSString stringWithFormat:@"Album: %@",albumString];
    } else {
        self.albumArtistLabel.text = @"Album: Unknown album";
    }
}

- (void)viewDidUnload
{
    [self setAlbumImageView:nil];
    [self setSongTitleLabel:nil];
    [self setSongArtistLabel:nil];
    [self setAlbumArtistLabel:nil];
    [self setVolumeSlider:nil];
    [self setPlayPauseButton:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
}

#pragma mark - MPMediaPickerControllerDelegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    if(mediaItemCollection != nil)
    {
        [self.musicPlayerController setQueueWithItemCollection:mediaItemCollection];
        
        [self.musicPlayerController play];
        [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Actions

- (IBAction)showMediaPickerPressed:(id)sender
{
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = YES;
    mediaPicker.prompt = @"Select songs to play!";
    
    [self presentModalViewController:mediaPicker animated:YES];
}

- (IBAction)rewingPressed:(id)sender
{
    [self.musicPlayerController skipToPreviousItem];
}

- (IBAction)playPressed:(id)sender
{
    if ([self.musicPlayerController playbackState] == MPMusicPlaybackStatePlaying)
    {
        [self.musicPlayerController pause];
        [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    else
    {
        [self.musicPlayerController play];
        [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

- (IBAction)fastForwardPressed:(id)sender
{
    [self.musicPlayerController skipToNextItem];
}

- (IBAction)sliderValueChanged:(id)sender
{
    // UISlider *theSlider = (UISlider *)sender;
    
    self.musicPlayerController.volume = self.volumeSlider.value;
}

@end

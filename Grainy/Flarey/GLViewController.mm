//
//  GLViewController.m
//  MobileMusic2
//
//  Created by Spencer Salazar on 7/9/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "GLViewController.h"
#import "Geometry.h"
#import "Texture.h"
#import "Audio.h"
#include <map>


class HoffGfx
{
public:
    GLvertex2f position;
    GLcolor4f c;
    float scale;
    GLuint tex;
    float time;
    
    void update(float dt, float t)
    {
        time += dt;
        float r = 0.5+0.5*sinf(2*M_PI*0.5*time);
        float g = 0.5+0.5*sinf(2*M_PI*0.55*time);
        float b = 0.5+0.5*sinf(2*M_PI*0.45*time);
        
        //    r = g = b = 1;
        
        scale = 1 + 0.25*sinf(2*M_PI*(0.75)*time);
        //    angle += 20*dt;
        //    x = 0.5*sinf(2*M_PI*(1.5)*time);
        
        c = GLcolor4f(r, g, b, 1);
    }
    
    void render()
    {
        GLvertex3f square[6];
        
        float r = 0.5;
        square[0] = GLvertex3f(-r, -r, 0);
        square[1] = GLvertex3f( r, -r, 0);
        square[2] = GLvertex3f(-r,  r, 0);
        
        square[3] = GLvertex3f( r, -r, 0);
        square[4] = GLvertex3f( r,  r, 0);
        square[5] = GLvertex3f(-r,  r, 0);
        
        glVertexPointer(3, GL_FLOAT, 0, square);
        glEnableClientState(GL_VERTEX_ARRAY);
        
        glTranslatef(position.x, position.y, 0);
        glScalef(scale, scale, scale);
        
        glColor4f(c.r, c.g, c.b, 1);
        
        GLvertex2f squareTexcoord[6];
        
        squareTexcoord[0] = GLvertex2f(0, 0);
        squareTexcoord[1] = GLvertex2f(1, 0);
        squareTexcoord[2] = GLvertex2f(0, 1);
        
        squareTexcoord[3] = GLvertex2f(1, 0);
        squareTexcoord[4] = GLvertex2f(1, 1);
        squareTexcoord[5] = GLvertex2f(0, 1);
        
        glTexCoordPointer(2, GL_FLOAT, 0, squareTexcoord);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, tex);
        
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
};


//------------------------------------------------------------------------------
// name: uiview2gl
// desc: convert UIView coordinates to the OpenGL coordinate space
//------------------------------------------------------------------------------
GLvertex2f uiview2gl(CGPoint p, UIView * view)
{
    GLvertex2f v;
    float aspect = fabsf(view.bounds.size.width / view.bounds.size.height);
    v.x = ((p.x - view.bounds.origin.x)/view.bounds.size.width)*2-1;
    v.y = (((p.y - view.bounds.origin.y)/view.bounds.size.height)*2-1)/aspect;
    return v;
}



@interface GLViewController ()
{
    float time;
    GLuint tex;
    
    Audio * audio;
    
    HoffGfx * theHoff;
    
    BOOL alreadyPickedSong;
}

@property (strong, nonatomic) EAGLContext *context;

@end

@implementation GLViewController

@synthesize context;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.context];
    
    self.view.multipleTouchEnabled = YES;
    
    time = 0;
    
    glEnable(GL_TEXTURE_2D);
    //tex = loadTexture(@"hasselhoff.png");
    tex = loadTexture(@"flare.png");
    
    audio = new Audio;
    
    theHoff = new HoffGfx;
    
    theHoff->position = GLvertex2f(0,0);
    theHoff->c = GLcolor4f(1, 1, 1, 1);
    theHoff->scale = 1;
    theHoff->tex = tex;
    theHoff->time = 0;
    
    alreadyPickedSong = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!alreadyPickedSong)
    {
        MPMediaPickerController *pickerController =	[[MPMediaPickerController alloc]
                                                     initWithMediaTypes: MPMediaTypeMusic];
        pickerController.prompt = @"Choose song to export";
        pickerController.allowsPickingMultipleItems = NO;
        pickerController.delegate = self;
        [self presentModalViewController:pickerController animated:YES];
    }
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)update
{
    float dt = self.timeSinceLastUpdate;
    
    time += dt;
    
    theHoff->update(dt, time);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    /*** clear ***/
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    /*** setup projection matrix ***/
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-1, 1, 1.0/aspect, -1.0/aspect, -1, 100);
    
    glMatrixMode(GL_PROJECTION);
    glLoadMatrixf(projectionMatrix.m);
    
    /*** set model + view matrix ***/
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    // normal blending
    //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // additive blending
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);

    for(int j = 0; j < 3; j++)
    {
        glPushMatrix();
        theHoff->render();
        glPopMatrix();
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch * touch in touches)
    {
        CGPoint p = [touch locationInView:self.view];
        GLvertex2f touchPosition = uiview2gl(p, self.view);
        
        theHoff->position = touchPosition;
        audio->setGrainPosition(0.5+0.5*touchPosition.x);
        audio->setGrainRate(powf(2, touchPosition.y));
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch * touch in touches)
    {
        CGPoint p = [touch locationInView:self.view];
        GLvertex2f touchPosition = uiview2gl(p, self.view);
        
        theHoff->position = touchPosition;
        audio->setGrainPosition(0.5+0.5*touchPosition.x);
        audio->setGrainRate(powf(2, touchPosition.y));
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch * touch in touches)
    {
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}


#pragma mark iTunes Media Picker stuff

-(IBAction) convertTapped: (id) sender {
	// set up an AVAssetReader to read from the iPod Library
	NSURL *assetURL = [song valueForProperty:MPMediaItemPropertyAssetURL];
	AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
	NSError *assetError = nil;
	AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset
                                                               error:&assetError];
	if (assetError) {
		NSLog (@"error: %@", assetError);
		return;
	}
	
	AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput
                                              assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks
                                              audioSettings: nil];
	if (! [assetReader canAddOutput: assetReaderOutput]) {
		NSLog (@"can't add reader output... die!");
		return;
	}
	[assetReader addOutput: assetReaderOutput];
	
	NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
	NSString *exportPath = [documentsDirectoryPath stringByAppendingPathComponent:@"export.wav"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
		[[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
	}
	NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
	AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:exportURL
                                                           fileType:AVFileTypeWAVE
                                                              error:&assetError];
	if (assetError) {
		NSLog (@"error: %@", assetError);
		return;
	}
	AudioChannelLayout channelLayout;
	memset(&channelLayout, 0, sizeof(AudioChannelLayout));
	channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
	NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
									[NSNumber numberWithFloat:44100.0], AVSampleRateKey,
									[NSNumber numberWithInt:2], AVNumberOfChannelsKey,
									[NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
									[NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
									[NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
									[NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
									[NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
									nil];
	AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                               outputSettings:outputSettings];
	if ([assetWriter canAddInput:assetWriterInput]) {
		[assetWriter addInput:assetWriterInput];
	} else {
		NSLog (@"can't add asset writer input... die!");
		return;
	}
	
	assetWriterInput.expectsMediaDataInRealTime = NO;
    
	[assetWriter startWriting];
	[assetReader startReading];
    
	AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
	CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
	[assetWriter startSessionAtSourceTime: startTime];
	
	__block UInt64 convertedByteCount = 0;
	
	dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
	[assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
											usingBlock: ^
	 {
		 // NSLog (@"top of block");
		 while (assetWriterInput.readyForMoreMediaData) {
             CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
             if (nextBuffer) {
                 // append buffer
                 [assetWriterInput appendSampleBuffer: nextBuffer];
                 //				NSLog (@"appended a buffer (%d bytes)",
                 //					   CMSampleBufferGetTotalSampleSize (nextBuffer));
                 convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);
                 // oops, no
                 // sizeLabel.text = [NSString stringWithFormat: @"%ld bytes converted", convertedByteCount];
                 
                 NSNumber *convertedByteCountNumber = [NSNumber numberWithLong:convertedByteCount];
                 [self performSelectorOnMainThread:@selector(updateSizeLabel:)
                                        withObject:convertedByteCountNumber
                                     waitUntilDone:NO];
             } else {
                 // done!
                 [assetWriterInput markAsFinished];
                 [assetWriter finishWriting];
                 [assetReader cancelReading];
                 NSDictionary *outputFileAttributes = [[NSFileManager defaultManager]
                                                       attributesOfItemAtPath:exportPath
                                                       error:nil];
                 NSLog (@"done. file size is %ld",
					    [outputFileAttributes fileSize]);
                 NSNumber *doneFileSize = [NSNumber numberWithLong:[outputFileAttributes fileSize]];
                 [self performSelectorOnMainThread:@selector(updateCompletedSizeLabel:)
                                        withObject:doneFileSize
                                     waitUntilDone:NO];
                 break;
             }
         }
         
	 }];
	NSLog (@"bottom of convertTapped:");
}

-(void) updateSizeLabel: (NSNumber*) convertedByteCountNumber {
//	UInt64 convertedByteCount = [convertedByteCountNumber longValue];
//	sizeLabel.text = [NSString stringWithFormat: @"%ld bytes converted", convertedByteCount];
}

-(void) updateCompletedSizeLabel: (NSNumber*) convertedByteCountNumber {
//	UInt64 convertedByteCount = [convertedByteCountNumber longValue];
//	sizeLabel.text = [NSString stringWithFormat: @"done. file size is %ld", convertedByteCount];
    
    audio->start();
}


#pragma mark MPMediaPickerControllerDelegate
- (void)mediaPicker: (MPMediaPickerController *)mediaPicker
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    alreadyPickedSong = YES;
    
	[self dismissModalViewControllerAnimated:YES];
	if ([mediaItemCollection count] < 1) {
		return;
	}
	song = [[mediaItemCollection items] objectAtIndex:0];
    
    [self convertTapped:self];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
	[self dismissModalViewControllerAnimated:YES];
}




@end

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
    HoffAudio * hoffAudio;
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
    
    std::map<UITouch *, HoffGfx *> hoffs;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)update
{
    float dt = self.timeSinceLastUpdate;
    
    time += dt;
    
    for(std::map<UITouch *, HoffGfx *>::iterator i = hoffs.begin();
        i != hoffs.end(); i++)
    {
        HoffGfx * theHoff = i->second;
        theHoff->update(dt, time);
    }
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

    for(std::map<UITouch *, HoffGfx *>::iterator i = hoffs.begin();
        i != hoffs.end(); i++)
    {
        for(int j = 0; j < 3; j++)
        {
            glPushMatrix();
            HoffGfx * theHoff = i->second;
            theHoff->render();
            glPopMatrix();
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch * touch in touches)
    {
        CGPoint p = [touch locationInView:self.view];
        GLvertex2f touchPosition = uiview2gl(p, self.view);
        
        HoffGfx * theHoff = new HoffGfx;
        theHoff->position = touchPosition;
        theHoff->c = GLcolor4f(1, 1, 1, 1);
        theHoff->scale = 1;
        theHoff->tex = tex;
        theHoff->time = 0;
        
        HoffAudio * hoffAudio = new HoffAudio;
        hoffAudio->init();
        theHoff->hoffAudio = hoffAudio;
        hoffAudio->noteOn();
        hoffAudio->setFreq(440+220*touchPosition.x);
        hoffAudio->setCutoff(660+440*touchPosition.y);

        
        audio->addHoffAudio(hoffAudio);
        
        hoffs[touch] = theHoff;
        
        hoffAudio->noteOn();
        hoffAudio->setFreq(110+55*touchPosition.x);
        hoffAudio->setLFOSpeed(51+touchPosition.y*100);
//        audio->setCutoff(660+440*touchPosition.y);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch * touch in touches)
    {
        CGPoint p = [touch locationInView:self.view];
        GLvertex2f touchPosition = uiview2gl(p, self.view);
        
        HoffGfx * theHoff = hoffs[touch];
        theHoff->position = touchPosition;
        
        HoffAudio * hoffAudio = theHoff->hoffAudio;
        
//        hoffAudio->noteOn();
        hoffAudio->setFreq(110+55*touchPosition.x);
//        hoffAudio->setCutoff(660+440*touchPosition.y);
        hoffAudio->setLFOSpeed(51+touchPosition.y*100);

        
//        audio->setFreq(440+220*touchPosition.x);
//        audio->setCutoff(660+440*touchPosition.y);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch * touch in touches)
    {
//        audio->noteOff();
        HoffGfx * theHoff = hoffs[touch];
        
        HoffAudio * hoffAudio = theHoff->hoffAudio;
        hoffAudio->noteOff();
        
        audio->removeHoffAudio(hoffAudio);
        
        hoffs.erase(touch);
        delete theHoff;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}



@end

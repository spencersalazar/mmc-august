//
//  ViewController.m
//  OSC2
//
//  Created by Mark Cerqueira on 8/16/12.
//  Copyright (c) 2012 Mark Cerqueira. All rights reserved.
//

#import "ViewController.h"
#import "OSCManager.h"

@interface ViewController ()

@property (nonatomic, strong) OSCManager *myManager;
@property (nonatomic, strong) OSCOutPort *outPort;
@end

@implementation ViewController

@synthesize myManager;
@synthesize outPort;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.myManager = [[OSCManager alloc] init];
    [self.myManager setDelegate:self];
    
    self.outPort = [[OSCOutPort alloc] initWithAddress:@"224.0.0.1" andPort:7777];
    
    [self.myManager createNewInputForPort:7777];
}

- (void)viewDidAppear:(BOOL)animated
{
    OSCMessage *msg = [OSCMessage createWithAddress:@"/test/osc1"];
    [msg addFloat:660.0];
    [msg addFloat:0.5];
    
    [self.outPort sendThisMessage:msg];
    
    NSLog(@"message sent!");
}

#pragma mark - OSCManagerDelegate

- (void) receivedOSCMessage:(OSCMessage *)msg
{
    NSString *addressSpace = msg.address;
    
    NSLog(@"The address space message from is: %@", addressSpace);
}

@end

















//
//  ViewController.m
//  GE Hackaton
//
//  Created by Zack Matthews on 3/4/17.
//  Copyright © 2017 Callyo. All rights reserved.
//

#import "ViewController.h"
#import "LocationManager.h"
@import SocketIO;
@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[LocationManager sharedManager] startMonitoring];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
}
- (IBAction)onButtonClick:(id)sender {
    [self initSocket];
}


-(void)initSocket{
    NSURL* url = [[NSURL alloc] initWithString:@"https://forte9293.ngrok.io/"];
    SocketIOClient* socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @YES, @"forcePolling": @YES}];
    
//    [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
//        NSLog(@"socket connected");
//        
//        
//        //    [socket emit:@"query" with:@[@{@"amount": @(cur + 2.50)}]];
//        
//        
//    }];
     NSString *location = [LocationManager sharedManager].currentLocationAsText;
    NSLog(@"Location: %@", location);
    [socket on:@"location" callback:^(NSArray* data, SocketAckEmitter* ack) {
        [[socket emitWithAck:@"location" with:@[@(location.UTF8String)]] timingOutAfter:0 callback:^(NSArray* data) {
            NSLog(@"Location Response: %@", [data debugDescription]);
        }];
        
    }];
        //[socket  emit:@"pong" with:@[@{@"query": @"Suh dude"}]];
    
//    [socket on:@"currentAmount" callback:^(NSArray* data, SocketAckEmitter* ack) {
//        double cur = [[data objectAtIndex:0] floatValue];
//

// [socket emit:@"pong" with:@[@{@"dude": @(cur + 2.50)}]];
//        [ack with:@[@"Got your currentAmount, ", @"dude"]];
//    }];
//    
    [socket connect];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

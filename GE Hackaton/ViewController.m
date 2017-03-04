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
    
    NSString *location = [LocationManager sharedManager].currentLocationAsText;
    
    NSLog(@"location: %@", location);
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[LocationManager sharedManager] getLocation] completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(!placemarks) return;
        NSString *reverseLocation = @"";
        for(CLPlacemark *placeMark in placemarks){
            if(!placeMark || ![placeMark addressDictionary]) return;
            NSLog(@"Placemark: %@", [placeMark debugDescription]);
            NSLog(@"Address: %@", [[placeMark addressDictionary] debugDescription]);
            
            for(NSString *string in [[placeMark addressDictionary] objectForKey:@"FormattedAddressLines"]){
                NSLog(@"STRING: %@", string);
                reverseLocation = [[reverseLocation stringByAppendingString:string] stringByAppendingString: @" "];
            }
        }
    }];
    
    [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
        [[socket emitWithAck:@"location" with:@[@(location.UTF8String)]] timingOutAfter:5 callback:^(NSArray* data) {
            NSLog(@"Location Response: %@", [data debugDescription]);
        }];
        
        
        //    [socket emit:@"query" with:@[@{@"amount": @(cur + 2.50)}]];
        
        
    }];
    [socket connect];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

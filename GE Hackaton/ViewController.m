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
#define LOCATION_REQUEST_EVENT @"location_request"
#define LOCATION_CHANNEL @"location_request"
#define CONNECT_EVENT @"connect"
#define REVERSE_GEO_ADDRESS_DICT_KEY @"FormattedAddressLines"
#define SERVER_URL @"https://forte9293.ngrok.io/"

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
    NSURL* url = [[NSURL alloc] initWithString:SERVER_URL];
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
            
            for(NSString *string in [[placeMark addressDictionary] objectForKey:REVERSE_GEO_ADDRESS_DICT_KEY]){
                NSLog(@"STRING: %@", string);
                reverseLocation = [[reverseLocation stringByAppendingString:string] stringByAppendingString: @" "];
            }
        }
        
        [socket on:LOCATION_REQUEST_EVENT callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSLog(@"socket connected");
            [[socket emitWithAck:LOCATION_CHANNEL with:@[@(reverseLocation.UTF8String)]] timingOutAfter:5 callback:^(NSArray* data) {
                NSLog(@"Location Response: %@", [data debugDescription]);
            }];
        }];
    }];
    
    
    [socket connect];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

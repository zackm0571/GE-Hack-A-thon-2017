//
//  LocationManager.m
//  GE Hackaton
//
//  Created by Zack Matthews on 3/4/17.
//  Copyright © 2017 Callyo. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager()

@property(nonatomic,strong)CLLocationManager* locationManager;
@property(nonatomic)dispatch_semaphore_t phoneReportToTheApp;
@property(nonatomic)BOOL serviceStarted;
@end


@implementation LocationManager
- (id)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
    }
    self.serviceStarted = false;
    return self;
}

- (void)startMonitoring{
    self.serviceStarted = true;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; // setting the accuracy
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorized:
            NSLog(@"Location Services are now Authorised");
            [_locationManager startUpdatingLocation];
            
            break;
            
        case kCLAuthorizationStatusDenied: {
            NSLog(@"Location Services are now Denied");
        }
            break;
            
        case kCLAuthorizationStatusNotDetermined: {
            NSLog(@"Location Services are now Not Determined");
            [_locationManager startUpdatingLocation];
            
        } break;
            
        case kCLAuthorizationStatusRestricted:
            NSLog(@"Location Services are now Restricted");
            break;
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
}

- (CLLocation*)recentLocation{
    return self.locationManager.location;
}

- (NSString*)currentLocationAsText{
    NSMutableDictionary *locationJson = [[NSMutableDictionary alloc] init];
    
    NSNumber *lat = [[NSNumber alloc] initWithDouble:self.locationManager.location.coordinate.latitude];
    NSNumber *lng = [[NSNumber alloc] initWithDouble:self.locationManager.location.coordinate.longitude];
    [locationJson setObject:lat forKey:@"lat"];
    [locationJson setObject:lng forKey:@"lng"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:locationJson options:NSJSONWritingPrettyPrinted error:&error];
    
    if(error || !jsonData){
        if(error){
            NSLog(@"%@", [error debugDescription]);
        }
        return nil;
    }
    NSString *json =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"JSON %@", json);
    return json;
}

-(BOOL)isAuthorized:(BOOL)askUserIfUnknown  {
    int status = CLLocationManager.authorizationStatus;
    if (status == kCLAuthorizationStatusNotDetermined){
        if (!askUserIfUnknown) return NO;
        self.phoneReportToTheApp = dispatch_semaphore_create(0);
        [self startMonitoring];
    } else {
        if (!self.serviceStarted) {
            [self startMonitoring];
        }
    }
    if (status == kCLAuthorizationStatusNotDetermined) status = CLLocationManager.authorizationStatus;
    
    BOOL result = false;

    result = (status == kCLAuthorizationStatusAuthorizedAlways) || (status == kCLAuthorizationStatusAuthorizedWhenInUse);

    return result;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if (self.phoneReportToTheApp != nil) dispatch_semaphore_signal(self.phoneReportToTheApp);
    if ([[error domain] isEqualToString: kCLErrorDomain] && [error code] == kCLErrorDenied) {
        NSLog(@"locationManager didFailWithError: kCLErrorDenied");
    }
}

-(BOOL)locationPlausible {
    return self.locationManager != nil && self.locationManager.location != nil && self.locationManager.location.coordinate.latitude != 0 && self.locationManager.location.coordinate.longitude != 0;
}

#pragma mark -
#pragma mark Singleton instance

+(LocationManager *)sharedManager {
    static dispatch_once_t pred;
    static LocationManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[LocationManager alloc] init];
    });
    
    return shared;
}

@end

//
//  LocationManager.h
//  GE Hackaton
//
//  Created by Zack Matthews on 3/4/17.
//  Copyright © 2017 Callyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface LocationManager : NSObject<CLLocationManagerDelegate>

- (NSString*)currentLocationAsText;
- (void)startMonitoring;
-(BOOL)isAuthorized:(BOOL)askUserIfUnknown;
+(LocationManager *)sharedManager;
-(BOOL)locationPlausible;
- (CLLocation*)getLocation;
@end

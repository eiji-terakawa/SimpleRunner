//
//  ViewController.m
//  SimpleRunner
//
//  Created by 寺川 栄二 on 2014/10/11.
//  Copyright (c) 2014年 ET-Pro. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLGeocoder.h>

@interface ViewController () <CLLocationManagerDelegate>

@property CLLocationManager *locationManager;   // ロケーションマネージャ

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // ロケーションマネージャの初期化
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;

        // 位置情報の取得開始
        NSLog(@"位置情報取得開始");
        [self.locationManager startUpdatingLocation];

    }
}

// 位置情報が更新されるたびに呼ばれる
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSString *m;
    m = [NSString stringWithFormat:@"%.2f", newLocation.coordinate.latitude];
    NSLog(@"Latitude = %@",m);
    
    m = [NSString stringWithFormat:@"%.2f", newLocation.coordinate.longitude];
    NSLog(@"Longitude = %@",m);
    
    CLGeocoder *geocoder = [CLGeocoder new];
    CLLocation *location = [[CLLocation new] initWithLatitude:newLocation.coordinate.latitude
                                                    longitude:newLocation.coordinate.longitude];
    NSLog(@"location = %@",location);
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray* placemarks, NSError* error) {
                       // 経度、緯度から逆ジオコーディングを行った結果（場所）の数
                       NSLog(@"逆ジオ変換完了");
                       if(error){
                           NSLog(@"Error!");
                       }else{
                           NSLog(@"found : %zd", [placemarks count]);
                           
                           for (CLPlacemark *placemark in placemarks) {
                               // それぞれの結果（場所）の情報
                               NSLog(@"%@%@",placemark.locality,placemark.name);
                               
                           }
                       }
                   }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

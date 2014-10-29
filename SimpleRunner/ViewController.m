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
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Mapkit/mapkit.h>

@interface ViewController () <CLLocationManagerDelegate>

- (IBAction)start:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *kmLabel;
@property (weak, nonatomic) IBOutlet UILabel *mLabel;
@property (weak, nonatomic) IBOutlet UIButton *startLabel;

@property (weak, nonatomic) IBOutlet UILabel *locationBase;
@property (weak, nonatomic) IBOutlet UILabel *addressBase;
@property (weak, nonatomic) IBOutlet UILabel *timeBase;
@property (weak, nonatomic) IBOutlet UILabel *distanceBase;
@property (weak, nonatomic) IBOutlet UILabel *kmBase;
@property (weak, nonatomic) IBOutlet UILabel *mBase;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property CLLocationManager *locationManager;   // ロケーションマネージャ
@property double totalDistance;
@property double kmDistance;
@property double mDistance;

@property bool statusStart;
@property NSDate *startTime;
@property NSDate *kmTime;
@property NSDate *mTime;
@property NSTimer *tm;
@property CLLocation *previusLocaton;
@property CLLocation *nextLocaton;
@property NSString *totalDistanceString;

@property bool minutRead;
@property bool kmRead;
@property bool mRead;
@property bool allRead;

@end

@implementation ViewController

- (void)viewDidLoad {
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // ロケーションマネージャの初期化
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;

        // 位置情報の取得開始
        [self.locationManager startUpdatingLocation];

    }
    
    [NSUserDefaults resetStandardUserDefaults];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.minutRead = [defaults boolForKey:@"1minutInfoEnabled"];
    self.kmRead = [defaults boolForKey:@"1kmInfoEnabled"];
    self.mRead = [defaults boolForKey:@"100mInfoEnabled"];
    self.allRead = self.minutRead | self.kmRead | self.mRead;
    
    //mapの初期化
    self.mapView.frame = self.view.bounds;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;
    // 表示倍率の設定
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(_mapView.userLocation.coordinate, span);
    [_mapView setRegion:region animated:YES];
    
    //ラベルの角を丸くする
    self.locationBase.layer.cornerRadius=3.0f;
    self.locationBase.clipsToBounds = YES;

    self.addressBase.layer.cornerRadius = 3.0f;
    self.addressBase.clipsToBounds = YES;

    self.timeBase.layer.cornerRadius = 5.0f;
    self.timeBase.clipsToBounds = YES;

    self.distanceBase.layer.cornerRadius = 5.0f;
    self.distanceBase.clipsToBounds = YES;

    self.kmBase.layer.cornerRadius = 5.0f;
    self.kmBase.clipsToBounds = YES;

    self.mBase.layer.cornerRadius = 5.0f;
    self.mBase.clipsToBounds = YES;
    
    self.startLabel.layer.cornerRadius = 8.0f;
    self.startLabel.layer.masksToBounds = NO;
    self.startLabel.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.startLabel.layer.shadowOpacity = 0.7f;
    self.startLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.startLabel.layer.shadowRadius = 10.0f;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    // 地図の中心座標に現在地を設定
    _mapView.centerCoordinate = _mapView.userLocation.location.coordinate;
    
    // 表示倍率の設定
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(_mapView.userLocation.coordinate, span);
    [_mapView setRegion:region animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
    [super viewDidAppear:animated];
    if(self.statusStart == TRUE){
        if(![self.tm isValid]){
            [self.tm fire];
        }
    }
    
    [NSUserDefaults resetStandardUserDefaults];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.minutRead = [defaults boolForKey:@"1minutInfoEnabled"];
    self.kmRead = [defaults boolForKey:@"1kmInfoEnabled"];
    self.mRead = [defaults boolForKey:@"100mInfoEnabled"];
    self.allRead = self.minutRead | self.kmRead | self.mRead;

}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear");
    [super viewDidDisappear:animated];
    if([self.tm isValid]){
        [self.tm invalidate];
    }
}

- (void)timeUp:(NSTimer*)timer{
    NSLog(@"TimeUp");

    // AVSpeechSynthesizerを初期化する。
    AVSpeechSynthesizer* speechSynthesizer = [AVSpeechSynthesizer new];
    
    [NSUserDefaults resetStandardUserDefaults];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.minutRead = [defaults boolForKey:@"1minutInfoEnabled"];
    self.kmRead = [defaults boolForKey:@"1kmInfoEnabled"];
    self.mRead = [defaults boolForKey:@"100mInfoEnabled"];
    self.allRead = self.minutRead | self.kmRead | self.mRead;

    NSDate *now = [NSDate date];
    float tmp= [now timeIntervalSinceDate:self.startTime];
    // 時
    int hour = (int)(tmp / 3600);
    // 分
    int min = (int)tmp % 3600 / 60;
    // 秒
    int sec = (int)tmp % 60;
    
    if(hour != 0){
        self.timeLabel.text = [NSString stringWithFormat:@"%zd時間 %zd分 %zd秒",hour,min,sec];
    }else if(min != 0){
        self.timeLabel.text = [NSString stringWithFormat:@"%zd分 %zd秒",min,sec];
    }else{
        self.timeLabel.text = [NSString stringWithFormat:@"%zd秒",sec];
    }
    
    
    if(self.previusLocaton!=nil){
        if(self.nextLocaton!=nil){
            //　距離を取得
            CLLocationDistance distance = [self.previusLocaton distanceFromLocation:self.nextLocaton];
//            double distance = 25;

            self.totalDistance = self.totalDistance + distance;
            self.kmDistance = self.kmDistance + distance;
            self.mDistance = self.mDistance + distance;
            
            self.previusLocaton = self.nextLocaton;
            
            if(self.kmDistance > 1000){
                tmp= [now timeIntervalSinceDate:self.kmTime];
                self.kmDistance = 0;
                self.kmTime = now;
                // 時
                hour = (int)(tmp / 3600);
                // 分
                min = (int)tmp % 3600 / 60;
                // 秒
                sec = (int)tmp % 60;
                if(hour != 0){
                    self.kmLabel.text = [NSString stringWithFormat:@"%zd時間 %zd分 %zd秒",hour,min,sec];
                }else if(min != 0){
                    self.kmLabel.text = [NSString stringWithFormat:@"%zd分 %zd秒",min,sec];
                }else{
                    self.kmLabel.text = [NSString stringWithFormat:@"%zd秒",sec];
                }
                
                if(self.kmRead){
                    // AVSpeechUtteranceを読ませたい文字列で初期化する。
                    NSString* speakingText = [NSString stringWithFormat:@"1キロメートルの　タイムは　%@ です",self.kmLabel.text];
                    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speakingText];
                    utterance.rate = 0.3f;        //読み上げる速さ
                    
                    // AVSpeechSynthesizerにAVSpeechUtteranceを設定して読んでもらう
                    [speechSynthesizer speakUtterance:utterance];
                    utterance = nil;
                    speakingText = nil;
                }
            }
            if(self.mDistance > 100){
                tmp= [now timeIntervalSinceDate:self.mTime];
                self.mDistance = 0;
                self.mTime = now;
                // 時
                hour = (int)(tmp / 3600);
                // 分
                min = (int)tmp % 3600 / 60;
                // 秒
                sec = (int)tmp % 60;
                
                if(hour != 0){
                    self.mLabel.text = [NSString stringWithFormat:@"%zd時間 %zd分 %zd秒",hour,min,sec];
                }else if(min != 0){
                    self.mLabel.text = [NSString stringWithFormat:@"%zd分 %zd秒",min,sec];
                }else{
                    self.mLabel.text = [NSString stringWithFormat:@"%zd秒",sec];
                }

                if(self.mRead){
                    // AVSpeechUtteranceを読ませたい文字列で初期化する。
                    NSString* speakingText = [NSString stringWithFormat:@"100メートルの　タイムは　%@ です",self.mLabel.text];
                    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speakingText];
                    utterance.rate = 0.3f;        //読み上げる速さ
                    
                    // AVSpeechSynthesizerにAVSpeechUtteranceを設定して読んでもらう
                    [speechSynthesizer speakUtterance:utterance];
                    utterance = nil;
                    speakingText = nil;

                }
            }

            // 距離をコンソールに表示
            NSLog(@"total distance:%f", self.totalDistance);
            if(self.totalDistance < 1000){
                self.distanceLabel.text=[NSString stringWithFormat:@"%zdm",(int)self.totalDistance];
                self.totalDistanceString = [NSString stringWithFormat:@"%zd　メートルの",(int)self.totalDistance];
            }else{
                self.distanceLabel.text=[NSString stringWithFormat:@"%.2fkm",self.totalDistance/1000];
                self.totalDistanceString = [NSString stringWithFormat:@"%.2f　キロメートルの",self.totalDistance/1000];
            }
            
            if(sec == 0){
                if(self.minutRead){
                    // AVSpeechUtteranceを読ませたい文字列で初期化する。
                    NSString* speakingText = [NSString stringWithFormat:@"きょり  %@  タイムは　%@ です",self.totalDistanceString,self.timeLabel.text];
                    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speakingText];
                    utterance.rate = 0.3f;        //読み上げる速さ
                    
                    // AVSpeechSynthesizerにAVSpeechUtteranceを設定して読んでもらう
                    [speechSynthesizer speakUtterance:utterance];
                    utterance = nil;
                    speakingText = nil;
                }
            }
        }
        now = nil;
        speechSynthesizer = nil;
    }
}

- (IBAction)start:(UIButton *)sender {
    NSLog(@"toutch");
    UIColor *buttonColor;
    
    // AVSpeechSynthesizerを初期化する。
    AVSpeechSynthesizer* speechSynthesizer = [AVSpeechSynthesizer new];

    if(self.statusStart == FALSE){
        NSLog(@"STOP");
        
        //ボタンを停止にする
        [self.startLabel setTitle:@"STOP" forState:UIControlStateNormal];
        buttonColor = [UIColor redColor];
        self.startLabel.backgroundColor = buttonColor;

        self.statusStart = TRUE;

        self.totalDistance = 0;
        self.kmDistance = 0;
        self.mDistance = 0;
        
        self.startTime = [NSDate date];
        self.kmTime = [NSDate date];
        self.mTime = [NSDate date];

        // タイマーの生成
        self.tm = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeUp:) userInfo:nil repeats:YES
                   ];

        if(![self.tm isValid]){
            [self.tm fire];
        }
    
        if(self.allRead){
            // AVSpeechUtteranceを読ませたい文字列で初期化する。
            NSString* speakingText = @"計測を開始します。";
            AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speakingText];
            utterance.rate = 0.3f;        //読み上げる速さ
            
            // AVSpeechSynthesizerにAVSpeechUtteranceを設定して読んでもらう
            [speechSynthesizer speakUtterance:utterance];
            utterance = nil;
            speakingText = nil;
        }
    }else{
        NSLog(@"START");
        //ボタンを開始にする
        [self.startLabel setTitle:@"START" forState:UIControlStateNormal];
        buttonColor = [UIColor blueColor];
        self.startLabel.backgroundColor = buttonColor;

        self.statusStart = FALSE;
        if([self.tm isValid]){
            [self.tm invalidate];
        }

        if(self.allRead){
            // AVSpeechUtteranceを読ませたい文字列で初期化する。
            NSString* speakingText = @"計測を終了しました。";
            AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speakingText];
            utterance.rate = 0.3f;        //読み上げる速さ
            
            // AVSpeechSynthesizerにAVSpeechUtteranceを設定して読んでもらう
            [speechSynthesizer speakUtterance:utterance];
            utterance = nil;
            speakingText = nil;
        }
    }
    speechSynthesizer = nil;
}

// 位置情報が更新されるたびに呼ばれる
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // 地図の中心座標に現在地を設定
    self.mapView.centerCoordinate = newLocation.coordinate;
    
    // 位置情報を表示
    self.locationLabel.text=[NSString stringWithFormat:@"緯度:%.2f  経度:%.2f",newLocation.coordinate.latitude,newLocation.coordinate.longitude];
    
    // 距離算出用に今回の位置情報を記憶
    if(self.previusLocaton == nil){
        self.previusLocaton = newLocation;
    }
    self.nextLocaton = newLocation;
    
    // 住所を取得
    CLGeocoder *geocoder = [CLGeocoder new];
    CLLocation *location = [[CLLocation new] initWithLatitude:newLocation.coordinate.latitude
                                                    longitude:newLocation.coordinate.longitude];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray* placemarks, NSError* error) {
                       // 経度、緯度から逆ジオコーディングを行った結果（場所）の数
                       if(error){
                       }else{
                           
                           for (CLPlacemark *placemark in placemarks) {
                               // それぞれの結果（場所）の情報
                               self.addressLabel.text=[NSString stringWithFormat:@"%@%@",placemark.locality,placemark.name];
                           }
                       }
                       placemarks = nil;
                       error = nil;
                   }];
    geocoder = nil;
    location = nil;
    newLocation = nil;
    oldLocation = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

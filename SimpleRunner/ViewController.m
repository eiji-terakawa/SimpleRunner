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

@interface ViewController () <CLLocationManagerDelegate>

- (IBAction)start:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *kmLabel;
@property (weak, nonatomic) IBOutlet UILabel *mLabel;
@property (weak, nonatomic) IBOutlet UIButton *startLabel;

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

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
    [super viewDidAppear:animated];
    if(self.statusStart == TRUE){
        if(![self.tm isValid]){
            [self.tm fire];
        }
    }
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
//            CLLocationDistance distance = [self.previusLocaton distanceFromLocation:self.nextLocaton];
            double distance = 25;

            self.totalDistance = self.totalDistance + distance;
            self.kmDistance = self.kmDistance + distance;
            self.mDistance = self.mDistance + distance;
            
            self.previusLocaton = self.nextLocaton;
            
            if(self.kmDistance > 1000){
                float tmp= [now timeIntervalSinceDate:self.kmTime];
                self.kmDistance = 0;
                self.kmTime = now;
                // 時
                int hour = (int)(tmp / 3600);
                // 分
                int min = (int)tmp % 3600 / 60;
                // 秒
                int sec = (int)tmp % 60;
                if(hour != 0){
                    self.kmLabel.text = [NSString stringWithFormat:@"%zd時間 %zd分 %zd秒",hour,min,sec];
                }else if(min != 0){
                    self.kmLabel.text = [NSString stringWithFormat:@"%zd分 %zd秒",min,sec];
                }else{
                    self.kmLabel.text = [NSString stringWithFormat:@"%zd秒",sec];
                }
                
                // AVSpeechUtteranceを読ませたい文字列で初期化する。
                NSString* speakingText = [NSString stringWithFormat:@"1キロメートルの　タイムは　%@ です",self.kmLabel.text];
                AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speakingText];
                utterance.rate = 0.3f;        //読み上げる速さ
                
                // AVSpeechSynthesizerにAVSpeechUtteranceを設定して読んでもらう
                [speechSynthesizer speakUtterance:utterance];
                
                
                

            }
            if(self.mDistance > 100){
                float tmp= [now timeIntervalSinceDate:self.mTime];
                self.mDistance = 0;
                self.mTime = now;
                // 時
                int hour = (int)(tmp / 3600);
                // 分
                int min = (int)tmp % 3600 / 60;
                // 秒
                int sec = (int)tmp % 60;
                
                if(hour != 0){
                    self.mLabel.text = [NSString stringWithFormat:@"%zd時間 %zd分 %zd秒",hour,min,sec];
                }else if(min != 0){
                    self.mLabel.text = [NSString stringWithFormat:@"%zd分 %zd秒",min,sec];
                }else{
                    self.mLabel.text = [NSString stringWithFormat:@"%zd秒",sec];
                }

                // AVSpeechUtteranceを読ませたい文字列で初期化する。
                NSString* speakingText = [NSString stringWithFormat:@"100メートルの　タイムは　%@ です",self.mLabel.text];
                AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speakingText];
                utterance.rate = 0.3f;        //読み上げる速さ
                
                // AVSpeechSynthesizerにAVSpeechUtteranceを設定して読んでもらう
                [speechSynthesizer speakUtterance:utterance];
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
                // AVSpeechUtteranceを読ませたい文字列で初期化する。
                NSString* speakingText = [NSString stringWithFormat:@"きょり  %@  タイムは　%@ です",self.totalDistanceString,self.timeLabel.text];
                AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speakingText];
                utterance.rate = 0.3f;        //読み上げる速さ
                
                // AVSpeechSynthesizerにAVSpeechUtteranceを設定して読んでもらう
                [speechSynthesizer speakUtterance:utterance];
            }
            
        }
    }
}

- (IBAction)start:(UIButton *)sender {
    NSLog(@"toutch");
    
    // AVSpeechSynthesizerを初期化する。
    AVSpeechSynthesizer* speechSynthesizer = [AVSpeechSynthesizer new];

    if(self.statusStart == FALSE){
        NSLog(@"END");
        [self.startLabel setTitle:@"END" forState:UIControlStateNormal];
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
    
        // AVSpeechUtteranceを読ませたい文字列で初期化する。
        NSString* speakingText = @"計測を開始します。";
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speakingText];
        utterance.rate = 0.3f;        //読み上げる速さ
        
        // AVSpeechSynthesizerにAVSpeechUtteranceを設定して読んでもらう
        [speechSynthesizer speakUtterance:utterance];
    
    
    }else{
        NSLog(@"START");
        [self.startLabel setTitle:@"START" forState:UIControlStateNormal];
        self.statusStart = FALSE;
        if([self.tm isValid]){
            [self.tm invalidate];
        }

        // AVSpeechUtteranceを読ませたい文字列で初期化する。
        NSString* speakingText = @"計測を終了しました。";
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speakingText];
        utterance.rate = 0.3f;        //読み上げる速さ
        
        // AVSpeechSynthesizerにAVSpeechUtteranceを設定して読んでもらう
        [speechSynthesizer speakUtterance:utterance];

    
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

    self.locationLabel.text=[NSString stringWithFormat:@"緯度:%.2f  経度:%.2f",newLocation.coordinate.latitude,newLocation.coordinate.longitude];
    
    // 位置情報を設定
    if(self.previusLocaton == nil){
        NSLog(@"初回設定");
        self.previusLocaton = newLocation;
    }
    NSLog(@"現在設定");
    self.nextLocaton = newLocation;
    
    // 住所を取得
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
                               self.addressLabel.text=[NSString stringWithFormat:@"%@%@",placemark.locality,placemark.name];

                               
                           }
                       }
                   }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

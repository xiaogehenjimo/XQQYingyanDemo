//
//  mainViewController.m
//  XQQYingyanDemo
//
//  Created by XQQ on 16/8/23.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import "mainViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件
#import <BaiduTraceSDK/BaiduTraceSDK-Swift.h>


#define AK @"6hMQgTmH5sydx3UabpmqT7U4BtQM1hj0"
#define MCODE @"UIP.XQQYingyanDemo"
#define serviceID  123934

#define iphoneWidth  [UIScreen mainScreen].bounds.size.width
#define iphoneHeight [UIScreen mainScreen].bounds.size.height
@interface mainViewController ()<BMKMapViewDelegate,ApplicationServiceDelegate, ApplicationEntityDelegate, ApplicationTrackDelegate, ApplicationFenceDelegate, UIAlertViewDelegate>
{
    BMKPointAnnotation* pointAnnotation;
}
/**
 *  地图
 */
@property(nonatomic, strong) BMKMapView * mapView;
/**
 *  开始追踪
 */
@property(nonatomic, strong)  UIButton  *  startBtn;
/**
 *  结束追踪
 */
@property(nonatomic, strong)  UIButton  *  endBtn;
/**
 *
 */
@property(nonatomic, strong)  BMKCircle *circleFence;
/**
 *
 */
@property(nonatomic, strong)  UILabel * entityNameLabel;
/**
 *  定时器
 */
@property(nonatomic, strong)  NSTimer  *  timer;

@end

@implementation mainViewController


static NSString * entityName;
static BTRACE * traceInstance = NULL;
double latitudeOfEntity;
double longitudeOfEntity;

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"实时追踪";
    [self.view addSubview:self.mapView];
    
    //创建围栏
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[BTRACEAction shared] createCircularFence:self serviceId:serviceID fenceName:@"test_fence" fenceDesc:@"my" creator:@"test114" monitoredPersons:@"test123" observers:@"test521" validTimes:@"0000,2359" validCycle:4 validDate:nil validDays:nil coordType:3 center:@"116.43265672414,39.931261886825" radius:4000 alarmCondition:3 precision:2];
        
    // [[BTRACEAction shared] createCircularFence:self serviceId:serviceId fenceName:@"test_fence" fenceDesc:nil creator:entityName monitoredPersons:entityName observers:entityName validTimes:@"0000,2359" validCycle:4 validDate:nil validDays:nil coordType:3 center:centerOfFence radius:radiusOfFence alarmCondition:3];
    });
    
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(timerDo) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];
    self.navigationItem.leftBarButtonItem = ({
        UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:self.startBtn];
        leftItem;
    });
    self.navigationItem.rightBarButtonItem = ({
        UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.endBtn];
        rightItem;
    });
    pointAnnotation = nil;

    [self doWork];
}
- (void)doWork{
    //把设备的uuid作为entityName
    //entityName = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    entityName = @"test521";
    traceInstance = [[BTRACE alloc] initWithAk:AK mcode:MCODE serviceId:serviceID entityName: entityName operationMode: 2];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _mapView.mapType = BMKMapTypeStandard;
    //请求实时位置
    [[BTRACEAction shared] startTrace:self trace:traceInstance];
    [self queryEntityList];
}

- (void)timerDo{
    [[BTRACEAction shared] startTrace:self trace:traceInstance];
    [self queryEntityList];
}


- (void)queryEntityList{
    [[BTRACEAction shared] queryEntityList:self serviceId:serviceID entityNames:entityName columnKey:nil activeTime:0 returnType:0 pageSize:0 pageIndex:0];
}

#pragma mark - Entity相关回调方法

- (void)onQueryEntityList:(NSData *)data{
    NSString * entityListResult = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"实时位置查询结果:%@",entityListResult);
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:[entityListResult dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    NSNumber  * states = dict[@"status"];
    if ([states longValue] == 0) {
        NSArray *entities = [dict objectForKey:@"entities"];
        NSDictionary *entity = [entities objectAtIndex:0];
        NSDictionary *realtimePoint = [entity objectForKey:@"realtime_point"];
        NSArray *location = [realtimePoint objectForKey:@"location"];
        longitudeOfEntity = [[location objectAtIndex:0] doubleValue];
        latitudeOfEntity = [[location objectAtIndex:1] doubleValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mapView removeOverlays:_mapView.overlays];
            [_mapView removeAnnotations:_mapView.annotations];
        });
        [self addPointAnnotation];
    }
}

- (void)addPointAnnotation{
    CLLocationCoordinate2D coord;
    coord.latitude = latitudeOfEntity;
    coord.longitude = longitudeOfEntity;
    if (pointAnnotation == nil) {
        pointAnnotation = [[BMKPointAnnotation alloc]init];
    }
    pointAnnotation.coordinate = coord;
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0,0};
    pt = (CLLocationCoordinate2D){latitudeOfEntity,longitudeOfEntity};
    pointAnnotation.title = @"最新位置";
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView setCenterCoordinate:coord animated:YES];
        [self.mapView addAnnotation:pointAnnotation];
    });
}

- (BMKAnnotationView*)mapView:(BMKMapView *)mapView
            viewForAnnotation:(id<BMKAnnotation>)annotation{
    if (annotation == pointAnnotation) {
        NSString * annotationID = @"renameMark";
        BMKPinAnnotationView * annotationView = (BMKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationID];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationID];
            //设置颜色
            annotationView.pinColor = BMKPinAnnotationColorPurple;
            //从天上掉下的效果
            annotationView.animatesDrop = YES;
            //设置可拖拽
            annotationView.draggable = YES;
        }
        return annotationView;
    }
    return nil;
}


- (void)applicationWillResignActive {
    NSLog(@"程序即将进入后台执行");
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    pointAnnotation = nil;
    _circleFence = nil;
    
}
- (void)applicationDidBecomeActive{
    
}


#pragma mark - activity

- (void)startBtnDidPress{
    
     [_timer setFireDate:[NSDate distantPast]];
}

- (void)endBtnDidPress{
     [_timer setFireDate:[NSDate distantFuture]];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil]; //监听是否重新进入程序.
}

#pragma mark - setter&getter
- (UIButton *)endBtn{
    if (!_endBtn) {
        _endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _endBtn.frame = CGRectMake(0, 0, 80, 40);
        [_endBtn setTitle:@"结束追踪" forState:UIControlStateNormal];
        [_endBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_endBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_endBtn addTarget:self action:@selector(endBtnDidPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _endBtn;
}
- (UIButton *)startBtn{
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _startBtn.frame = CGRectMake(0, 0, 80, 40);
        [_startBtn setTitle:@"开始追踪" forState:UIControlStateNormal];
        [_startBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_startBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_startBtn addTarget:self action:@selector(startBtnDidPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

- (BMKMapView *)mapView{
    if (!_mapView) {
        _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 64, iphoneWidth, iphoneHeight-64)];
        _mapView.zoomLevel = 17.0;
        _mapView.zoomEnabled = YES;
        _mapView.mapType = BMKMapTypeStandard;
    }
    return _mapView;
}
- (void)dealloc{
    _mapView.delegate = nil;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end

//
//  secondViewController.m
//  XQQYingyanDemo
//
//  Created by XQQ on 16/8/23.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import "secondViewController.h"
#import <BaiduTraceSDK/BaiduTraceSDK-Swift.h>
#import "CuiPickerView.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件

#define serviceID  123934
#define iphoneWidth  [UIScreen mainScreen].bounds.size.width
#define iphoneHeight [UIScreen mainScreen].bounds.size.height
@interface secondViewController ()<ApplicationTrackDelegate,CuiPickViewDelegate,BMKMapViewDelegate>
/**
 *  查询历史轨迹按钮
 */
@property (nonatomic, strong) UIButton * queryBtn;
/**
 *  显示时间
 */
@property(nonatomic, strong)  UILabel  *  timeLabel;
/**
 *  选择时间
 */
@property(nonatomic, strong)  UIButton  *  selTimeBtn;
/**
 *  isLoading
 */
@property(nonatomic, assign)  BOOL   isLoading;
/**
 *  开始时间
 */
@property(nonatomic, strong)  CuiPickerView * startPickerView;
/**
 * 结束时间
 */
@property(nonatomic, strong)  CuiPickerView  *  endPickerView;

@property(nonatomic, strong)  UITextField  *  textfield;
/**
 *  结束时间
 */
@property(nonatomic, strong)  UILabel  *  endTimeLabel;
/**
 *  选择结束时间
 */
@property(nonatomic, strong)  UIButton  *  selEndTimeBtn;
/**
 *  开始还是结束
 */
@property(nonatomic, assign)  BOOL   isStart;
/**
 *  开始时间戳
 */
@property(nonatomic, assign)  long long   startTime;
/**
 *  结束时间戳
 */
@property(nonatomic, assign)  long long   endTime;
/**
 *  地图
 */
@property(nonatomic, strong)  BMKMapView  *  mapView;
/**
 *  线
 */
@property(nonatomic, strong)  BMKPolyline * polyline;


@end

@implementation secondViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    _isLoading = NO;
    self.title = @"历史轨迹";
    _textfield = [[UITextField alloc]init];
    [self.view addSubview:self.selTimeBtn];
    [self.view addSubview:self.queryBtn];
    [self.view addSubview:self.timeLabel];
    [self.view addSubview:self.selEndTimeBtn];
    [self.view addSubview:self.endTimeLabel];
    

    //创建百度地图
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.endTimeLabel.frame) + 10, iphoneWidth, iphoneHeight - CGRectGetMaxY(self.endTimeLabel.frame) - 50)];
    _mapView.mapType = BMKMapTypeStandard;
    _mapView.delegate  =self;
    _mapView.zoomLevel = 15;
    _mapView.zoomEnabled = YES;
    _mapView.zoomEnabledWithTap = YES;
    [self.view addSubview:_mapView];
    _startPickerView = [[CuiPickerView alloc]init];
    _startPickerView.frame = CGRectMake(0, iphoneHeight, iphoneWidth, 200);
    _startPickerView.myTextField = _textfield;
    _startPickerView.delegate = self;
    _startPickerView.curDate = [NSDate date];
    [self.view addSubview:self.startPickerView];
    
    _endPickerView = [[CuiPickerView alloc]init];
    _endPickerView.frame = CGRectMake(0, iphoneHeight, iphoneWidth, 200);
    _endPickerView.myTextField = _textfield;
    _endPickerView.delegate = self;
    _endPickerView.curDate = [NSDate date];
    [self.view addSubview:self.endPickerView];
    
}
-(void)pickerviewbuttonclick:(UIButton *)sender{
    self.tabBarController.tabBar.hidden = NO;
}
-(void)hiddenPickerView{
    self.tabBarController.tabBar.hidden = NO;
}



#pragma mark - ApplicationTrackDelegate
/**
 *  历史轨迹查询回调方法
 *  @param data JSON格式的返回内容
 */
- (void)onGetHistoryTrack:(NSData * _Nonnull)data{
    
    
  NSDictionary * dict= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSNumber * states = dict[@"status"];
    NSString * message = dict[@"message"];
    
    NSLog(@"%@",message);
    
    if ([states longValue] == 0) {
        NSArray * pois = dict[@"points"];
        //取出经纬度(0,0)的点,将剩余的坐标存储在poinsWithoutZero中
        NSMutableArray * poinsWithoutZero = [[NSMutableArray alloc]init];
        for (int i = 0; i < pois.count; i ++) {
            NSArray * point = pois[i];
            NSNumber * longitude = point[0];
            NSNumber * latitude = point[1];
            extern double const EPSILON;
            if (fabs(longitude.doubleValue - 0) < EPSILON && fabs(latitude.doubleValue - 0) < EPSILON) {
                continue;
            }
            [poinsWithoutZero addObject:point];
        }
        
        CLLocationCoordinate2D *locations = malloc([poinsWithoutZero count] * sizeof(CLLocationCoordinate2D));
        CLLocationDegrees minLat = 90.0;
        CLLocationDegrees maxLat = -90.0;
        CLLocationDegrees minLon = 180.0;
        CLLocationDegrees maxLon = -180.0;
        for (int i = 0; i < [poinsWithoutZero count]; i++) {
            NSArray *point = [poinsWithoutZero objectAtIndex:i];
            NSNumber *longitude = [point objectAtIndex:0];
            NSNumber *latitude = [point objectAtIndex:1];
            minLat = MIN(minLat, latitude.doubleValue);
            maxLat = MAX(maxLat, latitude.doubleValue);
            minLon = MIN(minLon, longitude.doubleValue);
            maxLon = MAX(maxLon, longitude.doubleValue);
            
            locations[i] = CLLocationCoordinate2DMake(latitude.doubleValue,longitude.doubleValue);
        }

        if (_polyline) {
            [_mapView removeOverlay:_polyline];
        }
        _polyline  = [BMKPolyline polylineWithCoordinates:locations count:poinsWithoutZero.count];
        CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake((minLat + maxLat) * 0.5f, (minLon + maxLon) * 0.5f);
        BMKCoordinateSpan viewSapn;
        viewSapn.latitudeDelta = maxLat - minLat;
        viewSapn.longitudeDelta = maxLon - minLon;
        BMKCoordinateRegion viewRegion;
        viewRegion.center = centerCoord;
        viewRegion.span = viewSapn;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mapView setRegion:viewRegion animated:YES];
            [_mapView addOverlay:_polyline];
        });
        
        free(locations);
    }
    _isLoading = NO;
}

-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
        polylineView.lineWidth = 5.0;
        return polylineView;
    }
    return nil;
}

/**
 *   里程查询回调方法
 *  @param data JSON格式的返回内容
 */
- (void)onQueryDistance:(NSData * _Nonnull)data{
    _isLoading = NO;
}
#pragma mark - CuiPickViewDelegate

-(void)didFinishPickView:(NSString*)date{
    NSString* timeStr;
    
    //时间戳转换
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    //例如你在国内发布信息,用户在国外的另一个时区,你想让用户看到正确的发布时间就得注意时区设置,时间的换算.
    //例如你发布的时间为2010-01-26 17:40:50,那么在英国爱尔兰那边用户看到的时间应该是多少呢?
    //他们与我们有7个小时的时差,所以他们那还没到这个时间呢...那就是把未来的事做了
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    
    if (date == nil || [date isEqualToString:@""]) {
        NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
        timeStr = [formatter stringFromDate:datenow];//----------将nsdate按formatter格式转成nsstring
    }else{
        timeStr = [NSString stringWithFormat:@"%@%@",date,@":01"];
    }
    NSDate* date1 = [formatter dateFromString:timeStr]; //------------将字符串按formatter转成nsdate
    //时间转时间戳的方法:
    NSString *timeSp = [NSString stringWithFormat:@"%ld",(long)[date1 timeIntervalSince1970]];
    
//    NSLog(@"timeSp:%@",timeSp); //时间戳的值
    
    if (_isStart) {
        self.timeLabel.text = timeStr;
        _startTime = [timeSp longLongValue];
        NSLog(@"选择的开始时间:%lld",_startTime);
    }else{
        self.endTimeLabel.text = timeStr;
        _endTime = [timeSp longLongValue];
        NSLog(@"选择的结束时间:%lld",_endTime);
    }
}

#pragma mark - actievty

- (void)queryBtnDidPress{
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    
    //以后可换成选择要查看的对象名称
    NSString * entityName = @"test521";
    
    if (_startTime == 0) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"开始时间不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        _isLoading = NO;
        return;
    }
    if (_endTime == 0) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"结束时间不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        _isLoading = NO;
        return;
    }
    
    NSLog(@"上传的开始时间:%lld",_startTime);
    NSLog(@"上传的结束时间:%lld",_endTime);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[BTRACEAction shared] getTrackHistory:self serviceId:serviceID entityName:entityName startTime:_startTime endTime:_endTime simpleReturn:1 isProcessed:0 pageSize:5000 pageIndex:1];
    });
}

//选择时间
- (void)selTimeBtnDidPress:(UIButton*)button{
    //选择时间的pickView
    if (button.tag == 0) {
        //开始时间
        _startPickerView.btnTag = 0;
        _textfield.inputView = [[UIView alloc]initWithFrame:CGRectZero];
        [_startPickerView showInView:self.view];
        _isStart = YES;
    }else{
        _endPickerView.btnTag = 1;
        _textfield.inputView = [[UIView alloc]initWithFrame:CGRectZero];
        [_endPickerView showInView:self.view];
        _isStart = NO;
    }
}

#pragma mark - setter&getter
- (UIButton *)selEndTimeBtn{
    if (!_selEndTimeBtn) {
        _selEndTimeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.selTimeBtn.frame.origin.x, CGRectGetMaxY(self.selTimeBtn.frame)+5, 80, 44)];
        [_selEndTimeBtn setTitle:@"结束时间" forState:UIControlStateNormal];
        [_selEndTimeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_selEndTimeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        _selEndTimeBtn.tag = 1;
        [_selEndTimeBtn addTarget:self action:@selector(selTimeBtnDidPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selEndTimeBtn;
}
- (UILabel *)endTimeLabel{
    if (!_endTimeLabel) {
        _endTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.timeLabel.frame.origin.x, CGRectGetMaxY(self.timeLabel.frame) + 5, self.timeLabel.frame.size.width, 44)];
        _endTimeLabel.text = @"选择结束时间";
        _endTimeLabel.backgroundColor = [UIColor yellowColor];
        _endTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _endTimeLabel;
}
- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.selTimeBtn.frame)+10, 64, iphoneWidth - 10-10-80-10-80-10, 44)];
        _timeLabel.text = @"选择开始时间";
        _timeLabel.backgroundColor = [UIColor yellowColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLabel;
}
- (UIButton *)selTimeBtn{
    if (!_selTimeBtn) {
        _selTimeBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 64, 80, 44)];
        [_selTimeBtn setTitle:@"开始时间" forState:UIControlStateNormal];
        [_selTimeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_selTimeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        _selTimeBtn.tag = 0;
        [_selTimeBtn addTarget:self action:@selector(selTimeBtnDidPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selTimeBtn;
}


- (UIButton *)queryBtn{
    if (!_queryBtn) {
        _queryBtn = [[UIButton alloc]initWithFrame:CGRectMake(iphoneWidth - 80 - 10, 64, 80, 44)];
        [_queryBtn setTitle:@"查询轨迹" forState:UIControlStateNormal];
        [_queryBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_queryBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_queryBtn addTarget:self action:@selector(queryBtnDidPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _queryBtn;
}
- (void)dealloc{
    _mapView.delegate = nil;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
@end

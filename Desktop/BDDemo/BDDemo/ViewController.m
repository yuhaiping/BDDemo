//
//  ViewController.m
//  BDDemo
//
//  Created by 余海平 on 17/6/1.
//  Copyright © 2017年 Archermind. All rights reserved.
//

/**
 #import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
 #import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
 #import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
 #import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件
 #import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
 #import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
 #import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件
 */
#import "ViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

#define MEISHI_BUTTON_TAG     100
#define JIUDIAN_BUTTON_TAG    200
#define GOUWU_BUTTON_TAG      300
#define SHENGHUO_BUTTON_TAG   400
#define LVYOU_BUTTON_TAG      500

@interface ViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,BMKPoiSearchDelegate,UITextFieldDelegate>
@property (nonatomic,strong)BMKMapView         *mapView;
@property (nonatomic,strong)BMKLocationService *locService;
@property (nonatomic,strong)UITextField        *searchField;
@property (nonatomic,strong)BMKGeoCodeSearch   *geocodesearch;
@property (nonatomic,strong)BMKPoiSearch       *poisearch;
@property (nonatomic,strong)NSString           *locationCity;
@property (nonatomic,strong)UIView             *poiSearchView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _locationCity = nil;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _mapView = [[BMKMapView alloc]init];
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    [_mapView setZoomLevel:18];
    //_mapView.showsUserLocation = YES;
    // 设置地图类型
    _mapView.mapType = BMKMapTypeStandard;
    // 设置是否需要热力图显示
    [_mapView setBaiduHeatMapEnabled:NO];
     _mapView.rotateEnabled = YES;
    [self.view addSubview:_mapView];
    _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    _searchField = [[UITextField alloc]init];
    _searchField.delegate = self;
    _searchField.borderStyle = UITextBorderStyleRoundedRect;
    _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchField.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchField.clearsOnBeginEditing = YES;
    _searchField.adjustsFontSizeToFitWidth = YES;
    _searchField.returnKeyType = UIReturnKeySearch;
    [self.view addSubview:_searchField];
    _searchField.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *dic = NSDictionaryOfVariableBindings(_mapView,_searchField);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_searchField(>=0)]-10-|" options:0 metrics:0 views:dic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_searchField(==35)]-(>=0)-|" options:0 metrics:0 views:dic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_mapView(>=0)]-0-|" options:0 metrics:0 views:dic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_mapView(>=0)]-0-|" options:0 metrics:0 views:dic]];

    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    // 设置过滤距离，更新的最小间隔距离
    _locService.distanceFilter = 10;
    _locService.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    _geocodesearch.delegate = self;//设置代理为self
    // Do any additional setup after loading the view, typically from a nib.
}
#pragma mark -- initAndLayoutPoiSearchView
- (void)initAndLayoutPoiSearchView {

    _poiSearchView = [[UIView alloc]init];
    _poiSearchView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_poiSearchView];
    _poiSearchView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_poiSearchView(>=0)]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_poiSearchView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_poiSearchView(==35)]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_poiSearchView)]];
    
    UIButton *foodButton = [UIButton buttonWithType:UIButtonTypeCustom];
    foodButton.backgroundColor = [UIColor whiteColor];
    [foodButton setTitle:@"美食" forState:UIControlStateNormal];
    foodButton.tag = MEISHI_BUTTON_TAG;
    [foodButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [foodButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_poiSearchView addSubview:foodButton];
    foodButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIButton *hotelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hotelButton.backgroundColor = [UIColor whiteColor];
    [hotelButton setTitle:@"酒店" forState:UIControlStateNormal];
    hotelButton.tag = JIUDIAN_BUTTON_TAG;
    [hotelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [hotelButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_poiSearchView addSubview:hotelButton];
    hotelButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIButton *shoppingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shoppingButton.backgroundColor = [UIColor whiteColor];
    [shoppingButton setTitle:@"购物" forState:UIControlStateNormal];
    shoppingButton.tag = GOUWU_BUTTON_TAG;
    [shoppingButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [shoppingButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_poiSearchView addSubview:shoppingButton];
    shoppingButton.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *lifeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lifeButton.backgroundColor = [UIColor whiteColor];
    [lifeButton setTitle:@"生活" forState:UIControlStateNormal];
    lifeButton.tag = SHENGHUO_BUTTON_TAG;
    [lifeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [lifeButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_poiSearchView addSubview:lifeButton];
    lifeButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    UIButton *travelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    travelButton.backgroundColor = [UIColor whiteColor];
    [travelButton setTitle:@"旅游" forState:UIControlStateNormal];
    travelButton.tag = LVYOU_BUTTON_TAG;
    [travelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [travelButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_poiSearchView addSubview:travelButton];
    travelButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    NSDictionary *subDic = NSDictionaryOfVariableBindings(foodButton,hotelButton,shoppingButton,lifeButton,travelButton);
    
     [_poiSearchView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[foodButton(>=10)]-0-[hotelButton(==foodButton)]-0-[shoppingButton(==foodButton)]-0-[lifeButton(==foodButton)]-0-[travelButton(==foodButton)]-0-|" options:NSLayoutFormatAlignAllCenterY metrics:0 views:subDic]];
    [_poiSearchView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[foodButton(>=0)]-0-|" options:0 metrics:0 views:subDic]];

}

- (void)buttonAction:(id)sender {

    UIButton *btn = (UIButton*)sender;
    switch (btn.tag) {
        case MEISHI_BUTTON_TAG:
            
            break;
        case JIUDIAN_BUTTON_TAG:
            
            break;
        case GOUWU_BUTTON_TAG:
            
            break;
        case SHENGHUO_BUTTON_TAG:
            
            break;
        case LVYOU_BUTTON_TAG:
            
            break;
            
        default:
            break;
    }
}
#pragma mark -- locationViewDisplayParam
- (void)locationViewDisplayParam {
    
    _mapView.showsUserLocation = NO;
    
    /**
     //设置我的位置(原来是蓝点的位置)的样式
     BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc]init];
     //不显示精度圈
     param.isAccuracyCircleShow = NO;
     param.locationViewImgName = @"pin_red";
     param.locationViewOffsetX = 0;//定位偏移量(经度)
     param.locationViewOffsetY = 0;//定位偏移量（纬度）
     [self.mapView updateLocationViewWithParam:param];
     */
    _mapView.showsUserLocation = YES;

}
#pragma mark -- nameSearch
-(void)nameSearch
{
    _poisearch = [[BMKPoiSearch alloc]init];
    _poisearch.delegate = self;
    
    BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc]init];
    citySearchOption.pageIndex = 0;
    citySearchOption.pageCapacity = 30;
    citySearchOption.city= _locationCity;
    citySearchOption.keyword = _searchField.text;
    
    BOOL flag = [_poisearch poiSearchInCity:citySearchOption];
    
    if(flag)
    {
        NSLog(@"城市内检索发送成功");
         [_locService stopUserLocationService];
    }
    else
    {
        NSLog(@"城市内检索发送失败");
    }
}
#pragma mark -- BMKPoiSearchDelegate
/**
 *返回POI搜索结果
 *@param searcher 搜索对象
 *@param poiResult 搜索结果列表
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode {

    /**
         int _totalPoiNum;		///<本次POI搜索的总结果数
         int _currPoiNum;			///<当前页的POI结果数
         int _pageNum;			///<本次POI搜索的总页数
         int _pageIndex;			///<当前页的索引
         
         NSArray* _poiInfoList;	///<POI列表，成员是BMKPoiInfo
         NSArray* _cityList;		///<城市列表，成员是BMKCityListInfo
     */
    
    NSLog(@"poiResult detail: 本次POI搜索的总结果数 %d 当前页的POI结果数 %d 本次POI搜索的总页数 %d 当前页的索引 %d",poiResult.totalPoiNum,poiResult.currPoiNum,poiResult.pageNum,poiResult.pageIndex);
    NSLog(@"poiResult list: POI列表，成员是BMKPoiInfo %@ 城市列表 %@",poiResult.poiInfoList,poiResult.cityList);
   
    for (int i = 0; i < poiResult.poiInfoList.count; i++) {
        /**
         NSString* _name;			///<POI名称
         NSString* _uid;
         NSString* _address;		///<POI地址
         NSString* _city;			///<POI所在城市
         NSString* _phone;		///<POI电话号码
         NSString* _postcode;		///<POI邮编
         int		  _epoitype;		///<POI类型，0:普通点 1:公交站 2:公交线路 3:地铁站 4:地铁线路
         CLLocationCoordinate2D _pt;	///<POI坐标
         */
        
        //BMKPoiInfo  *poiInfo = (BMKPoiInfo *)[poiResult.poiInfoList objectAtIndex:i];
        
       // NSLog(@"POI名称 %@, uid %@, POI地址 %@ POI所在城市 %@  POI电话号码 %@  POI邮编 %@  POI类型 %d",poiInfo.name,poiInfo.uid,poiInfo.address,poiInfo.city,poiInfo.phone,poiInfo.postcode,poiInfo.epoitype);
       // NSLog(@"POI坐标  %f,  %f, ",poiInfo.pt.longitude,poiInfo.pt.latitude);
    }
    
    BMKPoiInfo  *poiInfo = (BMKPoiInfo *)[poiResult.poiInfoList objectAtIndex:0];
    //初始化一个点的注释
    BMKPointAnnotation *annotoation = [[BMKPointAnnotation alloc] init];
    //坐标
    annotoation.coordinate = poiInfo.pt;
    //title
    annotoation.title = poiInfo.name;
    //子标题
    annotoation.subtitle = poiInfo.address;
    //将标注添加到地图上
    [_mapView addAnnotation:annotoation];
    
    /**
     POI名称 天隆寺, uid 39fd921e6219d2b193114cec, POI地址 地铁1号线 POI所在城市 南京市  POI电话号码 (null)  POI邮编 (null)  POI类型 3
     POI坐标  118.769449,  31.985103,
     */
    //NSLog(@"POI名称 %@, uid %@, POI地址 %@ POI所在城市 %@  POI电话号码 %@  POI邮编 %@  POI类型 %d",poiInfo.name,poiInfo.uid,poiInfo.address,poiInfo.city,poiInfo.phone,poiInfo.postcode,poiInfo.epoitype);
    //NSLog(@"POI坐标  %f,  %f, ",poiInfo.pt.latitude,poiInfo.pt.longitude);
    
    _mapView.centerCoordinate = poiInfo.pt;
    _locationCity = poiInfo.city;
    
    [self locationViewDisplayParam];
    _searchField.text = [NSString stringWithFormat:@"%@%@%@",poiInfo.city,poiInfo.name,poiInfo.address];
    
    NSLog(@"POI _searchField.text IS %@ ",_searchField.text);
    
    [UIView animateWithDuration:2.0 animations:^{
        
        [self initAndLayoutPoiSearchView];
    }];
}

/**
 *返回POI详情搜索结果
 *@param searcher 搜索对象
 *@param poiDetailResult 详情搜索结果
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
- (void)onGetPoiDetailResult:(BMKPoiSearch*)searcher result:(BMKPoiDetailResult*)poiDetailResult errorCode:(BMKSearchErrorCode)errorCode {



}
#pragma mark -- viewWillAppear
- (void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _locService.delegate = nil;
    _geocodesearch.delegate = nil;
    _poisearch.delegate = nil;
}
#pragma mark -- UITextFieldDelegate
// 按return键收起键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_searchField resignFirstResponder];
    [_locService startUserLocationService];
    [self nameSearch];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    [_locService stopUserLocationService];
    [_poiSearchView removeFromSuperview];
    return YES;
}
#pragma mark -- BMKGeoCodeSearchDelegate
/**
 *根据地址名称获取地理信息
 *异步函数，返回结果在BMKGeoCodeSearchDelegate的onGetAddrResult通知
 *@param geoCodeOption       geo检索信息类
 *@return 成功返回YES，否则返回NO
 */
- (BOOL)geoCode:(BMKGeoCodeSearchOption*)geoCodeOption {

    return YES;
}
/**
 *根据地理坐标获取地址信息
 *异步函数，返回结果在BMKGeoCodeSearchDelegate的onGetAddrResult通知
 *@param reverseGeoCodeOption 反geo检索信息类
 *@return 成功返回YES，否则返回NO
 */
- (BOOL)reverseGeoCode:(BMKReverseGeoCodeOption*)reverseGeoCodeOption {

    return YES;
}
#pragma  mark -- BMKLocationServiceDelegate
/**
 *在将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser {

    NSLog(@"----%s---",__FUNCTION__);
}

/**
 *在停止定位后，会调用此函数
 */
- (void)didStopLocatingUser {

    NSLog(@"----%s---",__FUNCTION__);

}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {

    [_mapView updateLocationData:userLocation];
    //NSLog(@"heading is %@",userLocation.heading);

}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    
    [_mapView updateLocationData:userLocation];
    
    //NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    
    _mapView.centerCoordinate = userLocation.location.coordinate;
    
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    //反地理编码
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error!=nil || placemarks.count==0) {
            return ;
        }
        //获取地标
        CLPlacemark *placemark = [placemarks firstObject];
        //设置标题
        userLocation.title = placemark.locality;
        //设置子标题
        userLocation.subtitle = placemark.name;
       /**
        NSLog(@"name is %@\n",placemark.name);
        NSLog(@"thoroughfare is %@\n",placemark.thoroughfare);
        NSLog(@"subThoroughfare is %@\n",placemark.subThoroughfare);
        NSLog(@"locality is %@\n",placemark.locality);
        NSLog(@"subLocality is %@\n",placemark.subLocality);
        NSLog(@"administrativeArea is %@\n",placemark.administrativeArea);
        NSLog(@"subAdministrativeArea is %@\n",placemark.subAdministrativeArea);
        NSLog(@"postalCode is %@\n",placemark.postalCode);
        NSLog(@"ISOcountryCode is %@\n",placemark.ISOcountryCode);
        NSLog(@"inlandWater is %@\n",placemark.inlandWater);
        NSLog(@"ocean is %@\n",placemark.ocean);
        */
        _locationCity = placemark.locality;
        
        [self locationViewDisplayParam];

        _searchField.text = [NSString stringWithFormat:@"%@%@%@%@",placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.name];
        
        NSLog(@"didUpdateBMKUserLocation _searchField.text IS %@ ",_searchField.text);
       
    }];
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {

    NSLog(@"----%s---",__FUNCTION__);

}

- (void)dealloc
{
    if (self.mapView)
    {
        self.mapView = nil;
    }
    
    if (_poisearch != nil) {
        _poisearch = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

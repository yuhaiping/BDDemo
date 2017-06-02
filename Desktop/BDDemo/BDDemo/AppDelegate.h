//
//  AppDelegate.h
//  BDDemo
//
//  Created by 余海平 on 17/6/1.
//  Copyright © 2017年 Archermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic ,strong) BMKMapManager  *mapManager;
@end


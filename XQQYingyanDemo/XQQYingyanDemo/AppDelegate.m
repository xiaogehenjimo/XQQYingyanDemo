//
//  AppDelegate.m
//  XQQYingyanDemo
//
//  Created by XQQ on 16/8/23.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import "AppDelegate.h"
#import "mainViewController.h"
#import "secondViewController.h"
#import <BaiduTraceSDK/BaiduTraceSDK-Swift.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
@interface AppDelegate ()<BMKGeneralDelegate>
/**
 *  manager
 */
@property (nonatomic, strong) BMKMapManager * manager;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    mainViewController * mainVC = [[mainViewController alloc]init];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:mainVC];
    
    secondViewController * secondVC = [[secondViewController alloc]init];
    UINavigationController * secNav = [[UINavigationController alloc]initWithRootViewController:secondVC];
    
    
    UITabBarController * tabBar = [[UITabBarController alloc]init];
    tabBar.viewControllers = @[nav,secNav];
    
    
    self.window.rootViewController = tabBar;
    
    _manager = [[BMKMapManager alloc]init];
    extern  NSString * const AK;
    BOOL ret = [_manager start:AK generalDelegate:self];
    
    if (!ret) {
        NSLog(@"启动失败");
    }
    
    
    
    return YES;
}
#pragma mark - BMKGeneralDelegate
/**
 *返回网络错误
 *@param iError 错误号
 */
- (void)onGetNetworkState:(int)iError{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }

}

/**
 *返回授权验证错误
 *@param iError 错误号 : 为0时验证通过，具体参加BMKPermissionCheckResultCode
 */
- (void)onGetPermissionState:(int)iError{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

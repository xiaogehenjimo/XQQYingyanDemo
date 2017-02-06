//
//  CuiPickerView.h
//  CXB
//
//  Created by xutai on 16/4/15.
//  Copyright © 2016年 xutai. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol CuiPickViewDelegate <NSObject>
-(void)didFinishPickView:(NSString*)date;
-(void)pickerviewbuttonclick:(UIButton *)sender;
-(void)hiddenPickerView;


@end


@interface CuiPickerView : UIView
/**
 *  记录按钮tag
 */
@property(nonatomic, assign)  NSInteger   btnTag;
@property (nonatomic, copy) NSString *province;
@property(nonatomic,strong)NSDate*curDate;
@property (nonatomic,strong)UITextField *myTextField;
@property(nonatomic,weak)id<CuiPickViewDelegate>delegate;
- (void)showInView:(UIView *)view;
- (void)hiddenPickerView;
@end


//
//  LineChartContentView.h
//  LineGraphicTest
//
//  Created by yehengjia on 2015/3/27.
//  Copyright (c) 2015年 mitake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartBaseView.h"
#import "AnchorView.h"

@interface LineChartView : ChartBaseView

//! x軸虛線/實線顏色
@property (nonatomic, strong) UIColor *xLineColor;
//! x軸標籤顏色
@property (nonatomic, strong) UIColor *xTextColor;
//! x軸顏色
@property (nonatomic, strong) UIColor *xAxisLineColor;

//! y軸虛線/實線顏色
@property (nonatomic, strong) UIColor *yLineColor;
//! y軸標籤顏色
@property (nonatomic, strong) UIColor *yTextColor;
//! y軸顏色
@property (nonatomic, strong) UIColor *yAxisLineColor;

//! 折線顏色
@property (nonatomic, strong) UIColor *y1LineColorUpper;
@property (nonatomic, strong) UIColor *y1LineColorLower;

@property (nonatomic, strong) UIColor *y2LineColor;

-(id) initWithFrame:(CGRect)frame;

-(void) resetViewWithFrame:(CGRect) frame;

@end

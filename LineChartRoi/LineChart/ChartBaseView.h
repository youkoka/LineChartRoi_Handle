//
//  ChartBaseView.h
//  LineGraphicTest
//
//  Created by yehengjia on 2015/7/23.
//  Copyright (c) 2015年 mitake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

typedef NS_ENUM(NSInteger, LineDrawType)
{
    //! 無線條
    LineDrawTypeNone = 0,
    
    //! 實線
    LineDrawTypeDashLine,
    
    //! 虛線
    LineDrawTypeDottedLine,
};

typedef NS_ENUM(NSInteger, ZoomScaleAxis)
{
    ZoomScaleAxisNone   = 0,
    ZoomScaleAxisX      = 1 << 1,
    ZoomScaleAxisY      = 1 << 2,
    ZoomScaleAxisXY     = (ZoomScaleAxisX | ZoomScaleAxisY),
};

@interface ChartBaseView : UIView<UIGestureRecognizerDelegate>

@property (readonly) UIEdgeInsets edgeInset;

//! X 軸虛線
//! default value : LineDrawTypeNone
@property LineDrawType drawLineTypeOfX;

//! Y 軸虛線
//! default value : LineDrawTypeNone
@property LineDrawType drawLineTypeOfY;

//! 線圖繪圖區塊原始寬度
@property CGFloat drawOriginContentWidth;

//! 線圖繪圖區塊原始高度
@property CGFloat drawOriginContentHeight;

//! 線圖繪圖區塊寬度
@property CGFloat drawContentWidth;

//! 線圖繪圖區塊高度
@property CGFloat drawContentHeight;

//! 線圖繪圖區塊原點
@property(readonly) CGPoint originPoint;

//! X軸最遠點
@property(readonly) CGPoint rightBottomPoint;

//! 左Y軸最遠點
@property(readonly) CGPoint leftTopPoint;

//! 右Y軸最遠點
@property(readonly) CGPoint rightTopPoint;

//! 上一次點擊點
@property(readonly) CGPoint previousLocation;

//! 目前點擊點
@property(readonly) CGPoint tapLocation;

//! 右劃線起始原點
@property (nonatomic, assign) CGPoint rightLineOriginPoint;

//! 左劃線起始原點
@property (nonatomic, assign) CGPoint leftLineOriginPoint;

//! 資料
@property (nonatomic, strong) NSArray *anchorDataAry;

//! x軸顯示文字
@property (nonatomic, strong) NSMutableArray *xLabelAry;

//! Y 軸上 X 軸(虛)線數量(數量含軸線)
@property NSInteger xDrawLineCount;

//! X 軸上 Y 軸(虛)線數量(數量含軸線, 不含原點)
@property NSInteger yDrawLineCount;

//! y軸最大/小值
@property (nonatomic, assign) CGFloat y1AxisMin;
@property (nonatomic, assign) CGFloat y1AxisMax;
@property (nonatomic, assign) CGFloat y2AxisMin;
@property (nonatomic, assign) CGFloat y2AxisMax;

//! y軸資料最大/值
@property (nonatomic, assign) CGFloat y1MinValue;
@property (nonatomic, assign) CGFloat y1MaxValue;
@property (nonatomic, assign) CGFloat y2MinValue;
@property (nonatomic, assign) CGFloat y2MaxValue;

//! 是否顯示Y1最大最小值
@property (nonatomic, assign) BOOL isShowY1MinMaxValue;

//! 軸線間隔值
@property (nonatomic, strong) NSMutableArray *xAxisPosAry;
@property (nonatomic, strong) NSMutableArray *yAxiaPosAry;

//! y2 畫面比例, default = 0.25
@property (nonatomic, assign) CGFloat y2DrawRatio;

//! 依據畫面大小更新相關點的資訊
-(void) updateViewWithFrame:(CGRect)frame;

@end

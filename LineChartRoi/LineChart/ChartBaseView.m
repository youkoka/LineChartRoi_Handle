//
//  ChartBaseView.m
//  LineGraphicTest
//
//  Created by yehengjia on 2015/7/23.
//  Copyright (c) 2015年 mitake. All rights reserved.
//

#import "ChartBaseView.h"

@implementation ChartBaseView

#if !__has_feature(objc_arc)

-(void) dealloc
{
    OBJC_RELEASE(self.anchorDataAry);
    OBJC_RELEASE(self.xLabelAry);
    OBJC_RELEASE(self.xAxisPosAry);
    OBJC_RELEASE(self.yAxiaPosAry);
    
    [super dealloc];
}
#endif

-(id) initWithFrame:(CGRect)frame
{
    if ( (self = [super initWithFrame:frame]) ) {
        
        //! 將圓點設為左下角
        [self setTransform:CGAffineTransformMakeScale(1, -1)];
        
        //! (上, 左, 下, 右)
        _edgeInset = UIEdgeInsetsMake(10, 40, 20, 20);
        
        //! default value
        self.drawLineTypeOfX = LineDrawTypeDashLine;
        self.drawLineTypeOfY = LineDrawTypeDashLine;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.anchorDataAry = [NSArray array];
        self.xLabelAry = [NSMutableArray array];
        
        self.xAxisPosAry = [NSMutableArray array];
        self.yAxiaPosAry = [NSMutableArray array];
        
        self.y1AxisMin = self.y1AxisMax = self.y2AxisMin = self.y2AxisMax = 0.0f;
        
        self.y1MinValue = self.y2MinValue = CGFLOAT_MAX;
        self.y1MaxValue = self.y2MaxValue = -CGFLOAT_MAX;
        
        self.y2DrawRatio = 0.25f;
        
        self.isShowY1MinMaxValue = YES;
        
        //! X/Y軸預設數
        self.xDrawLineCount = 6;
        self.yDrawLineCount = 2;
    }
    
    return self;
}

//! 依據畫面大小更新相關點的資訊
-(void) updateViewWithFrame:(CGRect)frame
{
    self.frame = frame;
    
    _originPoint = CGPointMake(_edgeInset.left, _edgeInset.bottom);
    _leftTopPoint = CGPointMake(_edgeInset.left, self.frame.size.height - _edgeInset.top);
    _rightBottomPoint = CGPointMake(self.frame.size.width - _edgeInset.right, _edgeInset.bottom);
    _rightTopPoint = CGPointMake(self.frame.size.width - _edgeInset.right, self.frame.size.height - _edgeInset.top);
    
    self.drawOriginContentWidth = self.frame.size.width - (_edgeInset.left + _edgeInset.right);
    self.drawOriginContentHeight = self.frame.size.height - (_edgeInset.bottom + _edgeInset.top);
    
    self.drawContentWidth = self.drawOriginContentWidth;
    self.drawContentHeight = self.drawOriginContentHeight;
    
    self.rightLineOriginPoint = CGPointMake(_rightBottomPoint.x, (_rightTopPoint.y - _rightBottomPoint.y) / 2 + _originPoint.y);
    self.leftLineOriginPoint = CGPointMake(_originPoint.x, (_rightTopPoint.y - _rightBottomPoint.y) / 2 + _originPoint.y);

    [self setNeedsDisplay];
}

@end

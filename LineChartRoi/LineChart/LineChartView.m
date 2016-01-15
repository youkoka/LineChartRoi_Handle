//
//  LineChartContentView.m
//  LineGraphicTest
//
//  Created by yehengjia on 2015/3/27.
//  Copyright (c) 2015年 mitake. All rights reserved.
//

#import "LineChartView.h"
#import "ChartCommon.h"
#import "AnchorView.h"

@interface TextLabel : UILabel

@end

@implementation TextLabel

-(void) drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:rect];
    
    //! 將圓點設為左下角
    [self setTransform:CGAffineTransformMakeScale(1, -1)];
}

@end
@interface LineChartView()

//! 點陣列
@property (nonatomic, strong) NSMutableArray *y1AnchorAry;
@property (nonatomic, strong) NSMutableArray *y2AnchorAry;

//! 儲存Y軸標籤值
@property (nonatomic, strong) NSMutableArray *yAxisValueAry;

//! 儲存顯示在畫面上的 X Label元件(畫面變動時須清空)
@property (nonatomic, strong) NSMutableArray *xLabelSaveAry;

//! 儲存顯示在畫面上的 Y Label元件(畫面變動時須清空)
@property (nonatomic, strong) NSMutableArray *yLabelSaveAry;

//! 儲存顯示在線圖上的Label元件(畫面變動時須清空)
@property (nonatomic, strong) NSMutableArray *contentLabelSaveAry;

-(void) showMinMaxLabel:(AnchorItem *)anchorItem andPoint:(CGPoint) anchorPoint isMinLabel:(BOOL) isMin;

//! 產生 X/Y軸刻度
-(void) buildAxisStepByDataSource;

@end

@implementation LineChartView

#if !__has_feature(objc_arc)
-(void) dealloc
{
    OBJC_RELEASE(self.contentLabelSaveAry);
    OBJC_RELEASE(self.xLabelSaveAry);
    OBJC_RELEASE(self.yLabelSaveAry);
    
    OBJC_RELEASE(self.xLabelAry);
    OBJC_RELEASE(self.yAxisValueAry);
    
    OBJC_RELEASE(self.xLineColor);
    OBJC_RELEASE(self.yLineColor);
    
    OBJC_RELEASE(self.xTextColor);
    OBJC_RELEASE(self.yTextColor);
    
    OBJC_RELEASE(self.xAxisLineColor);
    OBJC_RELEASE(self.yAxisLineColor);
    
    OBJC_RELEASE(self.y1LineColorLower);
    OBJC_RELEASE(self.y1LineColorUpper);
    OBJC_RELEASE(self.y2LineColor);
    
    OBJC_RELEASE(self.y1AnchorAry);
    OBJC_RELEASE(self.y2AnchorAry);
    
    [super dealloc];
}
#endif

-(id) initWithFrame:(CGRect)frame
{
    if ( (self = [super initWithFrame:frame]) ) {
        
        self.xLabelSaveAry = [NSMutableArray array];
        self.yLabelSaveAry = [NSMutableArray array];
        self.contentLabelSaveAry = [NSMutableArray array];
        
        self.xLabelAry = [NSMutableArray array];
        self.yAxisValueAry = [NSMutableArray array];
        
        self.xLineColor = self.xAxisLineColor = [UIColor whiteColor];
        self.yLineColor = self.yAxisLineColor = [UIColor whiteColor];
        
        self.xTextColor = self.yTextColor = [UIColor whiteColor];

        self.y1LineColorLower = [UIColor greenColor];
        self.y1LineColorUpper = [UIColor redColor];
        self.y2LineColor = [UIColor blueColor];
        
        self.y1AnchorAry = [NSMutableArray array];
        self.y2AnchorAry = [NSMutableArray array];
        
        self.backgroundColor = [UIColor blackColor];
        
        [self updateViewWithFrame:frame];
    }
    
    return self;
}

-(void) reloadView {
    
    [self resetViewWithFrame:self.frame];
}

-(void) resetViewWithFrame:(CGRect) frame {

    [self updateViewWithFrame:frame];
    
    [self buildAxisStepByDataSource];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ([self.xLabelSaveAry count] > 0) {
        
        for (UILabel *lb in self.xLabelSaveAry) {
            
            [lb removeFromSuperview];
        }
        
        [self.xLabelSaveAry removeAllObjects];
    }

    if ([self.yLabelSaveAry count] > 0) {
        
        for (UILabel *lb in self.yLabelSaveAry) {
            
            [lb removeFromSuperview];
        }
        
        [self.yLabelSaveAry removeAllObjects];
    }

    if ([self.contentLabelSaveAry count] > 0) {
        
        for (UILabel *lb in self.contentLabelSaveAry) {
            
            [lb removeFromSuperview];
        }
        
        [self.contentLabelSaveAry removeAllObjects];
    }
    
    //! 畫虛線
#pragma mark 畫 Y 軸(虛)線

    if (self.drawLineTypeOfX == LineDrawTypeDashLine ||
        self.drawLineTypeOfX == LineDrawTypeNone) {
        
        CGFloat xPattern[1]= {1};
        CGContextSetLineDash(context, 0.0, xPattern, 0);
    }
    else if(self.drawLineTypeOfX == LineDrawTypeDottedLine) {
        
        CGFloat xPattern[2]= {6, 5};
        CGContextSetLineDash(context, 0.0, xPattern, 2);
    }

    for (NSInteger i = 0; i < [self.xAxisPosAry count]; i++) {
    
        CGFloat xPosition = [[self.xAxisPosAry objectAtIndex:i] floatValue];
        
        //! 範圍區塊內才畫
        if (xPosition > self.originPoint.x && fabs(xPosition - self.originPoint.x) <= self.frame.size.width && i < [self.xLabelAry count]) {
            
            NSString *valXStr = [self.xLabelAry objectAtIndex:i];
            
            if(![valXStr isKindOfClass:[NSNull class]]) {
                
                if (![valXStr isEqualToString:@""]) {
                    
                    if (self.drawLineTypeOfX != LineDrawTypeNone) {
                        
                        [ChartCommon drawLine:context
                                   startPoint:CGPointMake(xPosition, self.originPoint.y)
                                     endPoint:CGPointMake(xPosition, self.leftTopPoint.y)
                                    lineColor:self.yLineColor width:0.5f];
                    }
                }
            }
        }
        
        //! 顯示文字
        if (i < [self.xLabelAry count]) {
            
            NSString *valXStr = [self.xLabelAry objectAtIndex:i];
            UIFont *xFont = [UIFont fontWithName:@"Helvetica" size:12];
            CGSize xValSize = [valXStr sizeWithFont:xFont];
            
            CGFloat lbX_PosX = xPosition;
            CGFloat lbX_PosY = self.originPoint.y - 15;
            
            TextLabel *lbXVal = [[TextLabel alloc] initWithFrame:CGRectMake(lbX_PosX, lbX_PosY, xValSize.width, xValSize.height)];
            lbXVal.text = valXStr;
            lbXVal.font = xFont;
            lbXVal.textColor = self.xTextColor;
            [self.xLabelSaveAry addObject:lbXVal];
            [self addSubview:lbXVal];
#if !__has_feature(objc_arc)
            [lbXVal release];
#endif
        }

    }
#pragma mark 畫 X 軸(虛)線

    if (self.drawLineTypeOfY == LineDrawTypeDashLine ||
        self.drawLineTypeOfY == LineDrawTypeNone) {
        
        CGFloat xPattern[1]= {1};
        CGContextSetLineDash(context, 0.0, xPattern, 0);
    }
    else if(self.drawLineTypeOfY == LineDrawTypeDottedLine) {
        
        CGFloat xPattern[2]= {6, 5};
        CGContextSetLineDash(context, 0.0, xPattern, 2);
    }
    
    for (NSInteger i = 0; i < [self.yAxiaPosAry count]; i++) {
        
        CGFloat yPosition = [[self.yAxiaPosAry objectAtIndex:i] floatValue];
        
        //! 範圍區塊內才畫
        if (yPosition > self.originPoint.y && fabs(yPosition - self.originPoint.y) <= self.frame.size.height) {
            
            if (self.drawLineTypeOfY != LineDrawTypeNone) {
                
                //! 劃線
                [ChartCommon drawLine:context
                           startPoint:CGPointMake(self.originPoint.x, yPosition)
                             endPoint:CGPointMake(self.rightBottomPoint.x, yPosition)
                            lineColor:self.xLineColor width:0.5f];
            }
        }
        
        //! 顯示文字
        UIFont *yFont = [UIFont fontWithName:@"Helvetica" size:12];
        NSString *valYStr = [NSString stringWithFormat:@"%.1f", [self.yAxisValueAry[i] floatValue]];
        if ([valYStr floatValue] == 0) {
            
            valYStr = @"0%";
        }
        
        CGSize yValSize = [valYStr sizeWithFont:yFont];
        
        CGFloat lbY_PosX = 5;
        CGFloat lbY_PosY = yPosition - (yValSize.height / 2 - yValSize.height / 4);
        CGFloat lbY_Width = self.edgeInset.left - lbY_PosX - 5;
        CGFloat lbY_Height = yValSize.height;
        
        TextLabel *lbYVal = [[TextLabel alloc] initWithFrame:CGRectMake(lbY_PosX, lbY_PosY, lbY_Width, lbY_Height)];
        [lbYVal setAdjustsFontSizeToFitWidth:YES];
        lbYVal.text = valYStr;
        lbYVal.font = yFont;
        [lbYVal setTextAlignment:NSTextAlignmentRight];
        if ([valYStr floatValue] > 0) {
            
            lbYVal.textColor = self.y1LineColorUpper;
        }
        else if([valYStr floatValue] < 0) {
            
            lbYVal.textColor = self.y1LineColorLower;
        }
        else {
            
            lbYVal.textColor = self.yTextColor;
        }
        
        [self.yLabelSaveAry addObject:lbYVal];
        [self addSubview:lbYVal];
#if !__has_feature(objc_arc)
        [lbYVal release];
#endif

    }
    
#pragma mark 畫 X, Y軸
    
    CGFloat normal[1]={2};
    CGContextSetLineDash(context,0,normal,0); //! 畫實線

    //! X軸
    [ChartCommon drawLine:context startPoint:self.originPoint endPoint:self.rightBottomPoint lineColor:self.xAxisLineColor width:1.0f];

    //! 左Y軸
    [ChartCommon drawLine:context startPoint:self.originPoint endPoint:self.leftTopPoint lineColor:self.yAxisLineColor width:1.0f];
    
#pragma mark 畫 Y1, Y2連接線
    
    [self.y1AnchorAry removeAllObjects];
    [self.y2AnchorAry removeAllObjects];
    
    CGPoint y1AnchorPoint = self.leftLineOriginPoint;
    CGPoint y2AnchorPoint = self.originPoint;
    
    //! 新增畫圖原點
    [self.y1AnchorAry addObject:[NSValue valueWithCGPoint:y1AnchorPoint]];
    [self.y2AnchorAry addObject:[NSValue valueWithCGPoint:y2AnchorPoint]];

    //! 最大/小標籤值只顯示一次
    BOOL isShowMaxLabel = NO;
    BOOL isShowMinLabel = NO;
    
    for (int i = 0; i < [self.anchorDataAry count]; i++) {
        
        NSArray *dataAry = [self.anchorDataAry objectAtIndex:i];
        
        CGFloat xPerWidth = self.drawContentWidth / [self.anchorDataAry count];
        CGFloat xSectionPointCount = [[self.anchorDataAry objectAtIndex:i] count];
        CGFloat xPerPosWidth = xPerWidth/ xSectionPointCount;
        CGFloat xDrawPos = [[self.xAxisPosAry objectAtIndex:i] floatValue];
        
        //! 區間資料是空的時, 須將連接線回到原點
        //! 這裏會將空區間轉換為2筆座標點
        if (xSectionPointCount == 0) {
            
            y1AnchorPoint.x = xDrawPos;
            y1AnchorPoint.y = self.leftLineOriginPoint.y;

            y2AnchorPoint.x = xDrawPos;
            
            CGPoint y1NextAnchorPoint = y1AnchorPoint;
            CGPoint y2NextAnchorPoint = y2AnchorPoint;
            
            if ((i + 1) < [self.anchorDataAry count]) {
                
                CGFloat xPos = [[self.xAxisPosAry objectAtIndex:i + 1] floatValue];
                
                y1NextAnchorPoint.x = xPos;
                y1NextAnchorPoint.y = y1AnchorPoint.y;
                
                y2NextAnchorPoint.x = xPos;
            }
            
            [self.y1AnchorAry addObject:[NSValue valueWithCGPoint:y1AnchorPoint]];
            [self.y1AnchorAry addObject:[NSValue valueWithCGPoint:y1NextAnchorPoint]];
            
            [self.y2AnchorAry addObject:[NSValue valueWithCGPoint:y2AnchorPoint]];
            [self.y2AnchorAry addObject:[NSValue valueWithCGPoint:y2NextAnchorPoint]];
        }
        
        for (int j = 0; j < xSectionPointCount; j++) {
            
            AnchorItem *item = [dataAry objectAtIndex:j];
            
            CGFloat startPos = xDrawPos + xPerPosWidth * (j + 1);
            
            y1AnchorPoint.x = startPos;
            
            //! 計算y1's y軸座標點
            if (item.y1Value >= 0) {
                
                y1AnchorPoint.y = self.leftLineOriginPoint.y + (item.y1Value / self.y1AxisMax) * (self.leftTopPoint.y - self.leftLineOriginPoint.y);
            }
            else {
                
                y1AnchorPoint.y = self.leftLineOriginPoint.y - (fabs(item.y1Value) / self.y1AxisMax) * (self.leftLineOriginPoint.y - self.originPoint.y);
            }
            
            [self.y1AnchorAry addObject:[NSValue valueWithCGPoint:y1AnchorPoint]];
            
            //! 計算y2's y軸座標點
            y2AnchorPoint.x = startPos;
            
            y2AnchorPoint.y = self.originPoint.y + (item.y2Value / self.y2AxisMax) * ((self.leftTopPoint.y - self.originPoint.y) * self.y2DrawRatio);
            
            [self.y2AnchorAry addObject:[NSValue valueWithCGPoint:y2AnchorPoint]];
            
            //! 顯示Y1最大最小值
            if (self.isShowY1MinMaxValue == YES) {
                
                if (item.y1Value == self.y1MinValue && isShowMinLabel == NO) {
                    
                    if (item.y1Value == self.y1MinValue) {
                        
                        isShowMinLabel = YES;
                    }
                    
                    [self showMinMaxLabel:item andPoint:y1AnchorPoint isMinLabel:YES];
                }
                
                if (item.y1Value == self.y1MaxValue && isShowMaxLabel == NO) {
                    
                    if (item.y1Value == self.y1MaxValue) {
                        
                        isShowMaxLabel = YES;
                    }
                    
                    [self showMinMaxLabel:item andPoint:y1AnchorPoint isMinLabel:NO];
                }
            }
        }
    }
    
    /*
     for (int i = 0; i != [self.y1AnchorAry count]; i++) {
     
     CGPoint startAnchorPoint = [[self.y1AnchorAry objectAtIndex:i] CGPointValue];
     AnchorView *anchor = nil;
     
     #if !__has_feature(objc_arc)
     anchor = [[[AnchorView alloc] initWithFrame:CGRectMake(0, 0, 2 * 2, 2 * 2)] autorelease];
     #else
     anchor = [[AnchorView alloc] initWithFrame:CGRectMake(0, 0, 2 * 2, 2 * 2)];
     #endif
     if (anchor != nil) {
     
     anchor.center = CGPointMake(startAnchorPoint.x, startAnchorPoint.y);
     
     anchor.anchorColor = [UIColor orangeColor];
     
     [self addSubview:anchor];
     }
     }
    */
    CGFloat yPattern[1]= {1};
    CGContextSetLineDash(context, 0.0, yPattern, 0);
    
    for (int i = 0; i < [self.y1AnchorAry count] - 1; i++) {
        
        CGPoint y1StartAnchorPoint = [[self.y1AnchorAry objectAtIndex:i] CGPointValue];
        CGPoint y1EndAnchorPoint = [[self.y1AnchorAry objectAtIndex:i + 1] CGPointValue];
        
        //! 畫Y1連接線
        if(y1StartAnchorPoint.y == self.leftLineOriginPoint.y && y1EndAnchorPoint.y == self.leftLineOriginPoint.y) {
            
            [ChartCommon drawLine:context
                       startPoint:y1StartAnchorPoint
                         endPoint:y1EndAnchorPoint
                        lineColor:self.xAxisLineColor width:1.0f];
        }
        else if (y1StartAnchorPoint.y >= self.leftLineOriginPoint.y && y1EndAnchorPoint.y >= self.leftLineOriginPoint.y) {
            
            [ChartCommon drawLine:context
                       startPoint:y1StartAnchorPoint
                         endPoint:y1EndAnchorPoint
                        lineColor:self.y1LineColorUpper width:1.0f];
        }
        else if(y1StartAnchorPoint.y <= self.leftLineOriginPoint.y && y1EndAnchorPoint.y <= self.leftLineOriginPoint.y) {
            
            [ChartCommon drawLine:context
                       startPoint:y1StartAnchorPoint
                         endPoint:y1EndAnchorPoint
                        lineColor:self.y1LineColorLower width:1.0f];
        }
        else {
            
            //! 用斜率計算
            CGFloat m = (y1EndAnchorPoint.x - y1StartAnchorPoint.x) / (y1EndAnchorPoint.y - y1StartAnchorPoint.y);
            
            CGFloat xValue = m * (self.leftLineOriginPoint.y - y1StartAnchorPoint.y) + y1StartAnchorPoint.x;
            
            CGPoint mOrginPoint = CGPointMake(xValue, self.leftLineOriginPoint.y);
            
            if (y1StartAnchorPoint.y >= self.leftLineOriginPoint.y) {
                
                [ChartCommon drawLine:context
                           startPoint:y1StartAnchorPoint
                             endPoint:mOrginPoint
                            lineColor:self.y1LineColorUpper width:1.0f];
                
                [ChartCommon drawLine:context
                           startPoint:mOrginPoint
                             endPoint:y1EndAnchorPoint
                            lineColor:self.y1LineColorLower width:1.0f];
            }
            else {
                
                [ChartCommon drawLine:context
                           startPoint:y1StartAnchorPoint
                             endPoint:mOrginPoint
                            lineColor:self.y1LineColorLower width:1.0f];
                
                [ChartCommon drawLine:context
                           startPoint:mOrginPoint
                             endPoint:y1EndAnchorPoint
                            lineColor:self.y1LineColorUpper width:1.0f];
                
            }
        }
        
        //! 畫Y2連接線
        CGPoint y2StartAnchorPoint = [[self.y2AnchorAry objectAtIndex:i] CGPointValue];
        CGPoint y2EndAnchorPoint = [[self.y2AnchorAry objectAtIndex:i + 1] CGPointValue];
        CGPoint y2CornerPoint = CGPointMake(y2EndAnchorPoint.x, y2StartAnchorPoint.y);
        
        [ChartCommon drawLine:context
                   startPoint:y2StartAnchorPoint
                     endPoint:y2CornerPoint
                    lineColor:self.y2LineColor width:1.0f];
        
        [ChartCommon drawLine:context
                   startPoint:y2CornerPoint
                     endPoint:y2EndAnchorPoint
                    lineColor:self.y2LineColor width:1.0f];
    }
}

#pragma mark - Custom methods

-(void) showMinMaxLabel:(AnchorItem *)anchorItem andPoint:(CGPoint) anchorPoint isMinLabel:(BOOL) isMin {
    
    //! 顯示文字
    UIFont *yFont = [UIFont fontWithName:@"Helvetica" size:12];
    NSString *valYStr = [NSString stringWithFormat:@"%.1f%%", anchorItem.y1Value];
    
    CGSize yValSize = [valYStr sizeWithFont:yFont];
    
    CGFloat lbY_PosX = anchorPoint.x;
    CGFloat lbY_PosY = 0.0f;
    CGFloat lbY_Width = yValSize.width;
    CGFloat lbY_Height = yValSize.height;
    UIColor *textColor = self.yTextColor;
    
    if (anchorItem.y1Value >= 0) {
        
        textColor = self.y1LineColorUpper;
    }
    else {
        
        textColor = self.y1LineColorLower;
    }
    
    lbY_PosY = anchorPoint.y;
    
    if (isMin) {
    
        lbY_PosY -= lbY_Height;
    }
    
    TextLabel *lbVal = [[TextLabel alloc] initWithFrame:CGRectMake(lbY_PosX - (lbY_Width / 2), lbY_PosY, lbY_Width, lbY_Height)];
    [lbVal setAdjustsFontSizeToFitWidth:YES];
    lbVal.text = valYStr;
    lbVal.font = yFont;
    lbVal.textColor = textColor;
    [lbVal setTextAlignment:NSTextAlignmentCenter];
    [self.contentLabelSaveAry addObject:lbVal];
    [self addSubview:lbVal];
#if !__has_feature(objc_arc)
    [lbVal release];
#endif

}
//! 產生 X/Y軸刻度
-(void) buildAxisStepByDataSource
{
    if (self.xAxisPosAry) {
        
        [self.xAxisPosAry removeAllObjects];
    }
    else {
        
        self.xAxisPosAry = [NSMutableArray array];
    }
    
    if (self.yAxiaPosAry) {
        
        [self.yAxiaPosAry removeAllObjects];
    }
    else {
        
        self.yAxiaPosAry = [NSMutableArray array];
    }
    
    if(self.yAxisValueAry) {
        
        [self.yAxisValueAry removeAllObjects];
    }
    
    if ([self.anchorDataAry count] > 0) {
        
        for (int i = 0; i < [self.anchorDataAry count]; i++) {
            
            NSArray *dataAry = [self.anchorDataAry objectAtIndex:i];
            
            for (AnchorItem *item in dataAry) {
                
                if (item.y1Value < self.y1MinValue) {
                    
                    self.y1MinValue = item.y1Value;
                }
                else if (item.y1Value >= self.y1MaxValue) {
                    
                    self.y1MaxValue = item.y1Value;
                }
                
                if (item.y2Value < self.y2MinValue) {
                    
                    self.y2MinValue = item.y2Value;
                }
                else if (item.y2Value >= self.y2MaxValue) {
                    
                    self.y2MaxValue = item.y2Value;
                }
            }
        }
        
        //! 計算 y1 最大值
        CGFloat y1AxisTempMax = self.y1MaxValue;
        
        if (fabs(self.y1MinValue) > fabs(self.y1MaxValue)) {
        
            y1AxisTempMax = fabs(self.y1MinValue);
        }
        
        NSInteger y1AxisMax = (NSInteger)y1AxisTempMax;
        
        if (y1AxisMax == 0) {
            
            self.y1AxisMax = 1;
            self.y1AxisMin = -1;
        }
        else {
        
            NSString *sY1 = [NSString stringWithFormat:@"%zd", y1AxisMax];
            
            NSInteger count = [sY1 length];
            
            if (count > 0) {
                
                NSMutableString *value = [NSMutableString stringWithString:@"1"];
                
                for (int i = 0; i != count; i++) {
                    
                    [value appendString:@"0"];
                }
                
                self.y1AxisMax = ([sY1 integerValue] / [value integerValue] + 1) * [value integerValue];
                self.y1AxisMin = -([sY1 integerValue] / [value integerValue] + 1) * [value integerValue];
            }
        }
        
        //! 計算 y2 最大值
        CGFloat y2AxisTempMax = self.y2MaxValue;
        
        if (fabs(self.y2MinValue) > fabs(self.y2MaxValue)) {
            
            y2AxisTempMax = fabs(self.y2MinValue);
        }

        NSInteger y2AxisMax = (NSInteger)y2AxisTempMax;
        
        NSString *sY2 = [NSString stringWithFormat:@"%zd", y2AxisMax];
        
        NSInteger count = [sY2 length];
        
        if (count == 1) {
            
            /*
             y2 值為個位數時, 強制給最大值
             避免圖畫起來比例太理譜
             */
            self.y2AxisMax = 10;
            self.y2AxisMin = 0;
        }
        else if (count > 1) {
            
            NSMutableString *value = [NSMutableString stringWithString:@"1"];
            
            for (int i = 0; i != count - 1; i++) {
                
                [value appendString:@"0"];
            }
            
            //! 取到個位數 + 1, 算最大值
            self.y2AxisMax = ([sY2 integerValue] / [value integerValue] + 1) * [value integerValue];
            self.y2AxisMin = 0;
        }
        
        //! 計算軸線數量
        //! x軸
        self.xDrawLineCount = [self.anchorDataAry count];
    
        CGFloat xPerWidth = self.drawContentWidth / self.xDrawLineCount;
        
        for (int i = 0; i < self.xDrawLineCount + 1; i++) {
        
            CGFloat pos = i * xPerWidth + self.originPoint.x;
            
            [self.xAxisPosAry addObject:@(pos)];
        }
        
        //! y軸
        CGFloat ySectionHeight = self.leftLineOriginPoint.y - self.originPoint.y;
        
        CGFloat yPerHeight = ySectionHeight / self.yDrawLineCount;
        
        for (int i = 0; i != self.yDrawLineCount; i++) {
        
            CGFloat height = i * yPerHeight + self.originPoint.y;
            
            [self.yAxiaPosAry addObject:@(height)];
            
            CGFloat yLabel = self.y1AxisMin - self.y1AxisMin / self.yDrawLineCount * i;
            
            [self.yAxisValueAry addObject:@(yLabel)];
        }
        
        for (int i = 0; i != self.yDrawLineCount + 1; i++) {
            
            CGFloat height = i * yPerHeight + self.leftLineOriginPoint.y;
            
            [self.yAxiaPosAry addObject:@(height)];
            
            CGFloat yLabel = self.y1AxisMax / self.yDrawLineCount * i;
            
            [self.yAxisValueAry addObject:@(yLabel)];
        }
    }
    else {
        
        //! 計算軸線數量
        //! x軸
        CGFloat xPerWidth = self.drawContentWidth / self.xDrawLineCount;
        
        for (int i = 0; i < self.xDrawLineCount + 1; i++) {
            
            CGFloat pos = i * xPerWidth + self.originPoint.x;
            
            [self.xAxisPosAry addObject:@(pos)];
        }
        
        //! y軸
        [self.yAxiaPosAry addObject:@(self.leftLineOriginPoint.y)];
        
        [self.yAxisValueAry addObject:@(0)];
    }
}

@end

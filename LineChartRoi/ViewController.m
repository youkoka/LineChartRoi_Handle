//
//  ViewController.m
//  LineChartRoi
//
//  Created by yehengjia on 2016/1/8.
//  Copyright © 2016年 mitake. All rights reserved.
//

#import "ViewController.h"

#import "LineChartView.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *anchorDataAry;

@property (nonatomic, strong) LineChartView *lineChartView;

@end

@interface ViewController ()

@end

@implementation ViewController

#if !__has_feature(objc_arc)

-(void) dealloc
{
    OBJC_RELEASE(self.anchorDataAry);
    OBJC_RELEASE(self.lineChartView);
    
    [super dealloc];
    
}

#endif

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.anchorDataAry = [NSMutableArray array];
    
    NSMutableArray *labelAry = [NSMutableArray array];
    
    [labelAry addObject:@"0"];
    
    for (int j = 0; j != 12; j++) {
        
        NSMutableArray *stepAry = [NSMutableArray array];
        
        if (j != 0 && j != 6 && j != 11) {
        
            for (int i = 0; i != 5; i++) {
                
                AnchorItem *item = [[[AnchorItem alloc] init] autorelease];
                
                item.y1Value = 0.5 - ((rand() % 1000) * 0.001);
                item.y2Value = (rand() % 20000 + 1);
                
                [stepAry addObject:item];
            }
        }
        
        [self.anchorDataAry addObject:stepAry];
        
//        [labelAry addObject:[NSString stringWithFormat:@"%zd", j]];
        
        if (j % 2 == 0) {
        
            [labelAry addObject:[NSString stringWithFormat:@"01/%zd", j + 1]];
        }
        else {
            
            [labelAry addObject:@""];
        }
    }

    CGRect rect = CGRectMake(5, 40,
                             self.view.frame.size.width - 5 - 5,
                             300);
    
    self.lineChartView = [[[LineChartView alloc] initWithFrame:rect] autorelease];
    self.lineChartView.isShowY1MinMaxValue = YES;
    self.lineChartView.drawLineTypeOfY = LineDrawTypeDashLine;
    self.lineChartView.drawLineTypeOfX = LineDrawTypeDashLine;
    self.lineChartView.backgroundColor = [UIColor blackColor];
    self.lineChartView.xAxisLineColor = [UIColor whiteColor];
    self.lineChartView.yAxisLineColor = [UIColor whiteColor];
    self.lineChartView.xLineColor = [UIColor whiteColor];
    self.lineChartView.yLineColor = [UIColor whiteColor];
    self.lineChartView.xTextColor = [UIColor whiteColor];
    self.lineChartView.yTextColor = [UIColor whiteColor];
    self.lineChartView.y1LineColorLower = [UIColor greenColor];
    self.lineChartView.y1LineColorUpper = [UIColor redColor];
    self.lineChartView.y2LineColor = [UIColor colorWithRed:12/255.0 green:139/255.0 blue:207/255.0 alpha:1];;
    self.lineChartView.y2DrawRatio = 0.25;
    self.lineChartView.xLabelAry = labelAry;
    self.lineChartView.anchorDataAry = self.anchorDataAry;
    [self.view addSubview:self.lineChartView];
}

-(BOOL) shouldAutorotate
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect rect;
    
    switch (orientation) {
            
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            rect = CGRectMake(5, 40,
                              self.view.frame.size.width - 5 - 5,
                              300);
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            rect = CGRectMake(5, 10,
                              self.view.frame.size.width - 5 - 5,
                              300);
        }
            break;
        default:
            break;
    }
    
    [self.lineChartView resetViewWithFrame:rect];
    
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

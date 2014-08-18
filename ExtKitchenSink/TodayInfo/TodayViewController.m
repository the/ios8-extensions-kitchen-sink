//
//  TodayViewController.m
//  TodayInfo
//
//  Created by Thomas Eichmann on 15.08.14.
//  Copyright (c) 2014 Thomas Eichmann. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) IBOutlet UILabel *label;
@end

@implementation TodayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterLongStyle;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler
{
    NSDate *now = [NSDate date];
    self.label.text = [self.dateFormatter stringFromDate:now];

    completionHandler(NCUpdateResultNewData);
}

@end

//
//  PageContentViewController.m
//  Taboola JS ObjC Sample
//
//  Created by Roman Slyepko on 1/23/19.
//  Copyright © 2019 Taboola LTD. All rights reserved.
//

#import "PageContentViewController.h"
#import <TaboolaSDK/TaboolaSDK.h>
#import <WebKit/WebKit.h>

@interface PageContentViewController () <TaboolaJSDelegate>
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (nonatomic) BOOL didLoadTaboola;

@end

@implementation PageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.indexLabel.text = [NSString stringWithFormat:@"%lu", self.pageIndex];
    [TaboolaJS sharedInstance].delegate = self;
    [[TaboolaJS sharedInstance] setLogLevel:LogLevelDebug];
    [[TaboolaJS sharedInstance] registerWebView:self.webView];
    [self loadExamplePage:self.webView];
}

-(void)viewWillAppear:(BOOL)animated {
    if (!_didLoadTaboola) {
        _didLoadTaboola = YES;
        if (_pageIndex == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 *NSEC_PER_SEC), dispatch_get_main_queue(), ^{
               [self fetch];
            });
        } else {
            [self fetch];
        }
        
        
    }
}

- (void)loadExamplePage:(UIView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"sampleContentPageLazyLoad" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:appHtml baseURL:[NSURL URLWithString:@"http://cdn.taboola.com/mobile-sdk/init/"]];
}
- (void)fetch {
    [[TaboolaJS sharedInstance] fetchContent:self.webView];
}

@end

//
//  MidArticleJsViewController.m
//  Taboola JS ObjC Sample
//
//  Created by Roman Slyepko on 1/21/19.
//  Copyright © 2019 Taboola LTD. All rights reserved.
//

#import "MidArticleJsViewController.h"
#import <TaboolaSDK/TaboolaSDK.h>
#import <WebKit/WebKit.h>

@interface MidArticleJsViewController () <TaboolaJSDelegate>
@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation MidArticleJsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TaboolaJS sharedInstance].delegate = self;
    [[TaboolaJS sharedInstance] setLogLevel:LogLevelDebug];
    [[TaboolaJS sharedInstance] registerWebView:self.webView];
    [self loadExamplePage:self.webView];
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated{
        [[TaboolaJS sharedInstance] unregisterWebView:self.webView completion:nil];
}

- (void)loadExamplePage:(UIView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"sampleContentPage" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:appHtml baseURL:[NSURL URLWithString:@"http://cdn.taboola.com/mobile-sdk/init/"]];
}

@end

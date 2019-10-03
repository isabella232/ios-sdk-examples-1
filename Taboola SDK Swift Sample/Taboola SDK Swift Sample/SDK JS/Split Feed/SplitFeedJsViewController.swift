//
//  SplitFeedJsViewController.swift
//  Taboola JS Swift Sample
//
//  Created by Roman Slyepko on 2/12/19.
//  Copyright © 2019 Taboola LTD. All rights reserved.
//

import UIKit
import WebKit
import TaboolaSDK

class SplitFeedJsViewController: UIViewController {
    @IBOutlet weak var webViewContainer: UIView!
    var webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame = webViewContainer.frame
        webViewContainer.addSubview(webView)
        TaboolaJS.sharedInstance()?.logLevel = .debug
        TaboolaJS.sharedInstance()?.registerWebView(webView, with: self)
        
        try? loadExamplePage()
    }
    
    func loadExamplePage() throws {
        guard let htmlPath = Bundle.main.path(forResource: "sampleContentPageSplitFeed", ofType: "html") else {
            print("Error loading HTML")
            return
        }
        let appHtml = try String.init(contentsOfFile: htmlPath, encoding: .utf8)
        webView.loadHTMLString(appHtml, baseURL: URL(string: "https://cdn.taboola.com/mobile-sdk/init/"))
    }
}

extension SplitFeedJsViewController: TaboolaJSDelegate {
    func onItemClick(_ placementName: String!, withItemId itemId: String!, withClickUrl clickUrl: String!, isOrganic organic: Bool) -> Bool {
        return true
    }
}

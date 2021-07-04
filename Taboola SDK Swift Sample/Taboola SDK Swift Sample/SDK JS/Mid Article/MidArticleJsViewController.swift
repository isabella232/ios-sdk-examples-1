//
//  MidArticleJsViewController.swift
//  Taboola JS Swift Sample
//
//  Created by Roman Slyepko on 2/12/19.
//  Copyright © 2019 Taboola LTD. All rights reserved.
//

import UIKit
import WebKit
import TaboolaSDK

class MidArticleJsViewController: UIViewController {
    @IBOutlet weak var webViewContainer: UIView!
    var webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame = view.frame
        webViewContainer.addSubview(webView)
        TaboolaJS.sharedInstance()?.logLevel = .debug
        TaboolaJS.sharedInstance()?.registerWebView(webView, with: self)
        // Do any additional setup after loading the view.
        try? loadExamplePage()
    }
    
    func loadExamplePage() throws {
        guard let htmlPath = Bundle.main.path(forResource: "sampleContentPage", ofType: "html") else {
            print("Error loading HTML")
            return
        }
        let appHtml = try String.init(contentsOfFile: htmlPath, encoding: .utf8)
        webView.loadHTMLString(appHtml, baseURL: URL(string: "https://cdn.taboola.com/mobile-sdk/init/"))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParent || self.isBeingDismissed {
          TaboolaJS.sharedInstance()?.unregisterWebView(webView, completion: {})
        }
    }
}

extension MidArticleJsViewController: TaboolaJSDelegate {
    func onItemClick(_ placementName: String!, withItemId itemId: String!, withClickUrl clickUrl: String!, isOrganic organic: Bool) -> Bool {
        return true
    }
}

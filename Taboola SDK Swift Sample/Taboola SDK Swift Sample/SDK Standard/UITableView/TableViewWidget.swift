//
//  TBTableViewController.swift
//  TaboolaDemoSwiftApp
//
//  Created by Yuta Amakawa on 2019/02/15.
//  Copyright © 2019 Taboola. All rights reserved.
//

import UIKit
import TaboolaSDK
import WebKit

class TaboolaCell: UITableViewCell {

}

class TableViewWidget: UITableViewController {
    
    var didLoadTaboolaView = false
    var taboolaWidgetHeight: CGFloat = 0.0

    var taboolaView = TaboolaView()

    override func viewDidLoad() {
        super.viewDidLoad()
        taboolaView = TaboolaView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200))
        taboolaView.delegate = self
        taboolaView.ownerViewController = self
        taboolaView.mode = "alternating-widget-1x2";
        taboolaView.publisher = "sdk-tester-demo";
        taboolaView.pageType = "article";
        taboolaView.pageUrl = "http://www.example.com";
        taboolaView.placement = "Below Article";
        taboolaView.targetType = "mix";
        //Forcing Dark-Mode
        taboolaView.setExtraProperties(["darkMode": true])
    }
    
    func setTaboolaView(taboolaCell:TaboolaCell) {
        if !didLoadTaboolaView {
            
            didLoadTaboolaView = true
            taboolaCell.addSubview(taboolaView)
            
            taboolaView.translatesAutoresizingMaskIntoConstraints = false
            let horizConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[taboolaView]-0-|", options: [], metrics: nil, views: ["taboolaView":taboolaView])
            let vertConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[taboolaView]-0-|", options: [], metrics: nil, views: ["taboolaView":taboolaView])
            taboolaCell.addConstraints(horizConstraints)
            taboolaCell.addConstraints(vertConstraints)
            
            taboolaView.fetchContent()
        } else {
            // This is for orientation changed. use only if the app can change orientation.
            var tabooleRect = taboolaView.frame
            tabooleRect.size.width = self.view.frame.size.width
            taboolaView.frame = tabooleRect
        }
    }
    
    
    // Only for ios10!
    override func viewDidLayoutSubviews() {
        if #available(iOS 11, *) {

        } else {
            for wView in taboolaView.subviews {
                if let webView = wView as? WKWebView {
                    webView.setNeedsLayout()
                }
            }
        }
    }
    
    deinit {
        taboolaView.reset()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch indexPath.row {
        case 9:
            if taboolaWidgetHeight > 0 {
                return taboolaWidgetHeight
            }
            else {
                return 0
            }
        default:
            return 200
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {
        case 9:
            let taboolaCell = tableView.dequeueReusableCell(withIdentifier: "taboolaCell", for: indexPath) as! TaboolaCell
            setTaboolaView(taboolaCell: taboolaCell)
            
            return taboolaCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "randomCell", for: indexPath)
            cell.contentView.backgroundColor = UIColor.random
            return cell
        }
    }
    
}


extension TableViewWidget: TaboolaViewDelegate {

    func taboolaView(_ taboolaView: UIView!, didLoadPlacementNamed placementName: String!, withHeight height: CGFloat) {
        print("did height \(height)")
        taboolaWidgetHeight = height
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }

    func taboolaView(_ taboolaView: UIView!, didFailToLoadPlacementNamed placementName: String!, withErrorMessage error: String!) {
        //
    }

    func onItemClick(_ placementName: String!, withItemId itemId: String!, withClickUrl clickUrl: String!, isOrganic organic: Bool) -> Bool {
        return true
    }
}

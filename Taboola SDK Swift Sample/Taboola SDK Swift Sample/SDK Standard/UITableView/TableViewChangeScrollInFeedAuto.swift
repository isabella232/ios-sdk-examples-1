//
//  TBTableViewController.swift
//  TaboolaDemoSwiftApp
//
//  Created by Yuta Amakawa on 2019/02/15.
//  Copyright © 2019 Taboola. All rights reserved.
//

import UIKit
import TaboolaSDK

class TableViewChangeScrollInFeedAuto: UITableViewController {
    
    var taboolaView:TaboolaView!
    var didLoadTaboolaView = false
    
    lazy var viewId: String = {
        let timestamp = Int(Date().timeIntervalSince1970)
        return "\(timestamp)"
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        taboolaView = TaboolaView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: TaboolaView.widgetHeight()))
        taboolaView.delegate = self
        taboolaView.ownerViewController = self
        taboolaView.mode = "thumbs-feed-01"
        taboolaView.publisher = "sdk-tester-demo"
        taboolaView.pageType = "article"
        taboolaView.pageUrl = "http://www.example.com"
        taboolaView.placement = "Feed without video"
        taboolaView.targetType = "mix"
        taboolaView.viewID = viewId
        taboolaView.setInterceptScroll(true)
        //Forcing Dark-Mode
        taboolaView.setExtraProperties(["darkMode": false])
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch indexPath.row {
        case 4:
            return TaboolaView.widgetHeight()
        default:
            return 200
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {
        case 4:
            let taboolaCell = tableView.dequeueReusableCell(withIdentifier: "taboolaCell", for: indexPath) as! TaboolaCell
            for v in taboolaCell.contentView.subviews {
                v.removeFromSuperview()
            }
            taboolaCell.contentView.addSubview(taboolaView)
            if !didLoadTaboolaView {
                didLoadTaboolaView = true
                taboolaView.fetchContent()
            }
            return taboolaCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "randomCell", for: indexPath)
            cell.contentView.backgroundColor = UIColor.random
            return cell
        }
    }
    
    deinit {
        taboolaView.reset()
        print("deinit called")
    }
    
    
}


extension TableViewChangeScrollInFeedAuto: TaboolaViewDelegate {
    

    func taboolaView(_ taboolaView: UIView!, didLoadPlacementNamed placementName: String!, withHeight height: CGFloat) {
        //
    }

    func taboolaView(_ taboolaView: UIView!, didFailToLoadPlacementNamed placementName: String!, withErrorMessage error: String!) {
        //
    }

    func onItemClick(_ placementName: String!, withItemId itemId: String!, withClickUrl clickUrl: String!, isOrganic organic: Bool) -> Bool {
        return true
    }
}

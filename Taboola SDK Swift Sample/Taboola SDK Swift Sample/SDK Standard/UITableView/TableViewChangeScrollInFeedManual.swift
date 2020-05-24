//
//  TableViewChangeScrollInFeedManual.swift
//  Taboola SDK Swift Sample
//
//  Created by Liad Elidan on 18/05/2020.
//  Copyright © 2020 Taboola LTD. All rights reserved.
//

import UIKit
import TaboolaSDK

class TableViewChangeScrollInFeedManual: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var taboolaWidget: TaboolaView!
    var taboolaFeed: TaboolaView!
    var didLoadFeed = false
    var didLoadTaboolaView = false
    var taboolaWidgetHeight: CGFloat = 0.0
    
    lazy var viewId: String = {
        let timestamp = Int(Date().timeIntervalSince1970)
        return "\(timestamp)"
    }()
    
    fileprivate struct TaboolaSection {
        let placement: String
        let mode: String
        let index: Int
        let scrollIntercept: Bool
        
        static let widget = TaboolaSection(placement: "Below Article", mode: "alternating-widget-without-video-1x4", index: 1, scrollIntercept: false)
        static let feed = TaboolaSection(placement: "Feed without video", mode: "thumbs-feed-01", index: 3, scrollIntercept: true)
    }
    
    override func viewDidLoad() {
        taboolaWidget = taboolaView(mode: TaboolaSection.widget.mode,
                                    placement: TaboolaSection.widget.placement,
                                    scrollIntercept: TaboolaSection.widget.scrollIntercept)
        taboolaFeed = taboolaView(mode: TaboolaSection.feed.mode,
                                  placement: TaboolaSection.feed.placement,
                                  scrollIntercept: TaboolaSection.feed.scrollIntercept)
        
        taboolaWidget.fetchContent()
    }

    
    func taboolaView(mode: String, placement: String, scrollIntercept: Bool) -> TaboolaView {
        let taboolaView = TaboolaView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 200))
        taboolaView.delegate = self
        taboolaView.mode = mode
        taboolaView.publisher = "sdk-tester-demo"
        taboolaView.pageType = "article"
        taboolaView.pageUrl = "http://www.example.com"
        taboolaView.placement = placement
        taboolaView.targetType = "mix"
        taboolaView.overrideScrollIntercept = true
        taboolaView.logLevel = .debug
        taboolaView.setExtraProperties(["useOnlineTemplate": true])
        taboolaView.viewID = viewId;
        return taboolaView
    }
    
    deinit {
        taboolaWidget.reset()
        taboolaFeed.reset()
    }
    
}

extension TableViewChangeScrollInFeedManual: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == TaboolaSection.widget.index || section == TaboolaSection.feed.index) ? 1 : 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case TaboolaSection.widget.index:
            if taboolaWidgetHeight > 0 {
                return taboolaWidgetHeight
            }
            else {
                return 0
            }
        case TaboolaSection.feed.index:
            return TaboolaView.widgetHeight()
        default:
            return 200
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let taboolaIdentifier = "TaboolaCell"
        switch indexPath.section {
        case TaboolaSection.widget.index:
            let taboolaCell = tableView.dequeueReusableCell(withIdentifier: taboolaIdentifier, for: indexPath) as? TaboolaTableViewCell ?? TaboolaTableViewCell()
            taboolaCell.contentView.addSubview(taboolaWidget)
            return taboolaCell
        case TaboolaSection.feed.index:
            let taboolaCell = tableView.dequeueReusableCell(withIdentifier: taboolaIdentifier, for: indexPath) as? TaboolaTableViewCell ?? TaboolaTableViewCell()
            for v in taboolaCell.contentView.subviews {
                v.removeFromSuperview()
            }
            taboolaCell.contentView.addSubview(taboolaFeed)
            if !didLoadTaboolaView {
                didLoadTaboolaView = true
                taboolaFeed.fetchContent()
            }
            return taboolaCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "randomCell", for: indexPath)
            cell.contentView.backgroundColor = UIColor.random
            return cell
        }
    }
    
    func scrollViewDidScroll(toTopTaboolaView taboolaView: UIView!) {
        if taboolaFeed.scrollEnable {
            print("did finish scrolling taboola")
            taboolaFeed.scrollEnable = false
            tableView.isScrollEnabled = true
            taboolaFeed.releaseScroll()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didEndScrollOfParrentScroll()
    }
 
    func didEndScrollOfParrentScroll(){
        
        let tableViewFullHeight = tableView.contentSize.height
        let visibleHeight = tableView.frame.size.height
        var yContentOffset = tableView.contentOffset.y
        
        if #available(iOS 11.0, *) {
            yContentOffset = yContentOffset - tableView.adjustedContentInset.bottom
        } else {
            yContentOffset = yContentOffset - tableView.contentInset.bottom
        }

        let distanceFromBottom = tableViewFullHeight - yContentOffset
        
        if distanceFromBottom < visibleHeight, tableView.isScrollEnabled, tableView.contentSize.height > 0 {

            tableView.isScrollEnabled = false
            taboolaFeed.scrollEnable = true
        }
    }
}

extension TableViewChangeScrollInFeedManual: TaboolaViewDelegate {
    func taboolaView(_ taboolaView: UIView!, didLoadPlacementNamed placementName: String!, withHeight height: CGFloat) {
        if placementName == TaboolaSection.widget.placement {
            taboolaWidgetHeight = height
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    func taboolaView(_ taboolaView: UIView!, didFailToLoadPlacementNamed placementName: String!, withErrorMessage error: String!) {
        print("Did fail: \(String(describing: placementName)) error: \(String(describing: error))")
    }
    
    func onItemClick(_ placementName: String!, withItemId itemId: String!, withClickUrl clickUrl: String!, isOrganic organic: Bool) -> Bool {
        return true
    }
}

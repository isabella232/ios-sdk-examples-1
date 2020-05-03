//
//  CollectionViewChangeScrollInFeedManual.swift
//  Taboola SDK Swift Sample
//
//  Created by Roman Slyepko on 3/20/19.
//  Copyright © 2019 Taboola LTD. All rights reserved.
//

import UIKit
import TaboolaSDK

class CollectionViewChangeScrollInFeedManual: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var taboolaWidget: TaboolaView!
    var taboolaFeed: TaboolaView!
    var didLoadFeed = false
    
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

extension CollectionViewChangeScrollInFeedManual: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (section == TaboolaSection.widget.index || section == TaboolaSection.feed.index) ? 1 : 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let taboolaIdentifier = "TaboolaCell"
        switch indexPath.section {
        case TaboolaSection.widget.index:
            let taboolaCell = collectionView.dequeueReusableCell(withReuseIdentifier: taboolaIdentifier, for: indexPath) as? TaboolaCollectionViewCell ?? TaboolaCollectionViewCell()
            taboolaCell.contentView.addSubview(taboolaWidget)
            return taboolaCell
        case TaboolaSection.feed.index:
            let taboolaCell = collectionView.dequeueReusableCell(withReuseIdentifier: taboolaIdentifier, for: indexPath) as? TaboolaCollectionViewCell ?? TaboolaCollectionViewCell()
            taboolaCell.contentView.addSubview(taboolaFeed)
            return taboolaCell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "randomCell", for: indexPath)
            cell.contentView.backgroundColor = UIColor.random
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case TaboolaSection.widget.index:
            if taboolaWidgetHeight > 0 {
                return CGSize(width: view.frame.size.width, height: taboolaWidgetHeight)
            }
            else {
                return CGSize(width: view.frame.size.width, height: 0)
            }
        case TaboolaSection.feed.index:
            return CGSize(width: view.frame.size.width, height: TaboolaView.widgetHeight())
        default:
            return CGSize(width: view.frame.size.width, height: 200)
        }
    }
    
    func scrollViewDidScroll(toTopTaboolaView taboolaView: UIView!) {
        if taboolaFeed.scrollEnable {
            print("did finish scrolling taboola")
            taboolaFeed.scrollEnable = false
            collectionView.isScrollEnabled = true
            taboolaFeed.releaseScroll()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didEndScrollOfParrentScroll()
    }
    
    func didEndScrollOfParrentScroll(){
        let height = collectionView.frame.size.height
        var yContentOffset = collectionView.contentOffset.y
        
        if #available(iOS 11.0, *) {
            yContentOffset = yContentOffset - collectionView.adjustedContentInset.bottom
        } else {
            yContentOffset = yContentOffset - collectionView.contentInset.bottom
        }
        
        let distanceFromBotton = collectionView.contentSize.height - yContentOffset
        if distanceFromBotton < height, collectionView.isScrollEnabled, collectionView.contentSize.height > 0 {
            collectionView.isScrollEnabled = false
            taboolaFeed.scrollEnable = true
        }
    }
    
}



extension CollectionViewChangeScrollInFeedManual: TaboolaViewDelegate {
    func taboolaView(_ taboolaView: UIView!, didLoadPlacementNamed placementName: String!, withHeight height: CGFloat) {
        if placementName == TaboolaSection.widget.placement {
            taboolaWidgetHeight = height
            collectionView.collectionViewLayout.invalidateLayout()
            if !didLoadFeed {
                didLoadFeed = true
                // We are loading the feed only when the widget finished loading- for dedup.
                taboolaFeed.fetchContent()
            }
        }
    }
    
    func taboolaView(_ taboolaView: UIView!, didFailToLoadPlacementNamed placementName: String!, withErrorMessage error: String!) {
        print("Did fail: \(String(describing: placementName)) error: \(String(describing: error))")
    }
    
    func onItemClick(_ placementName: String!, withItemId itemId: String!, withClickUrl clickUrl: String!, isOrganic organic: Bool) -> Bool {
        return true
    }
}

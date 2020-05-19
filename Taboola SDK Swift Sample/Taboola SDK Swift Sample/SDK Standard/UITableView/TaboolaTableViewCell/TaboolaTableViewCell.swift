//
//  TaboolaTableViewCell.swift
//  Taboola SDK Swift Sample
//
//  Created by Liad Elidan on 18/05/2020.
//  Copyright © 2020 Taboola LTD. All rights reserved.
//
import UIKit

class TaboolaTableViewCell: UITableViewCell {
    
    override func prepareForReuse() {
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
    }
}

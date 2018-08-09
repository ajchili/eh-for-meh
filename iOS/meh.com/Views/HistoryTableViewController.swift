//
//  HistoryTableViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 8/8/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseDatabase

class HistoryTableViewController: UITableViewController {
    
    var theme: Theme! {
        didSet {
            setTheme()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "History"
    }
    
    fileprivate func setTheme() {
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = self.theme.backgroundColor
            self.tableView.separatorColor = self.theme.accentColor
        }
    }
    
    fileprivate func loadData() {
        Database.database().reference().child("previousDeals").queryOrdered(byChild: "time").queryLimited(toFirst: 15).observeSingleEvent(of: .value) { snapshot in
            
        }
    }
}

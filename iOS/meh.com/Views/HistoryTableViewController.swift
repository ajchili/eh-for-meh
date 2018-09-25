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
    
    let cellIdentifier = "previousDealCell"
    var previousDeals = [Deal]()
    
    var theme: Theme! {
        didSet {
            setTheme()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "History"
        tableView.separatorStyle = .none
        
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        loadData()
    }
    
    fileprivate func setTheme() {
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = self.theme.backgroundColor
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previousDeals.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dealView = MainViewController()
        let previousDeal = previousDeals[indexPath.row]
        dealView.deal = previousDeal
        dealView.navigationItem.title = previousDeal.title
        navigationController?.pushViewController(dealView, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HistoryTableViewCell
        
        cell.deal = previousDeals[indexPath.row]
        
        return cell
    }
    
    fileprivate func loadData() {
        Database.database().reference().child("previousDeal").queryOrdered(byChild: "time").queryLimited(toLast: 16).observe(.value) { snapshot in
            self.previousDeals.removeAll()
            
            for child in snapshot.children.allObjects.reversed().dropFirst() {
                let childSnapshot = child as! DataSnapshot
                
                DealLoader.sharedInstance.loadDeal(forDeal: childSnapshot.key, completion: { deal in
                    self.previousDeals.append(deal)
                    
                    self.tableView.reloadData()
                })
            }
        }
    }
}

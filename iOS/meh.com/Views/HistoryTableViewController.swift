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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        navigationItem.title = "History"
        tableView.separatorStyle = .none
        
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        let backButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(handleBack))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = backButton
        
        loadData()
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
        dealView.view.backgroundColor = previousDeal.theme.backgroundColor
        dealView.modalPresentationStyle = .currentContext
        dealView.modalTransitionStyle = .crossDissolve
        present(dealView, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HistoryTableViewCell
        
        cell.deal = previousDeals[indexPath.row]
        
        return cell
    }
    
    @objc func handleBack() {
        dismiss(animated: true)
    }
    
    fileprivate func loadData() {
        let toLast: UInt = UIDevice.current.userInterfaceIdiom == .pad ? 51 : 21;
        
        Database.database().reference().child("previousDeal").queryOrdered(byChild: "time").queryLimited(toLast: toLast).observeSingleEvent(of: .value) { snapshot in
            self.previousDeals.removeAll()
            
            for child in snapshot.children.allObjects.reversed().dropFirst() {
                let childSnapshot = child as! DataSnapshot
                
                DealLoader.sharedInstance.loadDeal(forDeal: childSnapshot.key, completion: { deal in
                    self.previousDeals.append(deal)
                    
                    print("\(deal.id) \(deal.title)")
                    
                    self.tableView.reloadData()
                })
            }
        }
    }
}

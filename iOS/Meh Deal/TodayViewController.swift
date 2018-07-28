//
//  TodayViewController.swift
//  Meh Deal
//
//  Created by Kirin Patel on 1/20/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import Firebase
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    let viewButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("View", for: .normal)
        button.addTarget(self, action: #selector(handleViewDealInApp), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    let buyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Buy", for: .normal)
        button.addTarget(self, action: #selector(handleBuy), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    static var wasFirebaseSet: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !TodayViewController.wasFirebaseSet {
            TodayViewController.wasFirebaseSet = true
            FirebaseApp.configure()
        }
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        loadData()
        completionHandler(NCUpdateResult.newData)
    }
    
    @objc func handleViewDealInApp() {
        let url: URL? = URL(string: "meh:")!
        
        if let appurl = url {
            Analytics.logEvent("viewDealInApp", parameters: [:])
            self.extensionContext!.open(appurl, completionHandler: nil)
        }
    }
    
    @objc func handleBuy() {
        Analytics.logEvent("buyInExtension", parameters: [:])
        self.extensionContext!.open(URL(string: "https://meh.com/account/signin?returnurl=https%3A%2F%2Fmeh.com%2F%23checkout")!, completionHandler: nil)
    }
    
    fileprivate func setupView() {
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        
        view.addSubview(priceLabel)
        priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        priceLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        
        view.addSubview(buyButton)
        buyButton.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor).isActive = true
        buyButton.leftAnchor.constraint(equalTo: priceLabel.rightAnchor, constant: 8).isActive = true
        
        view.addSubview(viewButton)
        viewButton.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor).isActive = true
        viewButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
    }
    
    fileprivate func loadData() {
        buyButton.isHidden = true
        viewButton.isHidden = true
        Database.database().reference().child("deal/title").observeSingleEvent(of: .value) { (snapshot) in
            self.titleLabel.text = (snapshot.value as! String)
            self.buyButton.isHidden = false
            self.viewButton.isHidden = false
        }
        Database.database().reference().child("deal/items").observeSingleEvent(of: .value) { (snapshot) in
            self.calculatePrices(snapshot)
        }
    }
    
    fileprivate func calculatePrices(_ snapshot: DataSnapshot) {
        var min: CGFloat = .infinity
        var max: CGFloat = 0
        
        for child in snapshot.children.allObjects {
            let childSnapshot = child as! DataSnapshot
            
            if let price = childSnapshot.childSnapshot(forPath: "price").value as? CGFloat {
                if price < min {
                    min = price
                    if max == 0 {
                        max = price
                    }
                } else if price > max {
                    max = price
                }
            }
        }
        
        var sMin: Any = min
        var sMax: Any = max
        
        if min.truncatingRemainder(dividingBy: 1.0) == 0 {
            sMin = String(format: "%g", min)
        }
        
        if max.truncatingRemainder(dividingBy: 1.0) == 0 {
            sMax = String(format: "%g", max)
        }
        
        if snapshot.childrenCount == 1 || min == max {
            self.priceLabel.text = "$\(sMin)"
        } else {
            self.priceLabel.text = "$\(sMin) - $\(sMax)"
        }
    }
}

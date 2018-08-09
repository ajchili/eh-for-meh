//
//  MainViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 7/17/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MainViewController: UITabBarController, UITabBarControllerDelegate {
    
    let itemTab = DealViewController()
    let buyTab = BuyViewController()
    let historyTab = HistoryNavigationViewController()
    let settingsTab = SettingsViewController()
    var theme: Theme! {
        didSet {
            setTheme()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupView()
        setupThemeObserver()
        setupDealObserver()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true;
    }
    
    fileprivate func setupView() {
        itemTab.tabBarItem = UITabBarItem(title: "Deal", image: UIImage(named: "view"), selectedImage: nil)
        buyTab.tabBarItem = UITabBarItem(title: "Buy", image: UIImage(named: "buy"), selectedImage: nil)
        historyTab.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 0)
        settingsTab.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settings"), selectedImage: nil)
        
        viewControllers = [itemTab, buyTab, historyTab, settingsTab]
        selectedIndex = 0
    }
    
    fileprivate func setTheme() {
        UIView.animate(withDuration: 0.5) {
            self.tabBar.tintColor = self.theme.backgroundColor
            self.tabBar.barTintColor = self.theme.accentColor
            self.view.backgroundColor = self.theme.backgroundColor
        }
        
        buyTab.theme = theme
        historyTab.theme = theme
        settingsTab.theme = theme
    }
    
    fileprivate func setupThemeObserver() {
        ThemeLoader.sharedInstance.setupThemeListener { theme in
            self.theme = theme
        }
    }
    
    fileprivate func setupDealObserver() {
        DealLoader.sharedInstance.loadCurrentDeal { deal in
            self.itemTab.deal = deal
        }
    }
}

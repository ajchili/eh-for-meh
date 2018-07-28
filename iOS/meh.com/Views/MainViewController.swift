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
    
    let itemTab = ItemViewController()
    let buyTab = BuyViewController()
    let settingsTab = SettingsViewController()
    var backgroundColor: UIColor! {
        didSet {
            buyTab.backgroundColor = backgroundColor
        }
    }
    var accentColor: UIColor! {
        didSet {
            buyTab.accentColor = accentColor
            settingsTab.accentColor = accentColor
        }
    }
    var isDark: Bool! {
        didSet {
            setTheme()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupView()
        setupThemeObserver()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true;
    }
    
    fileprivate func setupView() {
        itemTab.tabBarItem = UITabBarItem(title: "Deal", image: UIImage(named: "view"), selectedImage: nil)
        buyTab.tabBarItem = UITabBarItem(title: "Buy", image: UIImage(named: "buy"), selectedImage: nil)
        settingsTab.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settings"), selectedImage: nil)
        
        viewControllers = [itemTab, buyTab, settingsTab]
        selectedIndex = 0
    }
    
    fileprivate func setTheme() {
        UIView.animate(withDuration: 0.5) {
            self.tabBar.barStyle = self.isDark ? .black : .default
            self.tabBar.tintColor = self.backgroundColor
            self.view.backgroundColor = self.backgroundColor
        }
    }
    
    fileprivate func setupThemeObserver() {
        Database.database().reference().child("deal/theme").observe(.value) { snapshot in
            self.backgroundColor = UIColor.color(fromHexString: snapshot.childSnapshot(forPath: "backgroundColor").value as? String ?? "#ffffff")
            self.accentColor = UIColor.color(fromHexString: snapshot.childSnapshot(forPath: "accentColor").value as? String ?? "#000000")
            self.isDark = snapshot.childSnapshot(forPath: "foreground").value as? String ?? "dark" == "dark"
        }
    }
}

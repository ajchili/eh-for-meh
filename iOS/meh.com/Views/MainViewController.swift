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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let itemTab = ItemViewController()
        itemTab.tabBarItem = UITabBarItem(title: "Deal", image: UIImage(named: "view"), selectedImage: nil)
        
        let buyTab = BuyViewController()
        buyTab.tabBarItem = UITabBarItem(title: "Buy", image: UIImage(named: "buy"), selectedImage: nil)
        
        let settingsTab = SettingsViewController()
        settingsTab.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settings"), selectedImage: nil)
        
        self.viewControllers = [itemTab, buyTab, settingsTab]
        self.selectedIndex = 0
        
        view.backgroundColor = .white
        
        setBackgroundColor()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true;
    }
    
    fileprivate func setBackgroundColor() {
        Database.database().reference().child("deal/theme/backgroundColor").observe(.value) { (snapshot) in
            if snapshot.exists() {
                let color: UIColor = UIColor.color(fromHexString: snapshot.value as! String)
                self.tabBar.tintColor = color
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.backgroundColor = color
                })
            }
        }
    }
}

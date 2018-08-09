//
//  HistoryNavigationViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 8/8/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class HistoryNavigationViewController: UINavigationController {
    
    let mainView = HistoryTableViewController()
    
    var theme: Theme! {
        didSet {
            setTheme()
            mainView.theme = theme
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.prefersLargeTitles = true
        
        pushViewController(mainView, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let theme = theme {
            return theme.dark ? .lightContent : .default
        }
        
        return .default
    }
    
    fileprivate func setTheme() {
        UIView.animate(withDuration: 0.5) {
            self.navigationBar.barTintColor = self.theme.accentColor
            self.navigationBar.tintColor = self.theme.backgroundColor
            self.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: self.theme.backgroundColor]
            self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: self.theme.backgroundColor]
            self.view.backgroundColor = self.theme.backgroundColor
        }
    }
}

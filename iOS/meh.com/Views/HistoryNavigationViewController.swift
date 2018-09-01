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
            if self.theme.dark {
                self.navigationBar.tintColor = .white
                self.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
                self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            } else {
                self.navigationBar.tintColor = .black
                self.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
                self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
            }
            self.view.backgroundColor = self.theme.backgroundColor
        }
    }
}

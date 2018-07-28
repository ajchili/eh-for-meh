//
//  WebViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class BuyViewController: UIViewController {
    
    let webView: UIWebView = {
        let wb = UIWebView()
        wb.translatesAutoresizingMaskIntoConstraints = false
        wb.layer.cornerRadius = 6
        wb.layer.masksToBounds = true
        return wb
    }()
    
    let buyInBrowserButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("Buy in Browser", for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(handleBuyInBrowser), for: .touchUpInside)
        return button
    }()
    
    var backgroundColor: UIColor! {
        didSet {
            setTheme()
        }
    }
    var accentColor: UIColor! {
        didSet {
            setTheme()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        setupView()
    }
    
    @objc func handleBuyInBrowser() {
        UIApplication.shared.open(URL(string: "https://meh.com/account/signin?returnurl=https%3A%2F%2Fmeh.com%2F%23checkout")!, options: [:]) { _ in
            Analytics.logEvent("buyInApp", parameters: [:])
        }
    }
    
    fileprivate func setupView() {
        view.addSubview(buyInBrowserButton)
        buyInBrowserButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        buyInBrowserButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        buyInBrowserButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        buyInBrowserButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        webView.bottomAnchor.constraint(equalTo: buyInBrowserButton.topAnchor, constant: -10).isActive = true
        webView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        webView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        webView.loadRequest(URLRequest(url: URL(string: "https://meh.com/account/signin?returnurl=https%3A%2F%2Fmeh.com%2F%23checkout")!))
    }
    
    fileprivate func setTheme() {
        UIView.animate(withDuration: 0.5) {
            self.buyInBrowserButton.backgroundColor = self.accentColor
            self.buyInBrowserButton.tintColor = self.backgroundColor
            self.buyInBrowserButton.setTitleColor(self.backgroundColor, for: .normal)
        }
    }
}

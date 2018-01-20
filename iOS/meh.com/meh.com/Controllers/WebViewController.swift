//
//  WebViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class WebViewController: UIViewController {
    
    var ref: DatabaseReference!
    let webView: UIWebView = {
        let wb = UIWebView()
        return wb
    }()
    
    var backgroundColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        view.addSubview(webView)
        webView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        ref.child("settings").observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            self.backgroundColor = UIColor.color(fromHexString: value?["backgroundColor"] as? String ?? "#000000")
            
            self.view.layer.backgroundColor = self.backgroundColor!.cgColor
            self.webView.backgroundColor = self.backgroundColor
            
            self.webView.loadRequest(URLRequest(url: URL(string: "https://meh.com/account/signin?returnurl=https%3A%2F%2Fmeh.com%2F%23checkout")!))
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

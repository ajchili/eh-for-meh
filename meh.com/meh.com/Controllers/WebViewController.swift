//
//  WebViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.loadRequest(URLRequest(url: URL(string: "https://meh.com/account/signin?returnurl=https%3A%2F%2Fmeh.com%2F%23checkout")!));
    }

}

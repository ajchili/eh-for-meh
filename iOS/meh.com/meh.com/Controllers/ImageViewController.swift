//
//  ImageViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import SDWebImage

class ImageViewController: UIViewController {
    
    @IBOutlet var webView: UIWebView!
    open var image: URL!
    var didLoad: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = nil
        
        webView!.layer.cornerRadius = 10.0
        webView!.layer.masksToBounds = true
        webView!.scalesPageToFit = true
        webView!.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (!didLoad) {
            didLoad = true
            webView!.loadRequest(URLRequest(url: image))
        }
    }
}

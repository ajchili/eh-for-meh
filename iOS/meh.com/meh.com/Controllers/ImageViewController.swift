//
//  ImageViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    open var image: URL!
    var didLoad: Bool = false
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = nil
        
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (!didLoad) {
            didLoad = true
            
            if (!self.image.absoluteString.contains("https")) {
                let s = self.image.absoluteString.replacingOccurrences(of: "http", with: "https")
                self.image = URL(string: s)
            }
            
            URLSession.shared.dataTask(with: image, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async {
                    if let image = UIImage(data: data!) {
                        self.imageView.image = image
                        self.loadingIndicator.stopAnimating()
                    }
                }
            }).resume()
        }
    }
}

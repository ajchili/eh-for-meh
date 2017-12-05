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
    
    open var image: URL!
    var didLoad: Bool = false
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = nil
        
        imageView!.layer.cornerRadius = 10.0
        imageView!.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (!didLoad) {
            didLoad = true
            URLSession.shared.dataTask(with: image, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async {
                    if let image = UIImage(data: data!) {
                        self.imageView.image = image
                    }
                }
                
            }).resume()
        }
    }
}

//
//  ImageViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let progressView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView()
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    open var image: URL!
    var didLoad: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
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
                        self.progressView.stopAnimating()
                    }
                }
            }).resume()
        }
    }
    
    private func setupView() {
        view.backgroundColor = nil
        
        view.addSubview(imageView)
        imageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(progressView)
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        progressView.startAnimating()
    }
}

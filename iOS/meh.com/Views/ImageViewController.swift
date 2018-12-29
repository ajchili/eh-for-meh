//
//  ImageViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import Nuke

class ImageViewController: UIViewController {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        downloadImage()
        
    }
    
    fileprivate func setupView() {
        view.backgroundColor = nil
        
        let padding: CGFloat = 20
        
        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: padding).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: padding).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -padding).isActive = true
        
        view.addSubview(progressView)
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        progressView.startAnimating()
    }
    
    fileprivate func downloadImage() {
        if !image.absoluteString.contains("https") {
            image = URL(string: image.absoluteString.replacingOccurrences(of: "http", with: "https"))
        }
        
        ImagePipeline.shared.loadImage(
            with: image,
            progress: { response, _, _ in
                self.imageView.image = response?.image
            },
            completion: { response, _ in
                self.progressView.stopAnimating()
                self.imageView.image = response?.image
            }
        )
    }
}

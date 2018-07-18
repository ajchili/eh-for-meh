//
//  TodayViewController.swift
//  Meh Deal
//
//  Created by Kirin Patel on 1/20/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import NotificationCenter
import Firebase

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var ref: DatabaseReference!
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let progressView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView()
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.numberOfLines = 2
        label.text = ""
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = ""
        return label
    }()
    
    let viewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Deal", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(handleView), for: .touchUpInside)
        return button
    }()
    
    let buyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Buy", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(handleBuy), for: .touchUpInside)
        return button
    }()
    
    private static var hasBeenConfigured: Bool = false
    private static var didLoad: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !TodayViewController.hasBeenConfigured {
            TodayViewController.hasBeenConfigured = true
            FirebaseApp.configure()
        }
        
        ref = Database.database().reference()
        
        setupView()
        pullDeal()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !TodayViewController.didLoad {
            pullDeal()
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        pullDeal()
        completionHandler(NCUpdateResult.newData)
    }
    
    @objc func handleView() {
        let url: URL? = URL(string: "meh:")!
        
        if let appurl = url {
            self.extensionContext!.open(appurl, completionHandler: nil)
        }
    }
    
    @objc func handleBuy() {
        self.extensionContext!.open(URL(string: "https://meh.com/account/signin?returnurl=https%3A%2F%2Fmeh.com%2F%23checkout")!, completionHandler: nil)
    }
    
    fileprivate func setupView() {
        // view.addSubview(imageView)
        // imageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 70, height: 70)
        
        // view.addSubview(progressView)
        // progressView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        // progressView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        // progressView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        // progressView.startAnimating()
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        view.addSubview(priceLabel)
        priceLabel.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(viewButton)
        viewButton.anchor(top: nil, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        viewButton.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor).isActive = true
    }
    
    fileprivate func pullDeal() {
        ref.child("info").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            TodayViewController.didLoad = false
            
            self.titleLabel.text = value?["title"] as? String ?? "Unable to load"
            self.titleLabel.sizeToFit()
            
            var min:Double = Double(Int.max)
            var max:Double = 0
            var itemCount = 0
            
            for child in snapshot.childSnapshot(forPath: "items").children.allObjects {
                let childSnapshot = child as! DataSnapshot
                
                itemCount += 1
                let price: Double = childSnapshot.childSnapshot(forPath: "price").value as! Double
                if price < min {
                    min = price
                } else if price > max {
                    max = price
                }
            }
            
            if max == 0 {
                max = min
            }
            
            if itemCount == 1 || min == max {
                self.priceLabel.text = "$\(min)"
            } else {
                self.priceLabel.text = "$\(min) - $\(max)"
            }
            self.priceLabel.sizeToFit()
            
            for child in snapshot.childSnapshot(forPath: "photos").children.allObjects {
                let childSnapshot = child as! DataSnapshot
                
                let url: String = childSnapshot.value as? String ?? ""
                
                if url.count != 0 {
                    // self.loadImage(url: URL(string: url)!)
                    return;
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    fileprivate func loadImage(url: URL) {
        TodayViewController.didLoad = true
        
        var image: URL = url
        
        if (!image.absoluteString.contains("https")) {
            let s = image.absoluteString.replacingOccurrences(of: "http", with: "https")
            image = URL(string: s)!
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
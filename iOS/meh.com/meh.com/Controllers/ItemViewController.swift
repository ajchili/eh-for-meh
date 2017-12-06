//
//  ItemViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ItemViewController: UIViewController, UIWebViewDelegate {
    var ref: DatabaseReference!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var imageView: UIView!
    @IBOutlet var pageController: UIPageControl!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mehButton: UIButton!
    @IBOutlet var effectView: UIVisualEffectView!
    @IBOutlet var webView: UIWebView!
    @IBOutlet var priceLabel: UILabel!
    var accentColor: UIColor?
    var backgroundColor: UIColor?
    var foreground: String?
    var priceRange: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        ref.child("info").observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            self.titleLabel.text = value?["title"] as? String ?? "Title"
            self.titleLabel.sizeToFit()
            self.descriptionLabel.text = value?["description"] as? String ?? "Description"
            self.descriptionLabel.sizeToFit()
            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.descriptionLabel.frame.height)
            
            var min = Int.max
            var max = 0
            var itemCount = 0
            
            for child in snapshot.childSnapshot(forPath: "items").children.allObjects {
                let childSnapshot = child as! DataSnapshot
                
                itemCount += 1
                let price: Int = childSnapshot.childSnapshot(forPath: "price").value as! Int
                if price < min {
                    min = price
                } else if price > max {
                    max = price
                }
            }
            
            if itemCount == 1 {
                self.priceLabel.text = "$\(min)"
            } else {
                self.priceLabel.text = "$\(min) - $\(max)"
            }
            self.priceLabel.sizeToFit()
            self.priceLabel.frame = CGRect(x: self.priceLabel.frame.origin.x, y: self.priceLabel.frame.origin.y, width: self.priceLabel.frame.width + 20, height: 30)
        }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("settings").observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            self.accentColor = UIColor.color(fromHexString: value?["accentColor"] as? String ?? "#ffffff")
            self.backgroundColor = UIColor.color(fromHexString: value?["backgroundColor"] as? String ?? "#000000")
            self.foreground = value?["backgroundColor"] as? String ?? "dark"
            
            self.setColor()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        webView.delegate = self
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if self.webView?.request?.url?.absoluteString.range(of: "/vote") != nil {
            self.webView?.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('form')[1].submit();")
        } else {
            self.effectView.isHidden = true
            self.mehButton.isHidden = true
            
            let alert = UIAlertController(title: "You have already voted", message: "We get it, it's meh, no need to tell us again.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func mehButtonTouchUpInside(_ sender: Any) {
        webView.loadRequest(URLRequest(url: URL(string: "https://meh.com")!))
        effectView.isHidden = false
    }
    
    @IBAction func closeButtonTouchUpInside(_ sender: Any) {
        effectView.isHidden = true
    }
    
    private func setColor() {
        view.layer.backgroundColor = backgroundColor!.cgColor
        titleLabel.textColor = accentColor
        descriptionLabel.textColor = accentColor
        pageController.currentPageIndicatorTintColor = accentColor
        webView.layer.cornerRadius = 5
        webView.layer.backgroundColor = backgroundColor!.cgColor
        webView.layer.masksToBounds = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.backgroundColor = accentColor
        priceLabel.layer.cornerRadius = 5
        priceLabel.layer.masksToBounds = true
        priceLabel.isHidden = false
        mehButton.backgroundColor = accentColor
        mehButton.layer.cornerRadius = 5
        mehButton.isHidden = false
    }

}


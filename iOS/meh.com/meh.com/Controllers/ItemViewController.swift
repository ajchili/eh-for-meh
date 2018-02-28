//
//  ItemViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SwiftyMarkdown

class ItemViewController: UIViewController, UIWebViewDelegate {
    
    var ref: DatabaseReference!
    let imagePageViewController: ImagePageViewController = {
        let ipvc = ImagePageViewController()
        return ipvc
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 30)
        return label
    }()
    
    let pageController: UIPageControl = {
        let pc = UIPageControl()
        return pc
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    let mehButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("meh", for: .normal)
        button.sizeToFit()
        button.isHidden = true
        button.addTarget(self, action: #selector(handleMeh), for: .touchUpInside)
        return button
    }()
    
    let descriptionView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        return tv
    }()
    
    let effectView: UIVisualEffectView = {
        let vev = UIVisualEffectView()
        vev.effect = UIBlurEffect(style: .light)
        return vev
    }()
    
    let webView: UIWebView = {
        let wb = UIWebView()
        wb.layer.cornerRadius = 5.0
        wb.layer.masksToBounds = true
        return wb
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return button
    }()

    var accentColor: UIColor?
    var backgroundColor: UIColor?
    var foreground: String?
    var priceRange: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        ref.child("settings").observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            self.accentColor = UIColor.color(fromHexString: value?["accentColor"] as? String ?? "#ffffff")
            self.backgroundColor = UIColor.color(fromHexString: value?["backgroundColor"] as? String ?? "#000000")
            self.foreground = value?["foreground"] as? String ?? "dark"
            
            self.prettyView()
            
            self.ref.child("info").observe(DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                self.mehButton.isHidden = false
                
                self.titleLabel.text = value?["title"] as? String ?? "Title"
                self.titleLabel.sizeToFit()
                let md = SwiftyMarkdown(string: value?["description"] as? String ?? "Description")
                md.body.color = self.accentColor!
                self.descriptionView.dataDetectorTypes = UIDataDetectorTypes.all
                self.descriptionView.attributedText = md.attributedString()
                self.descriptionView.scrollsToTop = true
                
                var min: Double = Double(Int.max)
                var max: Double = 0
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
                self.priceLabel.anchor(top: nil, left: self.imagePageViewController.view.leftAnchor, bottom: self.imagePageViewController.view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -10, paddingRight: 0, width: self.priceLabel.frame.width + 20, height: 0)
            }) { (error) in
                print(error.localizedDescription)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        setupView()
        
        webView.delegate = self
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let url: String? = self.webView.request?.url?.absoluteString
        if url != nil {
            if url! == "https://meh.com/" {
                self.webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('form')[1].submit();")
            } else if url!.range(of: "signin") != nil {
                self.effectView.isHidden = false
            } else if url!.range(of: "vote") != nil || url!.range(of: "deals") != nil {
                self.effectView.isHidden = true
                self.mehButton.isHidden = true
            }
        }
    }
    
    @objc func handleMeh() {
        webView.loadRequest(URLRequest(url: URL(string: "https://meh.com/")!))
    }
    
    @objc func handleClose() {
        effectView.isHidden = true
    }

    private func setupView() {
        addChildViewController(imagePageViewController)
        view.addSubview(imagePageViewController.view)
        imagePageViewController.didMove(toParentViewController: self)
        imagePageViewController.view.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: ((view.frame.width - 20) / 4) * 3)
        
        view.addSubview(pageController)
        pageController.anchor(top: imagePageViewController.view.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        pageController.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: pageController.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        view.addSubview(priceLabel)
        priceLabel.anchor(top: nil, left: imagePageViewController.view.leftAnchor, bottom: imagePageViewController.view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -10, paddingRight: 0, width: 0, height: 30)
        
        view.addSubview(mehButton)
        mehButton.anchor(top: nil, left: nil, bottom: imagePageViewController.view.bottomAnchor, right: imagePageViewController.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -10, paddingRight: 0, width: mehButton.frame.width + 20, height: 30)
        
        view.addSubview(descriptionView)
        descriptionView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: -10, paddingRight: 10, width: 0, height: 0)
        
        view.addSubview(effectView)
        effectView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        effectView.isHidden = true
        
        effectView.contentView.addSubview(closeButton)
        closeButton.anchor(top: effectView.topAnchor, left: effectView.leftAnchor, bottom: effectView.bottomAnchor, right: effectView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        effectView.contentView.addSubview(webView)
        webView.anchor(top: effectView.safeAreaLayoutGuide.topAnchor, left: effectView.leftAnchor, bottom: nil, right: effectView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: (view.frame.height / 4) * 3)
    }
    
    private func prettyView() {
        view.layer.backgroundColor = backgroundColor?.cgColor
        pageController.currentPageIndicatorTintColor = accentColor
        titleLabel.textColor = accentColor
        priceLabel.textColor = .white
        priceLabel.backgroundColor = accentColor
        priceLabel.layer.masksToBounds = true
        priceLabel.layer.cornerRadius = 5.0
        mehButton.setTitleColor(.white, for: .normal)
        mehButton.backgroundColor = accentColor
        mehButton.tintColor = accentColor
        mehButton.layer.masksToBounds = true
        mehButton.layer.cornerRadius = 5.0
        descriptionView.backgroundColor = backgroundColor
        descriptionView.textColor = accentColor
    }
}


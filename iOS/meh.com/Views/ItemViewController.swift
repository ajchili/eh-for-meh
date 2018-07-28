//
//  ItemViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseDatabase
import SwiftyMarkdown

protocol ItemViewPageControlDelegate: class {
    func itemCountChanged(_ count: Int)
    func itemIndexChanged(_ index: Int)
}

class ItemViewController: UIViewController {
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    let imagePageViewController = ImagePageViewController()
    
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.hidesForSinglePage = true
        pageControl.addTarget(self, action: #selector(handlePageChange), for: .touchUpInside)
        return pageControl
    }()
    
    let itemView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.alpha = 0
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        return label
    }()
    
    let descriptionView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.backgroundColor = .white
        tv.layer.cornerRadius = 6
        return tv
    }()
    
    let mehButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("meh", for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(handleMeh), for: .touchUpInside)
        return button
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 25
        return label
    }()
    
    let viewInFormButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("View Deal on Forum", for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(handleViewOnForm), for: .touchUpInside)
        return button
    }()
    
    let effectView: UIVisualEffectView = {
        let vev = UIVisualEffectView()
        vev.translatesAutoresizingMaskIntoConstraints = false
        vev.effect = UIBlurEffect(style: .light)
        vev.isHidden = true
        return vev
    }()
    
    let webView: UIWebView = {
        let wb = UIWebView()
        wb.translatesAutoresizingMaskIntoConstraints = false
        wb.layer.cornerRadius = 5.0
        wb.layer.masksToBounds = true
        return wb
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return button
    }()
    
    var itemPageViewDelegate: ItemPageViewDelegate!
    var forumPostURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        loadData()
        
        webView.delegate = self
    }
    
    @objc func handleMeh() {
        Analytics.logEvent("pressedMeh", parameters: [:])
        webView.loadRequest(URLRequest(url: URL(string: "https://meh.com/")!))
    }
    
    @objc func handleClose() {
        Analytics.logEvent("closeWebView", parameters: [:])
        effectView.isHidden = true
    }
    
    @objc func handlePageChange() {
        itemPageViewDelegate.setCurrentImage(pageControl.currentPage)
    }
    
    @objc func handleViewOnForm() {
        if forumPostURL != nil {
            UIApplication.shared.open(forumPostURL!, options: [:]) { _ in
                Analytics.logEvent("viewForm", parameters: [:])
            }
        }
    }

    private func setupView() {
        view.backgroundColor = .clear
        
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        scrollView.addSubview(itemView)
        itemView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20).isActive = true
        itemView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20).isActive = true
        itemView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        itemView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        imagePageViewController.itemViewPageControlDelegate = self
        itemPageViewDelegate = imagePageViewController.self
        itemView.addSubview(imagePageViewController.view)
        imagePageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        imagePageViewController.view.topAnchor.constraint(equalTo: itemView.topAnchor, constant: 10).isActive = true
        imagePageViewController.view.leftAnchor.constraint(equalTo: itemView.leftAnchor, constant: 0).isActive = true
        imagePageViewController.view.rightAnchor.constraint(equalTo: itemView.rightAnchor, constant: 0).isActive = true
        imagePageViewController.view.heightAnchor.constraint(equalToConstant: ((view.frame.width - 40) / 4) * 3).isActive = true
        
        itemView.addSubview(pageControl)
        pageControl.topAnchor.constraint(equalTo: imagePageViewController.view.bottomAnchor, constant: 10).isActive = true
        pageControl.leftAnchor.constraint(equalTo: itemView.leftAnchor, constant: 0).isActive = true
        pageControl.rightAnchor.constraint(equalTo: itemView.rightAnchor, constant: 0).isActive = true
        
        itemView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: itemView.leftAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: itemView.rightAnchor, constant: -10).isActive = true
        
        let buttonView = UIView()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.backgroundColor = .clear
        itemView.addSubview(buttonView)
        buttonView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        buttonView.leftAnchor.constraint(equalTo: itemView.leftAnchor, constant: 10).isActive = true
        buttonView.rightAnchor.constraint(equalTo: itemView.rightAnchor, constant: -10).isActive = true
        buttonView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        buttonView.addSubview(priceLabel)
        priceLabel.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 0).isActive = true
        priceLabel.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: 0).isActive = true
        priceLabel.leftAnchor.constraint(equalTo: buttonView.leftAnchor, constant: 0).isActive = true
        priceLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        buttonView.addSubview(mehButton)
        mehButton.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 0).isActive = true
        mehButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: 0).isActive = true
        mehButton.rightAnchor.constraint(equalTo: buttonView.rightAnchor, constant: 0).isActive = true
        mehButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        itemView.addSubview(descriptionView)
        descriptionView.topAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: 10).isActive = true
        descriptionView.leftAnchor.constraint(equalTo: itemView.leftAnchor, constant: 10).isActive = true
        descriptionView.rightAnchor.constraint(equalTo: itemView.rightAnchor, constant: -10).isActive = true
        descriptionView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        
        itemView.addSubview(viewInFormButton)
        viewInFormButton.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 10).isActive = true
        viewInFormButton.bottomAnchor.constraint(equalTo: itemView.bottomAnchor, constant: -10).isActive = true
        viewInFormButton.leftAnchor.constraint(equalTo: itemView.leftAnchor, constant: 10).isActive = true
        viewInFormButton.rightAnchor.constraint(equalTo: itemView.rightAnchor, constant: -10).isActive = true
        viewInFormButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        scrollView.bounds = view.bounds
        scrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
        
        view.addSubview(effectView)
        effectView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        effectView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        effectView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        effectView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        effectView.contentView.addSubview(closeButton)
        closeButton.topAnchor.constraint(equalTo: effectView.contentView.topAnchor, constant: 0).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: effectView.contentView.bottomAnchor, constant: 0).isActive = true
        closeButton.leftAnchor.constraint(equalTo: effectView.contentView.leftAnchor, constant: 0).isActive = true
        closeButton.rightAnchor.constraint(equalTo: effectView.contentView.rightAnchor, constant: 0).isActive = true
        
        effectView.contentView.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        webView.bottomAnchor.constraint(equalTo: effectView.contentView.bottomAnchor, constant: -30).isActive = true
        webView.leftAnchor.constraint(equalTo: effectView.contentView.leftAnchor, constant: 30).isActive = true
        webView.rightAnchor.constraint(equalTo: effectView.contentView.rightAnchor, constant: -30).isActive = true
    }
    
    fileprivate func loadData() {
        Database.database().reference().child("deal").observe(.value) { (snapshot) in
            if snapshot.exists() {
                Analytics.logEvent("loadDeal", parameters: [
                    "deal": snapshot.childSnapshot(forPath: "id").value as! String
                    ])
                
                let backgroundColor: UIColor = UIColor.color(fromHexString: snapshot.childSnapshot(forPath: "theme/backgroundColor").value as! String)
                let accentColor: UIColor = UIColor.color(fromHexString: snapshot.childSnapshot(forPath: "theme/accentColor").value as! String)
                
                // Item title
                self.titleLabel.text = snapshot.childSnapshot(forPath: "title").value as! String
                
                // Item description
                let md = SwiftyMarkdown(string: snapshot.childSnapshot(forPath: "features").value as! String)
                self.descriptionView.dataDetectorTypes = UIDataDetectorTypes.all
                self.descriptionView.attributedText = md.attributedString()
                self.descriptionView.scrollsToTop = true
                
                // Item price
                if snapshot.childSnapshot(forPath: "soldOutAt").exists() {
                    self.priceLabel.text = "SOLD OUT"
                    self.priceLabel.constraints.forEach {
                        (constraint) in
                        
                        if constraint.firstAttribute == .width {
                            constraint.constant = CGFloat(50 + self.priceLabel.text!.count * 6)
                        }
                    }
                } else {
                    self.calculatePrices(snapshot.childSnapshot(forPath: "items"))
                }
                
                // Form Post
                self.forumPostURL = URL(string: snapshot.childSnapshot(forPath: "topic/url").value as? String ?? "")
                
                // Set Theme color
                UIView.animate(withDuration: 0.5, animations: {
                    self.pageControl.pageIndicatorTintColor = accentColor
                    self.mehButton.backgroundColor = backgroundColor
                    self.mehButton.tintColor = accentColor
                    self.mehButton.setTitleColor(accentColor, for: .normal)
                    self.viewInFormButton.backgroundColor = backgroundColor
                    self.viewInFormButton.tintColor = accentColor
                    self.viewInFormButton.setTitleColor(accentColor, for: .normal)
                    self.priceLabel.backgroundColor = backgroundColor
                    self.priceLabel.textColor = accentColor
                    
                    if snapshot.childSnapshot(forPath: "theme/foreground").value as! String == "dark" {
                        self.itemView.backgroundColor = .black
                        self.pageControl.currentPageIndicatorTintColor = .white
                        self.titleLabel.textColor = .white
                    } else {
                        self.itemView.backgroundColor = .white
                        self.pageControl.currentPageIndicatorTintColor = .black
                        self.titleLabel.textColor = .black
                    }
                }, completion: { _ in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.itemView.alpha = 1
                    })
                })
            } else {
                let alert = UIAlertController(title: "Error Loading Deal", message: "Unable to load current meh deal.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alert.addAction(okAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func calculatePrices(_ snapshot: DataSnapshot) {
        var min: CGFloat = .infinity
        var max: CGFloat = 0
        
        for child in snapshot.children.allObjects {
            let childSnapshot = child as! DataSnapshot
            
            if let price = childSnapshot.childSnapshot(forPath: "price").value as? CGFloat {
                if price < min {
                    min = price
                    if max == 0 {
                        max = price
                    }
                } else if price > max {
                    max = price
                }
            }
        }
        
        var sMin: Any = min
        var sMax: Any = max
        
        if min.truncatingRemainder(dividingBy: 1.0) == 0 {
            sMin = String(format: "%g", min)
        }
        
        if max.truncatingRemainder(dividingBy: 1.0) == 0 {
            sMax = String(format: "%g", max)
        }
        
        if snapshot.childrenCount == 1 || min == max {
            self.priceLabel.text = "$\(sMin)"
        } else {
            self.priceLabel.text = "$\(sMin) - $\(sMax)"
        }
        
        self.priceLabel.constraints.forEach {
            (constraint) in
            
            if constraint.firstAttribute == .width {
                constraint.constant = CGFloat(50 + self.priceLabel.text!.count * 6)
            }
        }
    }
}

extension ItemViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let url: String? = webView.request?.url?.absoluteString
        if url != nil {
            if url! == "https://meh.com/" {
                webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('form')[1].submit();")
            } else if url!.range(of: "signin") != nil {
                let alert = UIAlertController(title: "Sign in Required", message: "You must be signed in to meh.com in order to rate this deal.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                    self.effectView.isHidden = false
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true, completion: nil)
            } else if url!.range(of: "vote") != nil || url!.range(of: "deals") != nil {
                Analytics.logEvent("meh", parameters: [:])
                self.effectView.isHidden = true
                self.mehButton.isHidden = true
            }
        }
    }
}

extension ItemViewController: ItemViewPageControlDelegate {
    
    func itemCountChanged(_ count: Int) {
        pageControl.numberOfPages = count
    }
    
    func itemIndexChanged(_ index: Int) {
        pageControl.currentPage = index
    }
}

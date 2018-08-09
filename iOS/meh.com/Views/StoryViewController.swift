//
//  StoryViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 8/1/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseDatabase
import SwiftyMarkdown

class StoryViewController: UIViewController {
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.backgroundColor = .clear
        scrollView.layer.cornerRadius = 6
        return scrollView
    }()
    
    let cardView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        return label
    }()
    
    let bodyView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .white
        tv.layer.cornerRadius = 6
        return tv
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("Back", for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return button
    }()
    
    var theme: Theme! {
        didSet {
            setTheme()
        }
    }
    
    var story: Story! {
        didSet {
            titleLabel.text = story.title
            let md = SwiftyMarkdown(string: story.body)
            bodyView.dataDetectorTypes = UIDataDetectorTypes.all
            bodyView.attributedText = md.attributedString()
            bodyView.sizeToFit()
            bodyView.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    @objc func handleClose() {
        Analytics.logEvent("closeStory", parameters: [:])
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupView() {
        view.addSubview(closeButton)
        closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        closeButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        closeButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -10).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        scrollView.addSubview(cardView)
        cardView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        cardView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
        cardView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 0).isActive = true
        cardView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 0).isActive = true
        
        cardView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10).isActive = true
        
        cardView.addSubview(bodyView)
        bodyView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        bodyView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 0).isActive = true
        bodyView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 0).isActive = true
        bodyView.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: 0).isActive = true
        
        scrollView.bounds = view.bounds
        scrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
        cardView.widthAnchor.constraint(equalToConstant: scrollView.bounds.width).isActive = true
    }
    
    fileprivate func setTheme() {
        view.backgroundColor = theme.backgroundColor
        cardView.backgroundColor = theme.dark ? .black : .white
        titleLabel.textColor = theme.dark ? .white : .black
        closeButton.backgroundColor = theme.accentColor
        closeButton.tintColor = theme.backgroundColor
        closeButton.setTitleColor(theme.backgroundColor, for: .normal)
    }
}

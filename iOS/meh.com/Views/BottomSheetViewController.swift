//
//  BottomSheetViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 9/23/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import SwiftyMarkdown

class BottomSheetViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var deal: Deal? {
        didSet {
            animateView()
        }
    }
    
    let cornerRadius: CGFloat = 20
    let maximumY = CGFloat(100)
    let minimumY = UIScreen.main.bounds.height - 100
    let yCuttoff = UIScreen.main.bounds.height / 2
    
    let pullTab: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Deal Information"
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 36, weight: .medium)
        return label
    }()
    
    let segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl()
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.insertSegment(withTitle: "Features", at: 0, animated: true)
        segmentControl.insertSegment(withTitle: "Spec", at: 1, animated: true)
        segmentControl.insertSegment(withTitle: "Story", at: 2, animated: true)
        segmentControl.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        return segmentControl
    }()
    
    let featureScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    let specsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.backgroundColor = .clear
        scrollView.isHidden = true
        return scrollView
    }()
    
    let specTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    let storyScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.backgroundColor = .clear
        scrollView.isHidden = true
        return scrollView
    }()
    
    let storyTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 36, weight: .medium)
        return label
    }()
    
    let storyTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundCorners()
        setupView()
        setupGestureListener()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateView()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y
        
        let y = view.frame.minY
        var offset = featureScrollView.contentOffset.y
        if segmentControl.selectedSegmentIndex == 1 {
            offset = specsScrollView.contentOffset.y
        } else if segmentControl.selectedSegmentIndex == 2 {
            offset = storyScrollView.contentOffset.y
        }
        
        if (y == maximumY && offset == 0 && direction > 0) || (y == minimumY) {
            featureScrollView.isScrollEnabled = false
            specsScrollView.isScrollEnabled = false
            storyScrollView.isScrollEnabled = false
        } else {
            featureScrollView.isScrollEnabled = true
            specsScrollView.isScrollEnabled = true
            storyScrollView.isScrollEnabled = true
        }
        
        return false
    }
    
    @objc func panGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let y = self.view.frame.minY
        let yPosition = y + translation.y
        if recognizer.state == .ended || recognizer.state == .cancelled {
            UIView.animate(withDuration: 0.15, animations: {
                self.view.frame = CGRect(origin: CGPoint(x: 0, y: yPosition > self.yCuttoff ? self.minimumY : self.maximumY),
                                         size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
            })
        } else {
            self.view.frame = CGRect(origin: CGPoint(x: 0, y: yPosition < maximumY ? maximumY : yPosition > minimumY ? minimumY : yPosition),
                                     size: CGSize(width: view.frame.width, height: view.frame.height))
            recognizer.setTranslation(.zero, in: view)
        }
    }
    
    @objc func handleSegmentChange() {
        switch self.segmentControl.selectedSegmentIndex {
        case 1:
            self.featureScrollView.isHidden = true;
            self.specsScrollView.isHidden = false;
            self.storyScrollView.isHidden = true;
            break;
        case 2:
            self.featureScrollView.isHidden = true;
            self.specsScrollView.isHidden = true;
            self.storyScrollView.isHidden = false;
            break;
        default:
            self.featureScrollView.isHidden = false;
            self.specsScrollView.isHidden = true;
            self.storyScrollView.isHidden = true;
            break;
        }
    }
    
    fileprivate func animateView() {
        if let deal = deal {
            let textColor: UIColor = deal.theme.dark ? .white : .black
            setupDeal()
            UIView.animate(withDuration: 0.15, animations: {
                self.view.frame = CGRect(origin: CGPoint(x: 0, y: self.minimumY),
                                         size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
                self.view.backgroundColor = deal.theme.accentColor
                self.pullTab.backgroundColor = deal.theme.backgroundColor
                self.segmentControl.tintColor = deal.theme.backgroundColor
                self.segmentControl.selectedSegmentIndex = 0
                self.titleLabel.textColor = textColor
                self.descriptionTextView.textColor = textColor
                self.descriptionTextView.tintColor = deal.theme.backgroundColor
                self.specTextView.textColor = textColor
                self.specTextView.tintColor = deal.theme.backgroundColor
                self.storyTitleLabel.textColor = textColor
                self.storyTextView.textColor = textColor
                self.storyTextView.tintColor = deal.theme.backgroundColor
            })
        }
    }
    
    fileprivate func roundCorners() {
        let shape = CAShapeLayer()
        shape.bounds = view.frame
        shape.position = view.center
        shape.path = UIBezierPath(roundedRect: view.bounds,
                                  byRoundingCorners: [.topLeft, .topRight],
                                  cornerRadii: CGSize(width: cornerRadius,height: cornerRadius)).cgPath
        view.layer.mask = shape
    }
    
    fileprivate func setupGestureListener() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    fileprivate func setupView() {
        view.addSubview(pullTab)
        pullTab.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        pullTab.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        pullTab.widthAnchor.constraint(equalToConstant: 40).isActive = true
        pullTab.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: pullTab.bottomAnchor, constant: 15).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        view.addSubview(segmentControl)
        segmentControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 27).isActive = true
        segmentControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        segmentControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        view.addSubview(featureScrollView)
        featureScrollView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10).isActive = true
        featureScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150).isActive = true
        featureScrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        featureScrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        featureScrollView.addSubview(descriptionTextView)
        descriptionTextView.topAnchor.constraint(equalTo: featureScrollView.topAnchor, constant: 0).isActive = true
        descriptionTextView.bottomAnchor.constraint(equalTo: featureScrollView.bottomAnchor, constant: 0).isActive = true
        descriptionTextView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        descriptionTextView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        featureScrollView.bounds = view.bounds
        featureScrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
        
        view.addSubview(specsScrollView)
        specsScrollView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10).isActive = true
        specsScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150).isActive = true
        specsScrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        specsScrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        specsScrollView.addSubview(specTextView)
        specTextView.topAnchor.constraint(equalTo: specsScrollView.topAnchor, constant: 0).isActive = true
        specTextView.bottomAnchor.constraint(equalTo: specsScrollView.bottomAnchor, constant: 0).isActive = true
        specTextView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        specTextView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        specsScrollView.bounds = view.bounds
        specsScrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
        
        view.addSubview(storyScrollView)
        storyScrollView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10).isActive = true
        storyScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150).isActive = true
        storyScrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        storyScrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        storyScrollView.addSubview(storyTitleLabel)
        storyTitleLabel.topAnchor.constraint(equalTo: storyScrollView.topAnchor, constant: 0).isActive = true
        storyTitleLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        storyTitleLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        storyScrollView.addSubview(storyTextView)
        storyTextView.topAnchor.constraint(equalTo: storyTitleLabel.bottomAnchor, constant: 0).isActive = true
        storyTextView.bottomAnchor.constraint(equalTo: storyScrollView.bottomAnchor, constant: 0).isActive = true
        storyTextView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        storyTextView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        storyScrollView.bounds = view.bounds
        storyScrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
    }
    
    fileprivate func setupDeal() {
        if let deal = deal {
            let descriptionMD = SwiftyMarkdown(string: deal.features)
            descriptionTextView.dataDetectorTypes = UIDataDetectorTypes.all
            descriptionTextView.attributedText = descriptionMD.attributedString()
            descriptionTextView.sizeToFit()
            descriptionTextView.layoutIfNeeded()
            
            let specMD = SwiftyMarkdown(string: deal.specifications.replacingOccurrences(of: "\\", with: ""))
            specTextView.dataDetectorTypes = UIDataDetectorTypes.all
            specTextView.attributedText = specMD.attributedString()
            specTextView.sizeToFit()
            specTextView.layoutIfNeeded()
            
            storyTitleLabel.text = deal.story.title
            
            let storyMD = SwiftyMarkdown(string: deal.story.body)
            storyTextView.dataDetectorTypes = UIDataDetectorTypes.all
            storyTextView.attributedText = storyMD.attributedString()
            storyTextView.sizeToFit()
            storyTextView.layoutIfNeeded()
        }
    }
}

//
//  BottomSheetViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 9/23/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class BottomSheetViewController: UIViewController {
    
    var deal: Deal! {
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
        return label
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
    
    fileprivate func animateView() {
        UIView.animate(withDuration: 0.15, animations: {
            self.view.frame = CGRect(origin: CGPoint(x: 0, y: self.minimumY),
                                     size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
            self.view.backgroundColor = self.deal.theme.accentColor
            self.pullTab.backgroundColor = self.deal.theme.backgroundColor
        })
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
        view.addGestureRecognizer(gesture)
    }
    
    fileprivate func setupView() {
        view.addSubview(pullTab)
        pullTab.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        pullTab.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        pullTab.widthAnchor.constraint(equalToConstant: 40).isActive = true
        pullTab.heightAnchor.constraint(equalToConstant: 5).isActive = true
    }
}

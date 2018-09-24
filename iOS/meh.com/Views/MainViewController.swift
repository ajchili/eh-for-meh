//
//  MainViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 7/17/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MainViewController: UIViewController {
    
    var hasAddedBottomSheet: Bool = false
    var deal: Deal? {
        didSet {
            if let deal = deal {
                dealView.deal = deal
                bottomSheet.deal = deal
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.backgroundColor = deal.theme.backgroundColor
                })
            }
        }
    }
    
    let bottomSheet = BottomSheetViewController()
    let dealView = DealViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDealView()
        addBottomSheet()
        
        if deal == nil {
            setupDealObserver()
        }
    }
    
    fileprivate func setupDealObserver() {
        DealLoader.sharedInstance.loadCurrentDeal(completion: { deal in
            self.deal = deal
        })
    }
    
    fileprivate func addBottomSheet() {
        if hasAddedBottomSheet { return }
        
        addChildViewController(bottomSheet)
        view.addSubview(bottomSheet.view)
        bottomSheet.didMove(toParentViewController: self)
        bottomSheet.view.frame = CGRect(origin: CGPoint(x: 0, y: view.frame.maxY),
                                        size: CGSize(width: view.frame.width, height: view.frame.height))
    }
    
    fileprivate func setupDealView() {
        addChildViewController(dealView)
        view.addSubview(dealView.view)
        dealView.didMove(toParentViewController: self)
        dealView.view.frame = CGRect(origin: CGPoint(x: 0, y: 0),
                                     size: CGSize(width: view.frame.width, height: view.frame.height - 100))
    }
}

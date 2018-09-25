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
                    self.optionsStackView.backgroundColor = deal.theme.dark ? .white : .black
                    self.settingsButton.alpha = 1
                    self.settingsButton.tintColor = deal.theme.accentColor
                    self.historyButton.alpha = 1
                    self.historyButton.tintColor = deal.theme.accentColor
                })
            }
        }
    }
    
    let bottomSheet = BottomSheetViewController()
    let dealView = DealViewController()
    
    let optionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    let settingsButton: UIButton = {
        let button = UIButton(type: .infoLight)
        button.alpha = 0
        return button
    }()
    
    let historyButton: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0
        button.setTitle("History", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .light)
        button.addTarget(self, action: #selector(handleViewHistory), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDealView()
        addBottomSheet()
        setupView()
        
        if deal == nil {
            setupDealObserver()
        }
    }
    
    @objc func handleViewHistory() {
        if let deal = deal {
            let historyView = HistoryNavigationViewController()
            
            historyView.view.backgroundColor = deal.theme.backgroundColor
            
            historyView.modalPresentationStyle = .fullScreen
            historyView.modalTransitionStyle = .flipHorizontal
            
            present(historyView, animated: true)
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
    
    fileprivate func setupView() {
        view.addSubview(optionsStackView)
        optionsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        optionsStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        optionsStackView.addArrangedSubview(settingsButton)
        if deal == nil {
            optionsStackView.addArrangedSubview(historyButton)
        }
    }
}

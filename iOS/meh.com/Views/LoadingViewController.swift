//
//  File.swift
//  meh.com
//
//  Created by Kirin Patel on 7/21/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class LoadingViewController: UIViewController {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "eh for meh"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupView()
        loadTheme()
    }
    
    fileprivate func setupView() {
        view.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    fileprivate func loadTheme() {
        Database.database().reference().child("deal/theme").observeSingleEvent(of: .value) { snapshot in
            let mainViewController = MainViewController()
            mainViewController.backgroundColor = UIColor.color(fromHexString: snapshot.childSnapshot(forPath: "backgroundColor").value as? String ?? "#ffffff")
            mainViewController.accentColor = UIColor.color(fromHexString: snapshot.childSnapshot(forPath: "accentColor").value as? String ?? "#000000")
            mainViewController.isDark = snapshot.childSnapshot(forPath: "foreground").value as? String ?? "dark" == "dark"

            mainViewController.modalPresentationStyle = .fullScreen
            mainViewController.modalTransitionStyle = .crossDissolve
            
            self.present(mainViewController, animated: true, completion: nil)
        }
    }
}

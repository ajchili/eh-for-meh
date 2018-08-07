//
//  SettingsViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/5/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseMessaging

class SettingsViewController: UIViewController {
    
    let settingsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Receive notifications of new deals?"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let affiliateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "This app is not affiliated with meh.com and is created by a member of the Meh community. Any issues with this app should be reported to the developer (Kirin Patel), not to Meh."
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let iconLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Icons obtained from icons8.com"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let notificationSwitch: UISwitch = {
        let s = UISwitch()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.addTarget(self, action: #selector(handleSwitch), for: .valueChanged)
        return s
    }()
    
    var theme: Theme! {
        didSet {
            setTheme()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        view.addSubview(notificationSwitch)
        notificationSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        notificationSwitch.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(settingsLabel)
        settingsLabel.bottomAnchor.constraint(equalTo: notificationSwitch.topAnchor, constant: -8).isActive = true
        settingsLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        settingsLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        
        view.addSubview(affiliateLabel)
        affiliateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        affiliateLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        affiliateLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        
        view.addSubview(iconLabel)
        iconLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        iconLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        iconLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fmcToken = Messaging.messaging().fcmToken!
        Database.database().reference().child("notifications/\(fmcToken)").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                self.notificationSwitch.isOn = snapshot.value as? Bool ?? false
            }
        })
    }

    @objc func handleSwitch() {
        Analytics.logEvent("setNotifications", parameters: [
            "recieveNotifications": notificationSwitch.isOn
            ])
        Database.database().reference().child("notifications\(Messaging.messaging().fcmToken!)").setValue(notificationSwitch.isOn ? true : nil)
    }
    
    fileprivate func setTheme() {
        UIView.animate(withDuration: 0.5) {
            self.notificationSwitch.tintColor = self.theme.accentColor
            self.notificationSwitch.onTintColor = self.theme.accentColor
            self.settingsLabel.textColor = self.theme.accentColor
            self.affiliateLabel.textColor = self.theme.accentColor
            self.iconLabel.textColor = self.theme.accentColor
        }
    }
}

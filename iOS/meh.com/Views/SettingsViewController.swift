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
        label.text = "Receive notifications of new deals?"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let affiliateLabel: UILabel = {
        let label = UILabel()
        label.text = "This app is not affiliated with meh.com and is created by a member of the Meh community. Any issues with this app should be reported to the developer (Kirin Patel), not to Meh."
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let iconLabel: UILabel = {
        let label = UILabel()
        label.text = "Icons obtained from icons8.com"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let notificationSwitch: UISwitch = {
        let s = UISwitch()
        s.addTarget(self, action: #selector(handleSwitch), for: .valueChanged)
        return s
    }()
    
    var accentColor: UIColor! {
        didSet {
            setTheme()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        view.addSubview(notificationSwitch)
        notificationSwitch.center = view.center
        
        view.addSubview(settingsLabel)
        settingsLabel.anchor(top: nil, left: view.leftAnchor, bottom: notificationSwitch.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: -10, paddingRight: 10, width: 0, height: 0)
        
        view.addSubview(affiliateLabel)
        affiliateLabel.anchor(top: notificationSwitch.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        view.addSubview(iconLabel)
        iconLabel.anchor(top: affiliateLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
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
            self.notificationSwitch.tintColor = self.accentColor
            self.notificationSwitch.onTintColor = self.accentColor
            self.settingsLabel.textColor = self.accentColor
            self.affiliateLabel.textColor = self.accentColor
            self.iconLabel.textColor = self.accentColor
        }
    }
}

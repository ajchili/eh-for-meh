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
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        ref = Database.database().reference()
        
        view.addSubview(notificationSwitch)
        notificationSwitch.center = view.center
        
        view.addSubview(settingsLabel)
        settingsLabel.anchor(top: nil, left: view.leftAnchor, bottom: notificationSwitch.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: -10, paddingRight: 10, width: 0, height: 0)
        
        view.addSubview(affiliateLabel)
        affiliateLabel.anchor(top: notificationSwitch.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        view.addSubview(iconLabel)
        iconLabel.anchor(top: affiliateLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        ref.child("notifications").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let fmcToken = Messaging.messaging().fcmToken!
            
            if snapshot.hasChild(fmcToken) {
                self.notificationSwitch.isOn = value?[fmcToken] as? Bool ?? false
            } else {
                self.ref.child("notifications").child(fmcToken).setValue(false)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("deal/theme").observe(DataEventType.value, with: { (snapshot) in
            let accentColor = UIColor.color(fromHexString: snapshot.childSnapshot(forPath: "accentColor").value as? String ?? "#000000")
            
            self.notificationSwitch.tintColor = accentColor
            self.notificationSwitch.onTintColor = accentColor
            self.settingsLabel.textColor = accentColor
            self.affiliateLabel.textColor = accentColor
            self.iconLabel.textColor = accentColor
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    @objc func handleSwitch() {
        Analytics.logEvent("setNotifications", parameters: [
            "recieveNotifications": notificationSwitch.isOn
            ])
        ref.child("notifications").child(Messaging.messaging().fcmToken!).setValue(notificationSwitch.isOn)
    }
}

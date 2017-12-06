//
//  SettingsViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/5/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseMessaging

class SettingsViewController: UIViewController {
    
    var ref: DatabaseReference!
    @IBOutlet var settingsLabel: UILabel!
    @IBOutlet var notificationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
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
        
        ref.child("settings").observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let accentColor = UIColor.color(fromHexString: value?["accentColor"] as? String ?? "#000000")
            self.settingsLabel.textColor = accentColor
            self.notificationSwitch.tintColor = accentColor
            self.notificationSwitch.onTintColor = accentColor
            self.view.backgroundColor = UIColor.color(fromHexString: value?["backgroundColor"] as? String ?? "#000000")
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    @IBAction func notificationSwitchValueChanged(_ sender: Any) {
        ref.child("notifications").child(Messaging.messaging().fcmToken!).setValue(notificationSwitch.isOn)
    }
}

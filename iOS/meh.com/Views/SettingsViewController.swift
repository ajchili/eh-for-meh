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
import UserNotifications

class SettingsViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    let effectView: UIVisualEffectView = {
        let vev = UIVisualEffectView()
        vev.translatesAutoresizingMaskIntoConstraints = false
        vev.effect = UIBlurEffect(style: .light)
        return vev
    }()
    
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
    
    let notificationSwitch: UISwitch = {
        let s = UISwitch()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.addTarget(self, action: #selector(handleSwitch), for: .valueChanged)
        return s
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitle("Save", for: .normal)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    var theme: Theme! {
        didSet {
            setTheme()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        view.addSubview(effectView)
        effectView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        effectView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        effectView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        effectView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        view.addSubview(notificationSwitch)
        notificationSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        notificationSwitch.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        notificationSwitch.isOn = UserDefaults.standard.bool(forKey: "receiveNotifications")
        
        view.addSubview(settingsLabel)
        settingsLabel.bottomAnchor.constraint(equalTo: notificationSwitch.topAnchor, constant: -8).isActive = true
        settingsLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        settingsLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        
        view.addSubview(affiliateLabel)
        affiliateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        affiliateLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        affiliateLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        
        view.addSubview(saveButton)
        saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        saveButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        saveButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fmcToken = Messaging.messaging().fcmToken!
        Database.database().reference().child("notifications/\(fmcToken)").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                if let receiveNotifications = snapshot.value as? Bool {
                    if self.notificationSwitch.isOn != receiveNotifications {
                        self.displayDatabaseErrorAlert(receiveNotifications: receiveNotifications)
                    }
                }
            }
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let theme = theme {
            return theme.dark ? .lightContent : .default
        }
        
        return .default
    }

    @objc func handleSwitch() {
        Analytics.logEvent("setNotifications", parameters: [
            "recieveNotifications": notificationSwitch.isOn
            ])
        
        if (notificationSwitch.isOn) {
            setupFMC()
        } else {
            UserDefaults.standard.set(false, forKey: "receiveNotifications")
            Database.database().reference().child("notifications/\(Messaging.messaging().fcmToken!)").removeValue()
        }
    }
    
    @objc func handleSave() {
        dismiss(animated: true)
    }
    
    fileprivate func setTheme() {
        notificationSwitch.tintColor = theme.accentColor
        notificationSwitch.onTintColor = theme.backgroundColor
        saveButton.backgroundColor = theme.backgroundColor
        saveButton.tintColor = theme.accentColor
        saveButton.setTitleColor(theme.accentColor, for: .normal)
    }
    
    fileprivate func displayDatabaseErrorAlert(receiveNotifications: Bool) {
        let alert = UIAlertController(title: "Notification Settings Error", message: "Your notifications are \(receiveNotifications ? "not" : "") enabled in the app but are in our database. Would you still like to recieve notifications?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
            Analytics.logEvent("setNotifications", parameters: [
                "recieveNotifications": true,
                "error": "Was not set in database."
                ])
            self.setupFMC()
        })
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: { _ in
            Analytics.logEvent("setNotifications", parameters: [
                "recieveNotifications": false,
                "error": "Was not set in database."
                ])
            UserDefaults.standard.set(false, forKey: "receiveNotifications")
            Database.database().reference().child("notifications/\(Messaging.messaging().fcmToken!)").removeValue()
            self.notificationSwitch.isOn = false
        })
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }
    
    fileprivate func setupFMC() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
            if granted {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                    UserDefaults.standard.set(true, forKey: "receiveNotifications")
                    Database.database().reference().child("notifications/\(Messaging.messaging().fcmToken!)").setValue(true)
                    self.notificationSwitch.isOn = true
                })
            } else {
                DispatchQueue.main.async(execute: {
                    UserDefaults.standard.set(false, forKey: "receiveNotifications")
                    Database.database().reference().child("notifications/\(Messaging.messaging().fcmToken!)").removeValue()
                    self.notificationSwitch.isOn = false
                    
                    let alert = UIAlertController(title: "Notification Settings Error", message: "Notification permissions are required to receive notifications when new deals start. You can enable this in settings.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                    })
                    self.present(alert, animated: true)
                })
            }
        })
    }
}

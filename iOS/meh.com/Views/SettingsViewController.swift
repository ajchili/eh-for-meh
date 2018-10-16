//
//  SettingsViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/5/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import CTFeedback
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseMessaging
import QuickTableViewController
import UserNotifications

class SettingsViewController: QuickTableViewController, UNUserNotificationCenterDelegate {
    
    var notificationSwitch: SwitchRow<SwitchCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        let backButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(handleBack))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = backButton
        
        notificationSwitch =  SwitchRow(title: "Receive Notifications",
                                        switchValue: UserDefaults.standard.bool(forKey: "receiveNotifications"),
                                        action: didToggleSelection())
        
        tableContents = [
            Section(title: "Notifications",
                    rows: [ notificationSwitch ]),
            Section(title: "Deal History",
                    rows: [
                        SwitchRow(title: "Load images",
                                  switchValue: UserDefaults.standard.bool(forKey: "loadHistoryImages"),
                                  action: didToggleSelection()),
//                        NavigationRow(title: "Amount of previous deals", subtitle: .belowTitle("Choose how many deals to load"), action: nil),
                        ],
                    footer: "Please note, loading images has significantly high network usage and should not be used by users with limited data/bandwidth cellular plans."),
            Section(title: "Feedback",
                    rows: [
                        NavigationRow(title: "Provide feedback",
                                      subtitle: .belowTitle("Help improve the app"),
                                      action: { _ in self.loadFeedback() }),
                        ],
                    footer: "Any feedback submitted is completely anonymous and will be used to improve the app."),
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let fmcToken = Messaging.messaging().fcmToken!
        Database.database().reference().child("notifications/\(fmcToken)").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                if let receiveNotifications = snapshot.value as? Bool {
                    if UserDefaults.standard.bool(forKey: "receiveNotifications") != receiveNotifications {
                        self.displayDatabaseErrorAlert(receiveNotifications: receiveNotifications)
                    }
                }
            }
        })
    }
    
    @objc func handleBack() {
        dismiss(animated: true)
    }
    
    fileprivate func didToggleSelection() -> (Row) -> Void {
        return { [self] in
            if let option = $0 as? SwitchRowCompatible {
                switch option.title {
                case "Receive Notifications":
                    self.setNotificationsEnabled(enabled: option.switchValue)
                    break;
                case "Load images":
                    UserDefaults.standard.set(option.switchValue, forKey: "loadHistoryImages")
                    break;
                default:
                    break;
                }
            }
        }
    }
    
    fileprivate func setNotificationsEnabled(enabled: Bool) {
        Analytics.logEvent("setNotifications", parameters: [
            "recieveNotifications": enabled
            ])
        
        if enabled {
            setupFMC()
        } else {
            UserDefaults.standard.set(false, forKey: "receiveNotifications")
            Database.database().reference().child("notifications/\(Messaging.messaging().fcmToken!)").removeValue()
        }
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
        })

        alert.addAction(yesAction)
        alert.addAction(noAction)

        present(alert, animated: true)
    }
    
    fileprivate func setupFMC() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
            if error == nil {
                if granted {
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.registerForRemoteNotifications()
                        UserDefaults.standard.set(true, forKey: "receiveNotifications")
                        Database.database().reference().child("notifications/\(Messaging.messaging().fcmToken!)").setValue(true)
                        self.notificationSwitch.switchValue = true
                    })
                } else {
                    UserDefaults.standard.set(false, forKey: "receiveNotifications")
                    Database.database().reference().child("notifications/\(Messaging.messaging().fcmToken!)").removeValue()
                    DispatchQueue.main.async(execute: {
                        self.notificationSwitch.switchValue = false
                        
                        let alert = UIAlertController(title: "Notification Settings Error", message: "Notification permissions are required to receive notifications when new deals start. You can enable this in settings.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                        })
                        self.present(alert, animated: true)
                    })
                }
            } else {
                UserDefaults.standard.set(false, forKey: "receiveNotifications")
                Database.database().reference().child("notifications/\(Messaging.messaging().fcmToken!)").removeValue()
                DispatchQueue.main.async(execute: {
                    self.notificationSwitch.switchValue = false
                    
                    let alert = UIAlertController(title: "Notification Settings Error", message: "Notification were unable to be enabled.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    alert.addAction(UIAlertAction(title: "Okay", style: .default))
                    self.present(alert, animated: true)
                })
            }
        })
    }
    
    fileprivate func loadFeedback() {
        let feedbackView = CTFeedbackViewController()
        feedbackView.useHTML = false
        feedbackView.hidesTopicCell = true
        feedbackView.useCustomCallback = true
        feedbackView.delegate = self
        feedbackView.hidesAppNameCell = true
        navigationController?.pushViewController(feedbackView, animated: true)
    }
}

extension SettingsViewController: CTFeedbackViewControllerDelegate {
    
    func feedbackViewController(_ controller: CTFeedbackViewController!, didFinishWithCustomCallback email: String!, topic: String!, content: String!, attachment: UIImage!) {
        if let content = content {
            let key = Database.database().reference().child("feedback").childByAutoId().key
            Database.database().reference().child("feedback/\(key)").setValue([
                "time": NSDate().timeIntervalSince1970 * 1000,
                "email": email,
                "topic": "Feedback",
                "content": content,
                "hasAttachments": attachment != nil,
                "appBuild": controller.appBuild,
                "appVersion": controller.appVersion,
                "systemVersion": controller.systemVersion,
                "platformString": controller.platformString
                ],withCompletionBlock: { (error, _) in
                    if let error = error {
                        let alert = UIAlertController(title: "Error Submitting Feedback", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default))
                        self.present(alert, animated: true)
                    } else {
                        let alert = UIAlertController(title: "Thnak you for the Feedback", message: "Your message will be reviewed and addressed asap.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default) { _ in
                            self.navigationController?.popViewController(animated: true)
                        })
                        self.present(alert, animated: true)
                    }
            })
        } else {
            let alert = UIAlertController(title: "Unable to Submit Feedback", message: "A message must be provided to submit feedback.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            self.present(alert, animated: true)
        }
    }
}

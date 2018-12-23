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
import GoogleMobileAds
import QuickTableViewController
import UserNotifications

class SettingsViewController: QuickTableViewController, UNUserNotificationCenterDelegate {
    
    var notificationSwitch: SwitchRow<SwitchCell>!
    var radios: RadioSection!
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        let backButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(handleBack))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = backButton
        
        notificationSwitch =  SwitchRow(title: "Receive Notifications",
                                        switchValue: UserDefaults.standard.bool(forKey: "receiveNotifications"),
                                        action: didToggleSelection())
        
        interstitial = loadInterstitial()
        
        if let dealHistoryCount: Int = UserDefaults.standard.object(forKey: "dealHistoryCount") as? Int {
            radios = RadioSection(title: "",
                                  options: [
                                    OptionRow(title: "5 Deals", isSelected: dealHistoryCount == 5, action: didToggleOption()),
                                    OptionRow(title: "10 Deals", isSelected: dealHistoryCount == 10, action: didToggleOption()),
                                    OptionRow(title: "20 Deals", isSelected: dealHistoryCount == 20, action: didToggleOption()),
                                    OptionRow(title: "50 Deals", isSelected: dealHistoryCount == 50, action: didToggleOption())
                ],
                                  footer: "Number of deals to display in history screen. Please note that the more deals you load, the more data/bandwidh will be used.")
        } else {
            radios = RadioSection(title: "",
                                  options: [
                                    OptionRow(title: "5 Deals", isSelected: false, action: didToggleOption()),
                                    OptionRow(title: "10 Deals", isSelected: false, action: didToggleOption()),
                                    OptionRow(title: "20 Deals", isSelected: UIDevice.current.userInterfaceIdiom != .pad, action: didToggleOption()),
                                    OptionRow(title: "50 Deals", isSelected: UIDevice.current.userInterfaceIdiom == .pad, action: didToggleOption())
                ],
                                  footer: "Number of deals to display in history screen. Please note that the more deals you load, the more data/bandwidh will be used.")
        }
        
        radios.alwaysSelectsOneOption = true
        
        tableContents = [
            Section(title: "Notifications",
                    rows: [ notificationSwitch ]),
            Section(title: "Deal History",
                    rows: [
                        SwitchRow(title: "Load images",
                                  switchValue: UserDefaults.standard.bool(forKey: "loadHistoryImages"),
                                  action: didToggleSelection()),
                        ],
                    footer: "Please note, loading images has significantly high network usage and should not be used by users with limited data/bandwidth cellular plans."),
            radios,
            Section(title: "Feedback",
                    rows: [
                        NavigationRow(title: "Provide feedback",
                                      subtitle: .belowTitle("Help improve the app"),
                                      action: { _ in self.loadFeedback() }),
                        ],
                    footer: "Any feedback submitted is completely anonymous and will be used to improve the app."),
            Section(title: "Support the Developer",
                    rows: [
                        NavigationRow(title: "Watch Ad",
                                      subtitle: .belowTitle(""),
                                      action: { _ in self.displayAd() }),
                        ],
                    footer: "Watch an ad that helps the developer cover development (Kirin Patel) costs and time. This is no required and is only somethinf that should be done by users who are willing to watch ads to support the developer (Kirin Patel).")
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
    
    private func didToggleOption() -> (Row) -> Void {
        return { row in
            switch row.title.split(separator: " ")[0] {
            case "5":
                UserDefaults.standard.set(5, forKey: "dealHistoryCount")
                break;
            case "10":
                UserDefaults.standard.set(10, forKey: "dealHistoryCount")
                break;
            case "50":
                UserDefaults.standard.set(50, forKey: "dealHistoryCount")
                break;
            default:
                UserDefaults.standard.set(20, forKey: "dealHistoryCount")
                break;
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
        feedbackView.hidesAdditionalContent = true
        feedbackView.hidesTopicCell = true
        feedbackView.useCustomCallback = true
        feedbackView.delegate = self
        feedbackView.hidesAppNameCell = true
        navigationController?.pushViewController(feedbackView, animated: true)
    }
    
    fileprivate func loadInterstitial() -> GADInterstitial {
        Analytics.logEvent("loaded_ad", parameters: [
            "type":"interstitial",
            "location":"SettingsViewController"
            ])
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-9026572937829340/2237689912")
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
        return interstitial
    }
    
    fileprivate func displayAd() {
        if interstitial.isReady {
            Analytics.logEvent("viewed_ad", parameters: [
                "type":"interstitial",
                "location":"SettingsViewController",
                "successful": true
                ])
            interstitial.present(fromRootViewController: self)
        } else {
            Analytics.logEvent("viewed_ad", parameters: [
                "type":"interstitial",
                "location":"SettingsViewController",
                "successful": false
                ])
            let alert = UIAlertController(title: "Unable To Load Ad",
                                          message: "The ad was unable to load. Thank you for showing your support! You can try again after a few seconds if you would like, but it is not necessary.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
        }
    }
}

extension SettingsViewController: CTFeedbackViewControllerDelegate {
    
    func feedbackViewController(_ controller: CTFeedbackViewController!, didFinishWithCustomCallback email: String!, topic: String!, content: String!, attachment: UIImage!) {
        if let content = content {
            let key = Database.database().reference().child("feedback").childByAutoId().key
            Database.database().reference().child("feedback/\(key)").setValue([
                "time": NSDate().timeIntervalSince1970 * 1000,
                "topic": "Feedback",
                "content": content,
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
                        let alert = UIAlertController(title: "Thank you for the Feedback", message: "Your message will be reviewed and addressed asap.", preferredStyle: .alert)
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

extension SettingsViewController: GADInterstitialDelegate {
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        Analytics.logEvent("received_ad", parameters: [
            "type":"interstitial",
            "location":"SettingsViewController"
            ])
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = loadInterstitial()
    }
}

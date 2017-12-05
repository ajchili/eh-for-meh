//
//  ItemViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ItemViewController: UIViewController {
    
    var ref: DatabaseReference!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var imageView: UIView!
    @IBOutlet var pageController: UIPageControl!
    @IBOutlet var scrollView: UIScrollView!
    var accentColor: UIColor?
    var backgroundColor: UIColor?
    var foreground: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        ref.child("info").observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            self.titleLabel.text = value?["title"] as? String ?? "Title"
            self.titleLabel.sizeToFit()
            self.descriptionLabel.text = value?["description"] as? String ?? "Description"
            self.descriptionLabel.sizeToFit()
            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.descriptionLabel.frame.height)
        }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("settings").observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.accentColor = UIColor.color(fromHexString: value?["backgroundColor"] as? String ?? "#ffffff")
            self.backgroundColor = UIColor.color(fromHexString: value?["backgroundColor"] as? String ?? "#000000")
            self.foreground = value?["backgroundColor"] as? String ?? "dark"
            
            self.setColor()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func setColor() {
        self.view.layer.backgroundColor = self.backgroundColor!.cgColor
    }

}


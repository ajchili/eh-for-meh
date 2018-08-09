//
//  DealLoader.swift
//  meh.com
//
//  Created by Kirin Patel on 8/8/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAnalytics
import FirebaseDatabase

class DealLoader {
    
    static let sharedInstance = DealLoader()
    
    func loadCurrentDeal(completion: @escaping (_ deal: Deal) -> Void) {
        ThemeLoader.sharedInstance.setupThemeListener { theme in
            Database.database().reference().child("currentDeal/deal").observeSingleEvent(of: .value) { snapshot in
                let deal = self.getDealFromSnapshot(theme: theme, snapshot: snapshot)
                Analytics.logEvent("loadDeal", parameters: [
                    "deal": deal.id
                    ])
                completion(deal)
            }
        }
    }

    func loadDeal(forDeal id: String, completion: @escaping (_ deal: Deal) -> Void) {
        ThemeLoader.sharedInstance.loadTheme(forDeal: id) { theme in
            Database.database().reference().child("previousDeal/\(id)/deal").observeSingleEvent(of: .value, with: { snapshot in
                let deal = self.getDealFromSnapshot(theme: theme, snapshot: snapshot)
                Analytics.logEvent("loadPreviousDeal", parameters: [
                    "deal": deal.id
                    ])
                completion(deal)
            })
        }
    }
    
    private func getDealFromSnapshot(theme: Theme, snapshot: DataSnapshot) -> Deal {
        let id = snapshot.childSnapshot(forPath: "id").value as! String
        let features = snapshot.childSnapshot(forPath: "features").value as! String
        let specifications = snapshot.childSnapshot(forPath: "specifications").value as! String
        let title = snapshot.childSnapshot(forPath: "title").value as! String
        let url = URL(string: snapshot.childSnapshot(forPath: "url").value as! String)
        
        let storyTitle = snapshot.childSnapshot(forPath: "story/title").value as! String
        let storyBody = snapshot.childSnapshot(forPath: "story/body").value as! String
        let story = Story(title: storyTitle, body: storyBody)
        
        let deal = Deal(id: id,
                        title: title,
                        features: features,
                        specifications: specifications,
                        story: story,
                        theme: theme,
                        url: url!)
        
        
        deal.items.append(contentsOf: loadDealItems(objects: snapshot.childSnapshot(forPath: "items").children.allObjects))
        deal.photos.append(contentsOf: loadDealPhotos(objects: snapshot.childSnapshot(forPath: "photos").children.allObjects))
        
        if snapshot.childSnapshot(forPath: "soldOutAt").exists() {
            deal.soldOut = true
        }
        
        if snapshot.childSnapshot(forPath: "topic").exists() {
            let topicId = snapshot.childSnapshot(forPath: "topic/id").value as! String
            let topicURL = URL(string: snapshot.childSnapshot(forPath: "topic/url").value as! String)
            
            deal.topic = Topic(id: topicId, url: topicURL!)
        }
        
        return deal
    }
    
    private func loadDealItems(objects: [Any]) -> [Item] {
        var items = [Item]()
        
        for child in objects {
            let childSnapshot = child as! DataSnapshot
            
            let itemId = childSnapshot.childSnapshot(forPath: "id").value as! String
            let itemCondition = childSnapshot.childSnapshot(forPath: "condition").value as! String
            let itemPrice = childSnapshot.childSnapshot(forPath: "price").value as! CGFloat
            
            items.append(Item(id: itemId, condition: itemCondition, price: itemPrice))
        }
        
        return items
    }
    
    private func loadDealPhotos(objects: [Any]) -> [URL] {
        var photos = [URL]()
        
        for child in objects {
            let childSnapshot = child as! DataSnapshot
            print(childSnapshot.value as! String)
            photos.append(URL(string: childSnapshot.value as! String)!)
        }
        
        return photos
    }
}

//
//  ImagePageViewController.swift
//  meh.com
//
//  Created by Kirin Patel on 12/4/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ImagePageViewController: UIPageViewController {
    
    var ref: DatabaseReference!
    var pageViewController: UIPageViewController!
    weak var pageDelegate: UIPageViewControllerDelegate?
    var orderedViewControllers: [UIViewController]?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        ref = Database.database().reference()
        
        ref.child("info").child("photos").observe(DataEventType.value, with: { (snapshot) in
            self.orderedViewControllers = []
            
            for child in snapshot.children.allObjects {
                let childSnapshot = child as! DataSnapshot
                
                let imageURL = URL(string: childSnapshot.value as! String)!
                self.orderedViewControllers?.append(self.newImageViewController(image: imageURL))
            }
            
            if let firstViewController = self.orderedViewControllers!.first {
                self.setViewControllers([firstViewController],
                                   direction: .forward,
                                   animated: true,
                                   completion: nil)
            }
            
            (self.parent as? ItemViewController)?.pageController.numberOfPages = (self.orderedViewControllers?.count)!
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func newImageViewController(image: URL) -> UIViewController {
        let imageViewController = UIStoryboard(name: "ImageView", bundle: nil).instantiateInitialViewController() as! ImageViewController
        imageViewController.image = image
        return imageViewController
    }
}

extension ImagePageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        setPageControlIndex(index: orderedViewControllers!.index(of: viewController)!)
        guard let viewControllerIndex = orderedViewControllers!.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        if (previousIndex > orderedViewControllers!.count) {
            return orderedViewControllers![0]
        } else if (previousIndex < 0) {
            return orderedViewControllers![orderedViewControllers!.count - 1]
        } else {
            return orderedViewControllers![previousIndex]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        setPageControlIndex(index: orderedViewControllers!.index(of: viewController)!)
        guard let viewControllerIndex = orderedViewControllers!.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        if (nextIndex > orderedViewControllers!.count) {
            return orderedViewControllers![0]
        } else if (nextIndex < 0) {
            return orderedViewControllers![orderedViewControllers!.count - 1]
        } else {
            return orderedViewControllers![nextIndex]
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers!.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers!.index(of: firstViewController) else {
                return 0
        }
        return firstViewControllerIndex
    }
    
    func setPageControlIndex(index: Int) {
        (parent as? ItemViewController)?.pageController.currentPage = index
    }
}

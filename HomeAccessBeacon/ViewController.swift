//
//  ViewController.swift
//  HomeAccessBeacon
//
//  Created by AlienLi on 16/1/22.
//  Copyright © 2016年 MarcoLi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var tableViewController: TableViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TableViewController") as!TableViewController
        self.addChildViewController(tableViewController)
        
        tableViewController.willMoveToParentViewController(self)
        self.view.addSubview(tableViewController.view)
        tableViewController.view.frame = self.view.bounds
        
        tableViewController.didMoveToParentViewController(self)
        
        
        BlueToothCenter.defaultCenter.handler = { items in
            self.tableViewController.pmData = items
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableViewController.tableView.reloadData()
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


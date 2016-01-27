//
//  ViewController.swift
//  HomeAccessBeacon
//
//  Created by AlienLi on 16/1/22.
//  Copyright © 2016年 MarcoLi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var time: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        time = UILabel()
        view.addSubview(time)

        time.textColor = UIColor.blackColor()
        time.textAlignment = .Center
        time.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(
            [
                NSLayoutConstraint(item: time, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: time, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0),

            ])
        
        
        BlueToothCenter.defaultCenter.handler = {(data) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.time.text = data
                self.time.updateConstraintsIfNeeded()
                print(data)
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


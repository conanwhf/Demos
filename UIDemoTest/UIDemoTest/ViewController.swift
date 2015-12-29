//
//  ViewController.swift
//  UIDemoTest
//
//  Created by Conan on 28/12/15.
//  Copyright © 2015年 Conan. All rights reserved.
//

import UIKit

class DemoListController: UIViewController {
    
    @IBOutlet weak var info: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("id = \(segue.identifier), \(sender?.currentTitle)")
        // Get the new view controller using segue.destinationViewController, and pass the selected object to the new view controller.
        let next = segue.destinationViewController as! ShowController
        //passvalue为NextViewController中定义
        next.title = sender?.currentTitle
    }
}


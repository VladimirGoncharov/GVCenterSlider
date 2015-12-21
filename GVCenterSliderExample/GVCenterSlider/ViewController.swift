//
//  ViewController.swift
//  CenterSlider
//
//  Created by Jonathan Hull on 8/5/15.
//  Copyright © 2015 Jonathan Hull. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var slider: GVCenterSlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        slider.actionBlock = { (slider: GVCenterSlider, value: CGFloat) -> Void in
            print(value)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


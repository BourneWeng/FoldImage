//
//  ViewController.swift
//  FoldImage
//
//  Created by BourneWeng on 15/6/16.
//  Copyright (c) 2015年 Bourne. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pageView: PageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        self.pageView.backgroundColor = self.view.backgroundColor
        
        self.pageView.image = UIImage(named: "TaylorSwift.jpg")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


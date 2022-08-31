//
//  ExamplePopoverViewController.swift
//  NXGallery_Example
//
//  Created by Ionut Lucaci on 01.09.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class ExamplePopoverViewController: UIViewController {
    var message: String? = nil 
    
    @IBOutlet weak var topPadding: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var interimSpacing: NSLayoutConstraint!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bottomPadding: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = title
        messageLabel.text = message
        
        preferredContentSize = CGSize(width: 250,
                                      height: topPadding.constant
                                      + titleLabel.frame.height 
                                      + interimSpacing.constant
                                      + messageLabel.frame.height
                                      + bottomPadding.constant)
    }        
}

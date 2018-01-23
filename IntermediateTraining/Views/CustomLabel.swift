//
//  CustomLabel.swift
//  IntermediateTraining
//
//  Created on 1/23/18.
//  Copyright © 2018 Damian Cesar. All rights reserved.
//

import UIKit

class CustomLabel: UILabel {

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        let customRect = UIEdgeInsetsInsetRect(rect, insets)
        super.drawText(in: customRect)
    }
    
}

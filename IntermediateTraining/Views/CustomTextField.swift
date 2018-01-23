//
//  CustomTextField.swift
//  IntermediateTraining
//
//  Created on 1/23/18.
//  Copyright © 2018 Damian Cesar. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class CustomTextField: SkyFloatingLabelTextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        selectedTitleColor = .mainBlue
        selectedLineColor = .mainBlue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

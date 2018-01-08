//
//  UIViewController+Helpers.swift
//  IntermediateTraining
//
//  Created on 12/29/17.
//  Copyright © 2017 Damian Cesar. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setupAddBarButtonItemInNavBar(selector: Selector) {
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: selector)
        
        navigationItem.rightBarButtonItem = addBarButtonItem
    }
    
    func setupCancelBarButtonItemInNavBar(selector: Selector) {
        let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: selector)
        
        navigationItem.leftBarButtonItem = cancelBarButtonItem
    }
    
    func setupSaveBarButtonItemInNavBar(selector: Selector) {
        let saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: selector)
        
        navigationItem.rightBarButtonItem = saveBarButtonItem
    }
    
}

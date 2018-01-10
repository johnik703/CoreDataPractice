//
//  CustomMigrationPolicy.swift
//  IntermediateTraining
//
//  Created by Julio Cesar Hernandez-Duran on 1/9/18.
//  Copyright © 2018 Damian Cesar. All rights reserved.
//

import CoreData

class CustomMigrationPolicy: NSEntityMigrationPolicy {
    // type our transformation function
    
    @objc func transformNumEmployees(forNum: NSNumber) -> String {
        if forNum.intValue < 150 {
            return "Small"
        } else {
            return "Very Large"
        }
    }
    
}

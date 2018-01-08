//
//  EmployeeTableViewCell.swift
//  IntermediateTraining
//
//  Created on 12/29/17.
//  Copyright © 2017 Damian Cesar. All rights reserved.
//

import UIKit

class EmployeeTableViewCell: UITableViewCell {

    var employee: Employee? {
        didSet {
            textLabel?.text = employee?.name
            
            if let taxId = employee?.employeeInformation?.taxId {
                print(taxId)
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        
    }
    
}

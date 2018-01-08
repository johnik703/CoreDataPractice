//
//  CompaniesController+CreateCompany.swift
//  IntermediateTraining
//
//  Created on 12/28/17.
//  Copyright © 2017 Damian Cesar. All rights reserved.
//

import Foundation

extension CompaniesTableViewController: CreateEditCompanyControllerDelegate {
    func didCreateCompany(_ company: Company) {
        companies.append(company)
        
        let newIndexPath = IndexPath(row: companies.count - 1, section: 0)
        
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    func didEditCompany(_ company: Company) {
        let row = companies.index(of: company)
        
        let reloadIndexPath = IndexPath(row: row!, section: 0)
        
        tableView.reloadRows(at: [reloadIndexPath], with: .automatic)
    }
}

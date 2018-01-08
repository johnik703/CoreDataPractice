//
//  ViewController.swift
//  IntermediateTraining
//
//  Created by Julio Cesar Hernandez-Duran on 12/27/17.
//  Copyright © 2017 Damian Cesar. All rights reserved.
//

import UIKit
import CoreData

class CompaniesTableViewController: UITableViewController {
    
    let cellIdentifier = "CompanyCell"
    
    var companies = [Company]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.companies = CoreDataManager.shared.fetchCompanies()
        
        navigationItem.title = "Companies"
        
        tableView.register(CompanyTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView()
                
        setupAddBarButtonItemInNavBar(selector: #selector(handleAddCompany))
        
        let resetBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(handleReset))
        
        navigationItem.leftBarButtonItem = resetBarButtonItem
    }
    
    @objc private func handleReset() {
        CoreDataManager.shared.resetCompanies { (error) in
            guard error == nil else { return }
            
            var indexPathsToRemove = [IndexPath]()
            
            for index in companies.indices {
                let indexPath = IndexPath(row: index, section: 0)
                indexPathsToRemove.append(indexPath)
            }
            
            companies.removeAll()
            tableView.deleteRows(at: indexPathsToRemove, with: .top)
        }
    }
    
    @objc private func handleAddCompany() {
        let createCompanyViewController = CreateEditCompanyViewController()
        createCompanyViewController.delegate = self
        
        let navigationController = UINavigationController(rootViewController: createCompanyViewController)
        
        present(navigationController, animated: true, completion: nil)
    }
    
}

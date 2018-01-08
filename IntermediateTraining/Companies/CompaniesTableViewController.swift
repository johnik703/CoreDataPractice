//
//  ViewController.swift
//  IntermediateTraining
//
//  Created on 12/27/17.
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
        let doWorkBarButtonItem = UIBarButtonItem(title: "Do Work", style: .plain, target: self, action: #selector(doWork))
        
        navigationItem.leftBarButtonItems = [resetBarButtonItem, doWorkBarButtonItem]
    }
    
    @objc private func doWork() {
        print("Trying to do work...")
        
        // Grand Central Dispatch
        
        CoreDataManager.shared.persistentContainer.performBackgroundTask { (backgroundContext) in
            (0...20000).forEach { (value) in
                print(value)
                
                let newCompany = Company(context: backgroundContext)
                newCompany.name = "\(value)"
            }
            
            do {
                try backgroundContext.save()
            } catch let error {
                print(error)
            }
        }
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

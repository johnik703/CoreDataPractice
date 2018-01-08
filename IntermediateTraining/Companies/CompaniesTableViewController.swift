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
//        let doUpdatesBarButtonItem = UIBarButtonItem(title: "Do Updates", style: .plain, target: self, action: #selector(doUpdates))
//        let doWorkBarButtonItem = UIBarButtonItem(title: "Do Work", style: .plain, target: self, action: #selector(doWork))
        
        let nestedUpdatesBarButtonItem = UIBarButtonItem(title: "Nested Updates", style: .plain, target: self, action: #selector(doNestedUpdates))
        
        navigationItem.leftBarButtonItems = [resetBarButtonItem, nestedUpdatesBarButtonItem]
//        navigationItem.leftBarButtonItems = [resetBarButtonItem, doWorkBarButtonItem]
    }
    
    @objc private func doNestedUpdates() {
        DispatchQueue.global(qos: .background).async {
            // We'll try to perform our updates
            
            // WE'll first construct a managed object construct
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            
            privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
            
            // Execute updates on private context
            
            let request: NSFetchRequest<Company> = Company.fetchRequest()
            request.fetchLimit = 1
            
            do {
                let companies = try privateContext.fetch(request)
                
                companies.forEach({ (company) in
                    print(company.name ?? "")
                    
                    company.name = "D: \(company.name ?? "")"
                    
                    do {
                        try privateContext.save()
                        
                        DispatchQueue.main.async {
                            do {
                                
                                let context = CoreDataManager.shared.persistentContainer.viewContext
                                
                                if context.hasChanges {
                                    try context.save()
                                }
                                
                                self.tableView.reloadData()
                                
                            } catch let error {
                                print("Failed to save on main context", error)
                            }
                        }
                    } catch let error {
                        print("Failed to save on private context", error)
                    }
                })
            } catch let error {
                print("Failed to fetch on private context:", error)
            }
        }
    }
    
    @objc private func doUpdates() {
        print("Trying to do updates...")
        
        // Perform a background task
        CoreDataManager.shared.persistentContainer.performBackgroundTask { (backgroundContext) in
            
            // Have to make another fetch request becasue we're on a different thread
            let request: NSFetchRequest<Company> = Company.fetchRequest()
            
            // As usual we have to perform a do catch
            do {
                let companies = try backgroundContext.fetch(request)
                
                companies.forEach({ (company) in
                    print(company.name ?? "") // nil colassesing
                    company.name = "B: \(company.name ?? "")"
                })
                
                // In order to save we have to make another do catch
                do {
                    try backgroundContext.save()
                    
                    // lets try do update the ui after a save
                    
                    DispatchQueue.main.async {
                        
                        // You don't want to fetch everything if your just simply updating one or two companies
                        self.companies = CoreDataManager.shared.fetchCompanies()
                        
                        // Is there a way to just merge the changes that you made on to the main context
                        self.tableView.reloadData()
                    }
                } catch let error {
                    print(error)
                }
                
            } catch let error {
                print(error)
            }

        }
    }
    
    @objc private func doWork() {
        print("Trying to do work...")
        
        // Grand Central Dispatch
        
        CoreDataManager.shared.persistentContainer.performBackgroundTask { (backgroundContext) in
            (0...5).forEach { (value) in
                print(value)
                
                let newCompany = Company(context: backgroundContext)
                newCompany.name = "\(value)"
            }
            
            do {
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    self.companies = CoreDataManager.shared.fetchCompanies()
                    self.tableView.reloadData()
                }
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

//
//  CompaniesTableViewController.swift
//  IntermediateTraining
//
//  Created on 12/27/17.
//  Copyright © 2017 Damian Cesar. All rights reserved.
//

import UIKit
import CoreData

class CompaniesTableViewController: UITableViewController, CreateEditCompanyControllerDelegate {
    
    let cellIdentifier = "CompanyTableViewCell"
    
    var companies = [Company]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        companies = CoreDataManager.shared.fetchCompanies()
        
        navigationItem.title = "Companies"
        
        setupTableView()
        setupNavigationBar()
    }
    
    
    // MARK: - Helpers
    
    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        tableView.register(CompanyTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    private func setupNavigationBar() {
        setupAddBarButtonItemInNavBar(selector: #selector(handleCreateCompany))
        
        let resetBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(handleReset))
        navigationItem.leftBarButtonItem = resetBarButtonItem
    }
    
    private func presentNavigationController(with rootViewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        present(navigationController, animated: true)
    }
    
    
    // MARK: - Handlers
    
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
    
    @objc private func handleCreateCompany() {
        let createEditCompanyController = CreateEditCompanyViewController()
        createEditCompanyController.delegate = self
        
        presentNavigationController(with: createEditCompanyController)
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CompanyTableViewCell
        cell.company = companies[indexPath.row]
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
    }
    
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let employeesController = EmployeesTableViewController()
        employeesController.company = companies[indexPath.row]
        
        navigationController?.pushViewController(employeesController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: editHandlerFunction)
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: deleteHandlerFunction)
        return [deleteAction, editAction]
    }
    
    private func deleteHandlerFunction(action: UITableViewRowAction, indexPath: IndexPath) {
        let row = indexPath.row
        let companyToDelete = self.companies[row]
        self.companies.remove(at: row)
        self.tableView.deleteRows(at: [indexPath], with: .left)
        
        CoreDataManager.shared.deleteCompany(companyToDelete)
    }

    private func editHandlerFunction(action: UITableViewRowAction, indexPath: IndexPath) {
        let editCompanyController = CreateEditCompanyViewController()
        editCompanyController.company = companies[indexPath.row]
        editCompanyController.delegate = self
        
        presentNavigationController(with: editCompanyController)
    }
    
    // MARK: - Create Edit Company Controller Delegate
    
    func didCreateCompany(_ company: Company) {
        companies.append(company)
        
        let newIndexPath = IndexPath(row: companies.count - 1, section: 0)
        
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    func didEditCompany(_ company: Company) {
        guard let row = companies.index(of: company) else {
            print("Error: retreiving index of \(company.name ?? "company").")
            return
        }
        
        let reloadIndexPath = IndexPath(row: row, section: 0)
        
        tableView.reloadRows(at: [reloadIndexPath], with: .automatic)
    }
}


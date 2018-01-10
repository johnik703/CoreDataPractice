//
//  CompanyAutoUpdateController.swift
//  IntermediateTraining
//
//  Created by Julio Cesar Hernandez-Duran on 1/8/18.
//  Copyright © 2018 Damian Cesar. All rights reserved.
//

import UIKit
import CoreData

class CompanyAutoUpdateController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    let cellId = "CellId"
    
    lazy var fetchResultsController: NSFetchedResultsController<Company> = {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
       let frc = NSFetchedResultsController(fetchRequest: request,
                                            managedObjectContext: context,
                                            sectionNameKeyPath: "name",
                                            cacheName: nil)
        
        frc.delegate = self
        
        do {
         try frc.performFetch()
        } catch let err {
            print(err)
        }
        return frc
    }()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let employeesListController = EmployeesTableViewController()
        employeesListController.company = fetchResultsController.object(at: indexPath)
    
        navigationController?.pushViewController(employeesListController, animated: true)
    }
    
    @objc private func handleAdd() {
        print("Add a company called bmw")
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let newCompany = Company(context: context)
        
        newCompany.name = "0000"
        
        do {
            try context.save()
            
            
        } catch let error {
            print(error)
        }
        
    }
    
    @objc private func handleDelete() {
        print("Attempting to delete")
        let request: NSFetchRequest<Company> = fetchResultsController.fetchRequest
        
//        request.predicate = NSPredicate(format: "name CONTAINS %@", "0")
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        do {
            let companiesWithB = try context.fetch(request)
            
            companiesWithB.forEach({ (company) in
                context.delete(company)
            })
            
            do {
                try context.save()
            } catch let saveErr {
                print(saveErr)
            }
            
        } catch let err {
            print(err)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "CompanyAutoUpdates"
        
//        let addBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAdd))
        let deleteBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(handleDelete))
        
        navigationItem.leftBarButtonItem = deleteBarButtonItem
        
        tableView.register(CompanyTableViewCell.self, forCellReuseIdentifier: cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.tintColor = .white
        
        self.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh() {
        print("Handle refresh")
        
        Service.shared.downloadCompaniesFromServer()
        self.refreshControl?.endRefreshing()
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
        label.text = fetchResultsController.sectionIndexTitles[section]
        label.backgroundColor = .red
        return label
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultsController.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CompanyTableViewCell
        
        let company = fetchResultsController.object(at: indexPath)
        
        cell.company = company
        
        return cell
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()

    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        
        
        switch (type) {
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .automatic)
        default:
            break
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [newIndexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
}

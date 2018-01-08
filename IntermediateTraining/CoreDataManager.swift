//
//  CoreDataManager.swift
//  IntermediateTraining
//
//  Created by Damian Cesar Hernandez on 12/27/17.
//  Copyright © 2017 Damian Cesar. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "IntermediateTrainingModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Loading of persistent store failed: \(error)")
            }
        }
        return container
    }()
    
    func fetchCompanies() -> [Company] {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")
        
        do {
            let companies = try context.fetch(fetchRequest)
            return companies
            
        } catch let fetchError {
            print("Failed to fetch companies: \(fetchError)")
            return []
        }
    }
    
    func resetCompanies(completion: (_ error: String?) -> ()) {
        let context = persistentContainer.viewContext
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: Company.fetchRequest())
        
        do {
            try context.execute(batchDeleteRequest)

            completion(nil)
        } catch let deleteError {
            let error = "Failed to delete objects from core data: \(deleteError)"
            completion(error)
        }
    }
    
    func createEmployee(name: String, type: String, company: Company) -> (Employee?, Error?) {
        let context = persistentContainer.viewContext
        
        let employee = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: context) as! Employee
        
        employee.company = company
        employee.type = type
        
        employee.setValue(name, forKey: "name")
        
        let employeeInformation = NSEntityDescription.insertNewObject(forEntityName: "EmployeeInformation", into: context) as! EmployeeInformation
        
        employeeInformation.taxId = "456"
        
        employee.employeeInformation = employeeInformation
        
        do {
            try context.save()
            return (employee, nil)
            
        } catch let error {
            print("Error creating employee: \(error)")
            return (nil, error)
        }
    }
    
}

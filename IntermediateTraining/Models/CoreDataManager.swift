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
    
    private init(){}
    
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
    
    func deleteCompany(_ company: Company) {
        let context = persistentContainer.viewContext
        context.delete(company)
        
        do {
            try context.save()
        } catch let error {
            print("Failed to delete \(company.name ?? "company") from core data: \(error)")
        }
    }
    
    func createEmployee(firstName: String, lastName: String, type: String, company: Company) -> Employee? {
        let context = persistentContainer.viewContext
        
        let employee = Employee(context: context)
        employee.company = company
        employee.type = type
        employee.fullName = "\(firstName) \(lastName)"
        
        do {
            try context.save()
            return employee
            
        } catch let error {
            print("Error: Failed to create employee: \(error)")
            return nil
        }
    }
    
}

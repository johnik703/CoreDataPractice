//
//  Service.swift
//  IntermediateTraining
//
//  Created on 1/9/18.
//  Copyright © 2018 Damian Cesar. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct Service {
    
    static let shared = Service()
    
    let urlString = "https://api.letsbuildthatapp.com/intermediate_training/companies"
    
    func downloadCompaniesFromServer() {
        print("Attempting to download companies")
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("Failed to download companies:", error!)
                return
            }
            
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let jsonCompanies = try jsonDecoder.decode([JSONCompany].self, from: data)
                
                let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
                
                jsonCompanies.forEach({ (jsonCompany) in
                    print(jsonCompany.name)

                    let company = Company(context: privateContext)
                    
                    company.name = jsonCompany.name
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    
                    let foundedDate = dateFormatter.date(from: jsonCompany.founded)

                    company.foundedDate = foundedDate
                    
                    jsonCompany.employees?.forEach({ (jsonEmployee) in
                        print("  \(jsonEmployee.name)")
                        
                        let employee = Employee(context: privateContext)
                        employee.fullName = jsonEmployee.name
                        employee.type = jsonEmployee.type
                        employee.company = company
                        
                        let employeeInformation = EmployeeInformation(context: privateContext)
                        
                        let birthdayDate = dateFormatter.date(from: jsonEmployee.birthday)
                        
                        employeeInformation.birthday = birthdayDate
                        
                        employee.employeeInformation = employeeInformation
                    })
                    
                    
                    do {
                        try privateContext.save()
                        try privateContext.parent?.save()
                    } catch let saveError {
                        print("Failed to save to private context:", saveError)
                    }
                })
                
            } catch let decodeError {
                print("Failed to decode:", decodeError)
            }
            
        }.resume()
    }
}

struct JSONCompany: Decodable {
    let name: String
    let founded: String
    let photoUrl: String
    var employees: [JSONEmployee]?
}

struct JSONEmployee: Decodable {
    let name: String
    let birthday: String
    let type: String
}

//
//  Service.swift
//  IntermediateTraining
//
//  Created on 1/9/18.
//  Copyright © 2018 Damian Cesar. All rights reserved.
//

import Foundation
import UIKit

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
                
                jsonCompanies.forEach({ (jsonCompany) in
                    print(jsonCompany.name)
                    
                    jsonCompany.employees?.forEach({ (jsonEmployee) in
                        print("  \(jsonEmployee.name)")
                    })
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



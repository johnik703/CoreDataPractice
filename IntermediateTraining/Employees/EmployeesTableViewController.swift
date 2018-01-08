//
//  EmployeesTableViewController.swift
//  IntermediateTraining
//
//  Created on 12/29/17.
//  Copyright © 2017 Damian Cesar. All rights reserved.
//

import UIKit
import CoreData

class IndentedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        let customRect = UIEdgeInsetsInsetRect(rect, insets)
        super.drawText(in: customRect)
    }
}

class EmployeesTableViewController: UITableViewController {

    var company: Company?
    var executiveEmployees = [Employee]()
    var staffEmployees = [Employee]()
    var allEmployees = [[Employee]]()
    
    var employeeTypes: [String] = [
        EmployeeType.Executive.rawValue,
        EmployeeType.SeniorManagement.rawValue,
        EmployeeType.Staff.rawValue
    ]
    
    let EMPLOYEE_CELL_REUSE_IDENTIFIER = "EmployeeCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = company?.name

        setupAddBarButtonItemInNavBar(selector: #selector(handleAddEmployee))
        
        tableView.register(EmployeeTableViewCell.self, forCellReuseIdentifier: EMPLOYEE_CELL_REUSE_IDENTIFIER)
        
        fetchEmployees()
    }
    
    private func fetchEmployees() {
        guard let companyEmployees = company?.employees?.allObjects as? [Employee] else { return }
        
        employeeTypes.forEach { (employeeType) in
            allEmployees.append(companyEmployees.filter { $0.type == EmployeeType.Executive.rawValue })
        }
        
        let executives = companyEmployees.filter { $0.type == EmployeeType.Executive.rawValue }
        let seniorManagement = companyEmployees.filter { $0.type == EmployeeType.SeniorManagement.rawValue }
        let staff = companyEmployees.filter { $0.type == EmployeeType.Staff.rawValue }
        
        allEmployees = [executives, seniorManagement, staff]
    }
    
    @objc private func handleAddEmployee() {
        let createEmployeeController = CreateEmployeeViewController()
        createEmployeeController.delegate = self
        createEmployeeController.company = company
        
        let navigationController = UINavigationController(rootViewController: createEmployeeController)
        
        present(navigationController, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return allEmployees.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
        
        label.text = employeeTypes[section]
        label.backgroundColor = .softGray
        
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEmployees[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EMPLOYEE_CELL_REUSE_IDENTIFIER, for: indexPath) as! EmployeeTableViewCell
        
        let employee = allEmployees[indexPath.section][indexPath.row]
        
        cell.employee = employee
        
        return cell
    }

}

// MARK: - Create Employee Controller Delegate
extension EmployeesTableViewController: CreateEmployeeControllerDelegate {
    
    func didAddEmployee(employee: Employee) {
        guard let section = employeeTypes.index(of: employee.type!) else { return }
        
        let row = allEmployees[section].count
        
        allEmployees[section].append(employee)
    
        let indexPath = IndexPath(row: row, section: section)
        
        tableView.insertRows(at: [indexPath], with: .middle)
    }
    
}

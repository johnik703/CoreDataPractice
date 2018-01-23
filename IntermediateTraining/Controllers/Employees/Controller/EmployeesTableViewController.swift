//
//  EmployeesTableViewController.swift
//  IntermediateTraining
//
//  Created on 12/29/17.
//  Copyright © 2017 Damian Cesar. All rights reserved.
//

import UIKit
import CoreData

class EmployeesTableViewController: UITableViewController, CreateEmployeeViewControllerDelegate {

    var company: Company?
    var executiveEmployees = [Employee]()
    var staffEmployees = [Employee]()
    var employees = [[Employee]]()
    
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
        tableView.tableFooterView = UIView()
        
        fetchEmployees()
    }
    
    // MARK: - Helpers
    
    private func fetchEmployees() {
        guard let companyEmployees = company?.employees?.allObjects as? [Employee] else { return }
        
        employeeTypes.forEach { (employeeType) in
            employees.append(companyEmployees.filter { $0.type == EmployeeType.Executive.rawValue })
        }
        
        let executives = companyEmployees.filter { $0.type == EmployeeType.Executive.rawValue }
        let seniorManagement = companyEmployees.filter { $0.type == EmployeeType.SeniorManagement.rawValue }
        let staff = companyEmployees.filter { $0.type == EmployeeType.Staff.rawValue }
        
        employees = [executives, seniorManagement, staff]
    }
    
    // MARK: - Handlers
    
    @objc private func handleAddEmployee() {
        let createEmployeeController = CreateEmployeeViewController()
        createEmployeeController.delegate = self
        createEmployeeController.company = company
        
        let navigationController = UINavigationController(rootViewController: createEmployeeController)
        
        present(navigationController, animated: true)
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return employees.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EMPLOYEE_CELL_REUSE_IDENTIFIER, for: indexPath) as! EmployeeTableViewCell
        
        let employee = employees[indexPath.section][indexPath.row]
        cell.employee = employee
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = CustomLabel()
        label.text = employeeTypes[section]
        label.backgroundColor = .mainGray
        return label
    }
    
    // MARK: - Create Employee Delegate
    
    func didCreateEmployee(employee: Employee) {
        guard let section = employeeTypes.index(of: employee.type!) else { return }
        
        let row = employees[section].count
        
        employees[section].append(employee)
        
        let indexPath = IndexPath(row: row, section: section)
        tableView.insertRows(at: [indexPath], with: .middle)
    }

}

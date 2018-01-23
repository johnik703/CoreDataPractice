//
//  CreateEmployeeViewController.swift
//  IntermediateTraining
//
//  Created on 12/29/17.
//  Copyright © 2017 Damian Cesar. All rights reserved.
//

import UIKit
import PureLayout

protocol CreateEmployeeViewControllerDelegate {
    func didCreateEmployee(employee: Employee)
}

class CreateEmployeeViewController: UIViewController {
    
    var company: Company?
    var delegate: CreateEmployeeViewControllerDelegate?
    
    let firstNameTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "First Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let lastNameTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Last Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let birthdayTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Birthday"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let birthdayDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(handleDatePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    let employeeTypeSegmentedControl: UISegmentedControl = {
        let items = [EmployeeType.Executive.rawValue,
                     EmployeeType.SeniorManagement.rawValue,
                     EmployeeType.Staff.rawValue]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 2
        segmentedControl.tintColor = .mainBlue
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Create Employee"
        
        firstNameTextField.becomeFirstResponder()
        
        birthdayTextField.inputView = birthdayDatePicker
        
        setupCancelBarButtonItemInNavBar(selector: #selector(handleCancel))
        setupSaveBarButtonItemInNavBar(selector: #selector(handleSave))
        
        setupSubviews()
    }
    
    // MARK: - Helpers
    
    private func setupSubviews() {
        view.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(firstNameTextField)
        stackView.addArrangedSubview(lastNameTextField)
        stackView.addArrangedSubview(birthdayTextField)
        
        view.addSubview(stackView)
        view.addSubview(employeeTypeSegmentedControl)
        
        firstNameTextField.autoSetDimension(.height, toSize: 50)
        lastNameTextField.autoMatch(.height, to: .height, of: firstNameTextField)
        birthdayTextField.autoMatch(.height, to: .height, of: firstNameTextField)
        
        stackView.autoPinEdge(.left, to: .left, of: view, withOffset: 24)
        stackView.autoPinEdge(.top, to: .top, of: view, withOffset: 24)
        stackView.autoPinEdge(.right, to: .right, of: view, withOffset: -24)
        
        employeeTypeSegmentedControl.autoSetDimension(.height, toSize: 35)
        employeeTypeSegmentedControl.autoPinEdge(.top, to: .bottom, of: stackView, withOffset: 16)
        employeeTypeSegmentedControl.autoPinEdge(.left, to: .left, of: stackView)
        employeeTypeSegmentedControl.autoPinEdge(.right, to: .right, of: stackView)
    }
    
    // MARK: - Handlers
    
    @objc private func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc private func handleSave() {
        guard let company = company else { return }
        guard let firstName = firstNameTextField.text else { return }
        guard let lastName = lastNameTextField.text else { return }
        
        let selectedSegmentedIndex = employeeTypeSegmentedControl.selectedSegmentIndex
        
        guard let type = employeeTypeSegmentedControl.titleForSegment(at: selectedSegmentedIndex) else { return }
        
        if let newEmployee = CoreDataManager.shared.createEmployee(firstName: firstName, lastName: lastName, type: type, company: company) {
            dismiss(animated: true, completion: {
                self.delegate?.didCreateEmployee(employee: newEmployee)
            })
        }
    }
    
    @objc private func handleDatePickerValueChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        birthdayTextField.text = dateFormatter.string(from: birthdayDatePicker.date)
    }
    
}

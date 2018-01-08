//
//  CreateEmployeeViewController.swift
//  IntermediateTraining
//
//  Created on 12/29/17.
//  Copyright © 2017 Damian Cesar. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

protocol CreateEmployeeControllerDelegate {
    func didAddEmployee(employee: Employee)
}

class CreateEmployeeViewController: UIViewController {
    
    var company: Company?
    var delegate: CreateEmployeeControllerDelegate?
    
    lazy var nameTextField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.placeholder = "Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var birthdayTextField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.placeholder = "Birthday"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var birthdayDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    lazy var employeeTypeSegmentedControl: UISegmentedControl = {
        let items = [EmployeeType.Executive.rawValue,
                     EmployeeType.SeniorManagement.rawValue,
                     EmployeeType.Staff.rawValue]
        
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Create Employee"
        
        birthdayTextField.inputView = birthdayDatePicker
        
        setupCancelBarButtonItemInNavBar(selector: #selector(handleCancel))
        setupSaveBarButtonItemInNavBar(selector: #selector(handleSave))
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        view.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(birthdayTextField)
        stackView.addArrangedSubview(employeeTypeSegmentedControl)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            birthdayTextField.heightAnchor.constraint(equalTo: nameTextField.heightAnchor),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32)
        ])
    }
    
    @objc private func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc private func handleSave() {
        guard let company = self.company else { return }
        guard let name = nameTextField.text else { return }
        
        let selectedSegmentedIndex = employeeTypeSegmentedControl.selectedSegmentIndex
        
        guard let type = employeeTypeSegmentedControl.titleForSegment(at: selectedSegmentedIndex) else { return }
        
        let tuple = CoreDataManager.shared.createEmployee(name: name, type: type, company: company)
        
        if let error = tuple.1 {
            print(error)
        } else {
            dismiss(animated: true, completion: {
                self.delegate?.didAddEmployee(employee: tuple.0!)
            })
        }
    }
    
    @objc private func datePickerValueChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        birthdayTextField.text = dateFormatter.string(from: birthdayDatePicker.date)
    }

}

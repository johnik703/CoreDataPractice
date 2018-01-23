//
//  CreateCompanyViewController.swift
//  IntermediateTraining
//
//  Created on 12/27/17.
//  Copyright © 2017 Damian Cesar. All rights reserved.
//

import UIKit
import CoreData
import PureLayout

protocol CreateEditCompanyControllerDelegate {
    func didCreateCompany(_ company: Company)
    func didEditCompany(_ company: Company)
}

class CreateEditCompanyViewController: UIViewController, UINavigationControllerDelegate {
    
    var delegate: CreateEditCompanyControllerDelegate?
    
    var company: Company? {
        didSet {
            guard let company = company else { return }
            
            if let imageData = company.imageData {
                companyImageView.image = UIImage(data: imageData)
                
                setupCircularImageStyle()
            }
            
            nameTextField.text = company.name
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            
            guard let foundedDate = company.foundedDate else { return }
            foundedDateTextField.text = dateFormatter.string(from: foundedDate)
        }
    }
    
    private lazy var companyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.clipsToBounds = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImage)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Company Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let foundedDateTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Founding Date"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var foundedDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            self.nameTextField.becomeFirstResponder()
        }
        
        navigationItem.title = company == nil ? "Create Company" : "Edit Company"
        
        foundedDateTextField.inputView = foundedDatePicker
    
        setupCancelBarButtonItemInNavBar(selector: #selector(handleCancel))
        setupSaveBarButtonItemInNavBar(selector: #selector(handleSave))
        
        setupSubviews()
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }
    
    private func setupSubviews() {
        view.addSubview(companyImageView)
        
        let textFieldStackView = UIStackView()
        textFieldStackView.axis = .vertical
        textFieldStackView.alignment = .fill
        textFieldStackView.spacing = 18
        textFieldStackView.translatesAutoresizingMaskIntoConstraints = false

        textFieldStackView.addArrangedSubview(nameTextField)
        textFieldStackView.addArrangedSubview(foundedDateTextField)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(textFieldStackView)

        view.addSubview(stackView)

        nameTextField.autoSetDimension(.height, toSize: 50)
        foundedDateTextField.autoSetDimension(.height, toSize: 50)
        
        companyImageView.autoPinEdge(.top, to: .top, of: view, withOffset: 16)
        companyImageView.autoAlignAxis(.vertical, toSameAxisOf: view)
        companyImageView.autoSetDimensions(to: CGSize(width: 120, height: 120))
        
        stackView.autoPinEdge(.left, to: .left, of: view, withOffset: 24.0)
        stackView.autoPinEdge(.top, to: .bottom, of: companyImageView, withOffset: 8)
        stackView.autoPinEdge(.right, to: .right, of: view, withOffset: -24.0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        companyImageView.layer.cornerRadius = companyImageView.bounds.size.width / 2
        
//        setupCircularImageStyle()
    }
    
    private func setupCircularImageStyle() {
        companyImageView.layer.borderWidth = 2
        companyImageView.layer.borderColor = UIColor.mainGray.cgColor
        companyImageView.layer.cornerRadius = companyImageView.frame.width / 2
        companyImageView.clipsToBounds = true
    }
    
    @objc private func datePickerValueChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        foundedDateTextField.text = dateFormatter.string(from: foundedDatePicker.date)
    }
    
    @objc private func handleSelectImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true)
    }
    
    @objc private func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc private func handleSave() {
        if company == nil {
            createCompany()
        } else {
            editCompany()
        }
    }
    
    private func createCompany() {
        let context = CoreDataManager.shared.persistentContainer.viewContext

        let newCompany = Company(context: context)

        if let companyImage = companyImageView.image {
            let imageData = UIImageJPEGRepresentation(companyImage, 0.8)
            
            newCompany.imageData = imageData
        }

        guard let name = nameTextField.text, nameTextField.text != "" else {
            presentAlertController(title: "Error Creating Company", message: "Please be sure to include the company's name.")
            return
        }

        guard let _ = foundedDateTextField.text, foundedDateTextField.text != "" else {
            presentAlertController(title: "Error Creating Company", message: "Please be sure to include the company's founding date")
            return
        }
        
        newCompany.name = name
        newCompany.foundedDate = foundedDatePicker.date

        do {
            try context.save()

            dismiss(animated: true, completion: {
                self.nameTextField.becomeFirstResponder()
                self.delegate?.didCreateCompany(newCompany)
            })
        } catch let error {
            print("Failed to save company: \(error)")
            
            let alertController = UIAlertController(title: "Error Saving Company", message: "", preferredStyle: .alert)
            
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            
            alertController.addAction(okayAction)
            
            present(alertController, animated: true)
        }
    }
    
    private func editCompany() {
        let context = CoreDataManager.shared.persistentContainer.viewContext

        if let companyImage = companyImageView.image {
            let imageData = UIImageJPEGRepresentation(companyImage, 0.8)
            
            company?.imageData = imageData
        }
        
        guard let name = nameTextField.text, nameTextField.text != "" else {
            presentAlertController(title: "Error Creating Company", message: "Please be sure to include the company's name.")
            return
        }
        
        company?.name = name
        company?.foundedDate = foundedDatePicker.date

        do {
            try context.save()

            dismiss(animated: true, completion: {
                self.delegate?.didEditCompany(self.company!)
            })
        } catch let error {
            print("Failed to save company changes: \(error)")
        }
    }
    
    private func presentAlertController(title: String, message: String) {
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(okayAction)
        
        present(alertController, animated: true)
    }
    
}

// MARK: - Image Picker Controller Delegate
extension CreateEditCompanyViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            companyImageView.image = editedImage
            
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            companyImageView.image = originalImage
        }
        
        setupCircularImageStyle()
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
}

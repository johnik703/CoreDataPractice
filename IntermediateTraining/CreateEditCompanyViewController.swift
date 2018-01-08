//
//  CreateCompanyViewController.swift
//  IntermediateTraining
//
//  Created on 12/27/17.
//  Copyright © 2017 Damian Cesar. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import CoreData

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
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImage)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var selectImageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Select Image", for: .normal)
        button.setTitleColor(.lightRed, for: .normal)
        button.addTarget(self, action: #selector(handleSelectImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nameTextField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.placeholder = "Company Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let foundedDateTextField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nameTextField.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = company == nil ? "Create Company" : "Edit Company"
        
        foundedDateTextField.inputView = foundedDatePicker
        
        view.backgroundColor = .white
    
        setupCancelBarButtonItemInNavBar(selector: #selector(handleCancel))
        setupSaveBarButtonItemInNavBar(selector: #selector(handleSave))
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        let imageStackView = UIStackView()
        imageStackView.axis = .vertical
        imageStackView.alignment = .center
        imageStackView.spacing = 8
        imageStackView.translatesAutoresizingMaskIntoConstraints = false

        imageStackView.addArrangedSubview(companyImageView)
        imageStackView.addArrangedSubview(selectImageButton)

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

        stackView.addArrangedSubview(imageStackView)
        stackView.addArrangedSubview(textFieldStackView)

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32),
            companyImageView.widthAnchor.constraint(equalToConstant: 120),
            companyImageView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func setupCircularImageStyle() {
        companyImageView.layer.borderWidth = 2
        companyImageView.layer.borderColor = UIColor.softGray.cgColor
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
                self.delegate?.didCreateCompany(newCompany)
            })
        } catch let error {
            print("Failed to save company: \(error)")
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

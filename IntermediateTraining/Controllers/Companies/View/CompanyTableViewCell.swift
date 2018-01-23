//
//  CompanyTableViewCell.swift
//  IntermediateTraining
//
//  Created on 12/28/17.
//  Copyright © 2017 Damian Cesar. All rights reserved.
//

import UIKit

class CompanyTableViewCell: UITableViewCell {
    
    var company: Company? {
        didSet {
            nameLabel.text = company?.name
            
//            nameLabel.text = "\(company?.name ?? "") \(company?.numberOfEmployees ?? ""))"
            
            if let imageData = company?.imageData {
                companyImageView.image = UIImage(data: imageData)
            }
            
            if let foundedDate = company?.foundedDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy"

                let foundedDateString = dateFormatter.string(from: foundedDate)

                foundedDateLabel.text = "Founded: \(foundedDateString)"
            } else {
                foundedDateLabel.text = "May 13, 1996"
            }
        }
    }
    
    let companyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let foundedDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(companyImageView)

        NSLayoutConstraint.activate([
            companyImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            companyImageView.widthAnchor.constraint(equalToConstant: 50),
            companyImageView.heightAnchor.constraint(equalTo: companyImageView.widthAnchor),
            companyImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16)
        ])
        
        let companyInfostackView = UIStackView()
        companyInfostackView.axis = .vertical
        companyInfostackView.alignment = .fill
        companyInfostackView.spacing = 4
        companyInfostackView.translatesAutoresizingMaskIntoConstraints = false
        
        companyInfostackView.addArrangedSubview(nameLabel)
        companyInfostackView.addArrangedSubview(foundedDateLabel)
        
        addSubview(companyInfostackView)

        NSLayoutConstraint.activate([
            companyInfostackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            companyInfostackView.leftAnchor.constraint(equalTo: companyImageView.rightAnchor, constant: 12),
            companyInfostackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        ])
    }
    
}

//
//  ContactCell.swift
//  PickSkip
//
//  Created by Eric Duong on 7/25/17.
//  Copyright © 2017 Eric Duong. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class ContactCell: UITableViewCell {
    var contact: Contact?
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: Constants.defaultFont, size: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        return label
    }()
    
    var numberLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: Constants.defaultFont, size: 15)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.text = ""
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.layer.borderColor = UIColor.clear.cgColor
        self.backgroundColor = .white
        self.addSubview(nameLabel)
        self.addSubview(numberLabel)
        setContraints()
    }
    
    func setContraints() {
        let constraints = [
            nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: self.frame.height / 2),
            numberLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            numberLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            numberLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            numberLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    override func layoutSubviews() {
        
        self.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: .greatestFiniteMagnitude)
        if let contact = contact {
            let trimmed = (contact.firstName! + " " + contact.lastName!).replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
            nameLabel.text = trimmed
            numberLabel.text = contact.phoneNumber!
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

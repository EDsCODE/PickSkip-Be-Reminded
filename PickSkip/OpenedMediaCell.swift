//
//  UnopenedMediaCell.swift
//  PickSkip
//
//  Created by Eric Duong on 8/2/17.
//  Copyright © 2017 Eric Duong. All rights reserved.
//

import Foundation
import UIKit

class OpenedMediaCell: UITableViewCell {
    
    var media: Media!

    var nameLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: Constants.defaultFont, size: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Placeholder"
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.minimumScaleFactor = 0.3
        label.font = UIFont(name: Constants.defaultFont, size: 13)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 2
        label.text = "January 20, 2017 \n 11:15 PM"
        return label
    }()
    
    var thumbnailSpinner: SpinnerView!
    var thumbnailImageView: ThumbnailImageView!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
        self.backgroundColor = .white
        
        thumbnailSpinner = SpinnerView()
        thumbnailSpinner.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView = ThumbnailImageView()
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(thumbnailImageView)
        self.addSubview(nameLabel)
        self.addSubview(dateLabel)
        self.addSubview(thumbnailSpinner)
        setContraints()
        
    }
    
    func setContraints() {
        let constraints = [
            thumbnailSpinner.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.bounds.height * 0.8 / 2),
            thumbnailSpinner.topAnchor.constraint(equalTo: self.topAnchor, constant: 3.0),
            thumbnailSpinner.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3.0),
            thumbnailSpinner.widthAnchor.constraint(equalTo: thumbnailSpinner.heightAnchor),
            thumbnailImageView.centerXAnchor.constraint(equalTo: thumbnailSpinner.centerXAnchor),
            thumbnailImageView.centerYAnchor.constraint(equalTo: thumbnailSpinner.centerYAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailSpinner.heightAnchor, multiplier: 0.85),
            thumbnailImageView.widthAnchor.constraint(equalTo: thumbnailSpinner.widthAnchor, multiplier: 0.85),
            nameLabel.leadingAnchor.constraint(equalTo: thumbnailSpinner.trailingAnchor, constant: 15),
            nameLabel.topAnchor.constraint(equalTo: self.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            nameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.35),
            dateLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15.0),
            dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15.0),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10.0),
            dateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -self.bounds.height * 0.8 / 2)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    
    func loadAnimation() {
        thumbnailSpinner.animate()
        thumbnailSpinner.layer.strokeColor = UIColor.black.cgColor
    }
    
    func cancelAnimation() {
        self.dateLabel.textColor = .black
        self.nameLabel.textColor = .black

        thumbnailSpinner.layer.removeAllAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class TestView: UIView {
    var circleLayer: CAShapeLayer!
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        circleLayer = CAShapeLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        imageView = UIImageView()
        circleLayer = CAShapeLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.clear
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0), radius: (frame.size.width - 5)/2, startAngle: 0.0, endAngle: CGFloat(.pi * 2.0), clockwise: false)
        
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor(displayP3Red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0).cgColor
        circleLayer.lineWidth = 2.0;
        circleLayer.strokeEnd = 1.0
        

        layer.addSublayer(circleLayer)
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width * 0.8, height: self.frame.height * 0.8)
        imageView.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = (frame.size.width * 0.8)/2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView)
    }
}

class ThumbnailImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = frame.size.width / 2
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
    }
}

private class customView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
    }
}

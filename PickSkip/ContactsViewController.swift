//
//  ContactsViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/31/17.
//  Copyright © 2017 Eric Duong. All rights reserved.
//

import UIKit
import TokenField
import Contacts
import Firebase
import FA_TokenInputView



class ContactsViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    var toField: FA_TokenInputView!
    var contactTableView: UITableView!
    
    var sendButton: SendButton = {
        let button = SendButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.borderWidth = 1.5
        button.layer.borderColor = Constants.defaultBlueColor.cgColor
        button.titleLabel?.textAlignment = .center
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.titleLabel?.font = UIFont(name: Constants.defaultFont, size: 30)
        button.layer.cornerRadius = 20
        button.isHidden = true
        return button
    }()
    
    var selectedContacts: [Contact] = []
    var filtered : [Contact] = []
    var searchActive = false
    var keyboardIsActive = false
    var keyboardHeight: CGFloat = 0
    var buttonBottomConstraint: NSLayoutConstraint!
    var dateComponenets: DateComponents!
    var releaseDate: Date!
    var image: Data?
    var video: URL?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        toField = FA_TokenInputView()
        toField.translatesAutoresizingMaskIntoConstraints = false
        toField.placeholderText = "Enter a name"
        toField.drawBottomBorder = true
        toField.delegate = self
        toField.tintColor = Constants.defaultBlueColor
        toField.setColors(.black, selectedTextColor: .black, selectedBackgroundColor: Constants.defaultBlueColor)
        toField.fieldName = "To"
        toField.font = UIFont(name: Constants.defaultFont, size: 14.0)
        toField.fieldNameFont = UIFont(name: Constants.defaultFont, size: 13.0)
        toField.fieldNameColor = UIColor.black
        
        contactTableView = UITableView()
        contactTableView.translatesAutoresizingMaskIntoConstraints = false
        contactTableView.dataSource = self
        contactTableView.delegate = self
        contactTableView.isHidden = false
        let backgroundView = UIView(frame: CGRect())
        contactTableView.tableFooterView = backgroundView
        contactTableView.separatorColor = .clear
        contactTableView.register(ContactCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(contactTableView)
        self.view.addSubview(toField)
        
        let views = [
            "to": toField,
            "contacts": contactTableView,
            "topGuide": self.topLayoutGuide,
            "bottomGuide": self.bottomLayoutGuide
            ] as [String: AnyObject]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topGuide][to][contacts][bottomGuide]|", options: .directionLeadingToTrailing, metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[to]|", options: .directionLeftToRight, metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contacts]|", options: .directionLeftToRight, metrics: nil, views: views))
        self.toField.setHeightToAuto()
        
        setupSendButton()
        
        timeLabel.adjustsFontSizeToFitWidth = true
        infoLabel.adjustsFontSizeToFitWidth = true
        timeLabel.lineBreakMode = .byWordWrapping
        timeLabel.textAlignment = .right
        timeLabel.numberOfLines = 0
        timeLabel.text = dateToString(dateComponents: dateComponenets)
        timeLabel.sizeToFit()
        
        self.navigationItem.titleView?.tintColor = .blue
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "Raleway-Light", size: 15.0)!
            ], for: .normal)
        
        setupKeyboardObserver()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        toField.removeAllTokens()
        selectedContacts = []
    }
    
    func dateToString(dateComponents: DateComponents) -> String {
        var timeString = ""
        if dateComponents.year == 0 && dateComponents.month == 0 && dateComponents.day == 0 && dateComponents.hour == 0 && dateComponents.minute == 0 {
            infoLabel.text = "Your message will arrive"
            return "now"
        }
        if let year = dateComponents.year, year != 0 {
            timeString += (year == 1) ? String(describing: year) + " year" + "\n" : String(describing: year) + " years" + "\n"
        }
        if let month = dateComponents.month, month != 0 {
            timeString += (month == 1) ? String(describing: month) + " month" + "\n" : String(describing: month) + " months" + "\n"
        }
        if let day = dateComponents.day, day != 0 {
            timeString += (day == 1) ? String(describing: day) + " day" + "\n" : String(describing: day) + " days" + "\n"
        }
        if let hour = dateComponents.hour, hour != 0 {
            timeString += (hour == 1) ? String(describing: hour) + " hour" + "\n" : String(describing: hour) + " hours" + "\n"
        }
        if let minute = dateComponents.minute, minute != 0 {
            timeString += (minute == 1) ? String(describing: minute) + " minute" + "\n" : String(describing: minute) + " minutes" + "\n"
        }
        return timeString
        
    }
    
    private func setupSendButton() {
        self.view.addSubview(sendButton)
        
        let constraints = [
            sendButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            sendButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        NSLayoutConstraint.activate(constraints)
        
        buttonBottomConstraint = NSLayoutConstraint(item: sendButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -10)
        buttonBottomConstraint?.isActive = true
        
        let sendGesture = UITapGestureRecognizer(target: self, action: #selector(sendContent(gesture:)))
        sendButton.addGestureRecognizer(sendGesture)
        
    }
    
    func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    ///Called when keyboard will be shown.
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        if !keyboardIsActive {
            UIView.animate(withDuration: keyboardAnimationDuration, animations: {
                self.buttonBottomConstraint.constant = -(keyboardSize?.height)! - 10
                self.view.layoutIfNeeded()
                self.keyboardIsActive = true
            })
        }
    }
    
    ///Called when keyboard will be hidden.
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        if keyboardIsActive {
            UIView.animate(withDuration: keyboardAnimationDuration, animations: {
                self.buttonBottomConstraint.constant = -10
                self.view.layoutIfNeeded()
                self.keyboardIsActive = false
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSendButton(){
        print("updating send button")
        print(selectedContacts)
        if selectedContacts.count == 0 {
            sendButton.isHidden = true
            contactTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        } else {
            print("showing button")
            sendButton.isHidden = false
            self.view.bringSubview(toFront: sendButton)
            contactTableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        dateComponenets = nil
        releaseDate = nil
    }
    
    @objc func sendContent(gesture: UITapGestureRecognizer) {
        var recipients: [String] = []
        for selectedContact in selectedContacts {
            if let phoneNumeber = selectedContact.phoneNumber {
                recipients.append(phoneNumeber)
            }
            
        }

        
        if let videoURL = video {
            let videoName = "\(NSUUID().uuidString)\(videoURL)"
            let ref = DataService.instance.videosStorageRef.child(videoName)
            _ = ref.putFile(from: videoURL, metadata: nil, completion: { (metadata, error) in
                if let error = error {
                    print("error: \(error.localizedDescription)")
                } else {
                    let downloadURL = metadata?.downloadURL()
                    DataService.instance.sendMedia(senderNumber: Auth.auth().currentUser!.providerData[0].phoneNumber!, recipients: recipients, mediaURL: downloadURL!, mediaType: "video", releaseDate: Int(self.releaseDate.timeIntervalSince1970))
                }
            })
        } else if let image = image {
            let uid = NSUUID().uuidString
            let ref = DataService.instance.imagesStorageRef.child("\(uid).jpg")
            _ = ref.putData(image, metadata: nil, completion: {(metadata, error) in
                if let error  = error {
                    print("error: \(error.localizedDescription))")
                } else {
                    let downloadURL = metadata?.downloadURL()
                    DataService.instance.sendMedia(senderNumber: Auth.auth().currentUser!.providerData[0].phoneNumber!, recipients: recipients, mediaURL: downloadURL!, mediaType: "image", releaseDate: Int(self.releaseDate.timeIntervalSince1970))
                }
            })
            
        }
        let presentingVC = self.presentingViewController as! PreviewController
        self.dismiss(animated: false, completion: {
            presentingVC.previewContent.removeExistingContent()
            presentingVC.dismiss(animated: false, completion: nil)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    

}

extension ContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //implement
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactCell
        cell.textLabel?.font = UIFont(name: Constants.defaultFont, size: 20)
        cell.textLabel?.isUserInteractionEnabled = false
        cell.detailTextLabel?.textColor = .gray
        cell.selectionStyle = .none
        
        if searchActive {
            contactTableView.isHidden = false
            infoLabel.isHidden = true
            timeLabel.isHidden = true
            
            if selectedContacts.contains(where: {$0 == filtered[indexPath.row]}) {
                cell.backgroundColor = Constants.defaultBlueColor
            } else {
                cell.backgroundColor = .white
            }
            //cell data 
            cell.contact = filtered[indexPath.row]
        } else {
            contactTableView.isHidden = true
            infoLabel.isHidden = false
            timeLabel.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //implement
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        } else {
            return Constants.contacts.count
        }
    }
    
}

extension ContactsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ContactCell {
            if selectedContacts.contains(cell.contact!) {
                toField.removeToken(token: FA_Token(displayText: cell.nameLabel.text!, baseObject: cell.contact!))
                toField.getTextFieldView().text = ""
                if selectedContacts.isEmpty {
                    tableView.isHidden = true
                }
                toField.reloadInputViews()
                cell.backgroundColor = .clear
                cell.detailTextLabel?.textColor = .gray
            } else {
                toField.addToken(token: FA_Token(displayText: cell.nameLabel.text!, baseObject: cell.contact!))
                toField.reloadInputViews()
                cell.backgroundColor = Constants.defaultBlueColor
                cell.detailTextLabel?.textColor = .white
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ContactCell {
            if selectedContacts.isEmpty {
                tableView.isHidden = true
            }
            toField.reloadInputViews()
            cell.backgroundColor = .clear
        }
    }
    
}

extension ContactsViewController: FA_TokenInputViewDelegate {
    
    func tokenInputViewDidAddToken(_ view: FA_TokenInputView, token theNewToken: FA_Token) {
        NSLog("new token");
        selectedContacts.append(theNewToken.baseObject as! Contact)
        updateSendButton()
    }
    
    func tokenInputViewDidBeginEditing(_ view: FA_TokenInputView) {
        searchActive = true
    }
    
    func tokenInputViewDidChangeHeight(_ view: FA_TokenInputView, height newHeight: CGFloat) {
        
    }
    
    func tokenInputViewDidChangeText(_ view: FA_TokenInputView, text theNewText: String) {
        if theNewText.count == 0 {
            filtered.removeAll()
            filtered = Constants.contacts
            searchActive = false
        } else {
            filtered.removeAll()
            searchActive = true
            for contact in Constants.contacts {
                let nameRange: NSRange = (contact.firstName! + " " + contact.lastName! as NSString).range(of: theNewText, options: ([.caseInsensitive, .diacriticInsensitive]))
                if nameRange.location != NSNotFound {
                    filtered.append(contact)
                }
            }
        }
        contactTableView.reloadData()
        
    }
    
    func tokenInputViewDidEnditing(_ view: FA_TokenInputView) {
        searchActive = false
        view.endEditing(true)
    }
    
    func tokenInputViewDidRemoveToken(_ view: FA_TokenInputView, token removedToken: FA_Token) {
        selectedContacts = selectedContacts.filter({$0 != removedToken.baseObject as! Contact})
        print(selectedContacts)
        updateSendButton()
    }
    
    func tokenInputViewTokenForText(_ view: FA_TokenInputView, text searchToken: String) -> FA_Token? {
        return FA_Token(displayText: searchToken, baseObject: searchToken as AnyObject)
    }
    
    func tokenInputViewShouldDisplayMenuItems(_ view: FA_TokenInputView) -> Bool {
        return true
    }
    
    func tokenInputViewMenuItems(_ view: FA_TokenInputView, token: FA_Token) -> [UIMenuItem] {
        let menu = UIMenuItem(title: "Copy Email address", action: #selector(ContactsViewController.copyFromMenu(_:)))
        return [menu]
    }
    
    @objc func copyFromMenu(_ sender: AnyObject) {
        NSLog("Copy from menu called")
    }
    
}

//sets button fill to blue when pressed
class SendButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Constants.defaultBlueColor : .white
        }
    }
}

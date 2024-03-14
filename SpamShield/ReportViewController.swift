//
//  ReportViewController.swift
//  SpamShield
//
//  Created by Ethan Mohammed on 4/20/23.
//

import UIKit
import Firebase
import FirebaseDatabase

class ReportViewController: UIViewController, UITextViewDelegate {
    
    private let keywordTextField: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.layer.cornerRadius = 5.0
        textView.clipsToBounds = true
        textView.font = UIFont.systemFont(ofSize: 16.0)
        textView.textContainerInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        textView.text = "Enter spam message"
        textView.textColor = UIColor.lightGray
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Report"
        FirebaseApp.configure()

        view.addSubview(keywordTextField)
        
        let addButton = UIButton(type: .system)
        addButton.setTitle("    REPORT    ", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = .systemBlue
        addButton.layer.cornerRadius = 8
        addButton.addTarget(self, action: #selector(addSpam), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(addButton)
        
        keywordTextField.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            keywordTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            keywordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            keywordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            keywordTextField.heightAnchor.constraint(equalToConstant: 125),
            
            addButton.topAnchor.constraint(equalTo: keywordTextField.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 200),
            addButton.heightAnchor.constraint(equalToConstant: 50),
        ])

        // Set the delegate of the text view to self
        keywordTextField.delegate = self
    }
    
    @objc private func dismissKeyboard() {
        keywordTextField.resignFirstResponder()
    }
    
    @objc private func addSpam() {
        guard var keyword = keywordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !keyword.isEmpty else {
            keywordTextField.text = ""
            return
        }
        
        if keywordTextField.text == "Enter spam message" && keywordTextField.textColor == UIColor.lightGray {
            return
        }
        
        keyword = keyword.lowercased()
        let invalidCharacters = CharacterSet(charactersIn: ".#$[]/")
        keyword = keyword.components(separatedBy: invalidCharacters).joined(separator: "-")
        
        //Send to database
        
        let ref = Database.database().reference()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy HH:mm:SS AM";
        let currentDate = dateFormatter.string(from: Date())
        
        ref.child(keyword).setValue(
        [
            "Spam" : keyword,
            "Uploaded" : currentDate
        ]
        ) { (error, reference) in
            if error == nil {
                // Show a label with a confirmation message
                let confirmationLabel = UILabel()
                confirmationLabel.text = "Spam message reported successfully!"
                confirmationLabel.textColor = UIColor.white
                confirmationLabel.textAlignment = .center
                confirmationLabel.font = UIFont.systemFont(ofSize: 18.0)
                confirmationLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(1)
                confirmationLabel.layer.cornerRadius = 8.0
                confirmationLabel.clipsToBounds = true
                self.view.addSubview(confirmationLabel)
                
                confirmationLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    confirmationLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    confirmationLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 400),
                    confirmationLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                    confirmationLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                    confirmationLabel.heightAnchor.constraint(equalToConstant: 40)
                ])
                
                // Hide the label after 4 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    confirmationLabel.removeFromSuperview()
                }
            } else {
                // Show a label with an error message
                let errorLabel = UILabel()
                errorLabel.text = "Failed to report spam message"
                errorLabel.textColor = UIColor.white
                errorLabel.textAlignment = .center
                errorLabel.font = UIFont.systemFont(ofSize: 18.0)
                errorLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(1)
                errorLabel.layer.cornerRadius = 8.0
                errorLabel.clipsToBounds = true
                self.view.addSubview(errorLabel)
                
                errorLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    errorLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    errorLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 400),
                    errorLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                    errorLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                    errorLabel.heightAnchor.constraint(equalToConstant: 40)
                ])
                
                // Hide the label after 4 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    errorLabel.removeFromSuperview()
                }
            }
        }
        
        keywordTextField.text = "Enter spam message"
        keywordTextField.textColor = UIColor.lightGray
        keywordTextField.resignFirstResponder()
    }


    
    // Handle placeholder behavior when the user begins editing the text view
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    // Handle placeholder behavior when the user ends editing the text view
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter spam message"
            textView.textColor = UIColor.lightGray
        }
    }
    
}


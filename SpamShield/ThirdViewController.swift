//
//  ThirdViewController.swift
//  SpamShield
//
//  Created by Ethan Mohammed on 4/16/23.
//

import UIKit

class ThirdViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models = [BlockNums]()
    private var models2 = [AllowNums]()
    
    private let keywordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "(222) 222-2222"
        return textField
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Blocked Numbers"
        //view.backgroundColor = .systemGray6
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        view.addSubview(keywordTextField)
        //tableView.backgroundColor = UIColor.systemGray6
        
        let addButton = UIButton(type: .system)
        addButton.setTitle("    BLOCK    ", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = .systemRed
        addButton.layer.cornerRadius = 8
        addButton.addTarget(self, action: #selector(addKeyword), for: .touchUpInside)
        
        keywordTextField.keyboardType = .numberPad
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(addButton)
        
        getAllItems()
        tableView.delegate = self
        tableView.dataSource = self
    
        tableView.frame = view.bounds
        
        keywordTextField.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
                
        NSLayoutConstraint.activate([
            keywordTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            keywordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            keywordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            keywordTextField.heightAnchor.constraint(equalToConstant: 45),
            
            addButton.topAnchor.constraint(equalTo: keywordTextField.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 200),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

        ])
        tableView.separatorInset = .zero
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func dismissKeyboard() {
        keywordTextField.resignFirstResponder()
    }

    
    @objc private func addKeyword() {
        guard var keyword = keywordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !keyword.isEmpty else {
            keywordTextField.text = ""
            return
        }
        
        keyword = keyword.lowercased()
        keyword = keyword.replacingOccurrences(of: " ", with: "")
        //createItem(number: keyword)
        
        if let formatted = formatPhoneNumber(keyword) {
            createItem(number: formatted)
        } else {
            createItem(number: keyword)
        }
        
        keywordTextField.text = ""
        keywordTextField.resignFirstResponder()
    }
    
    func formatPhoneNumber(_ number: String) -> String? {
        // Remove any non-numeric characters
        let digits = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        // Remove leading +1 or 1 from the number
        var digitsWithoutPrefix = digits
        if digits.hasPrefix("+1") {
            digitsWithoutPrefix = String(digits.dropFirst(2))
        } else if digits.hasPrefix("1") {
            digitsWithoutPrefix = String(digits.dropFirst())
        }
        
        // Check if the number has 10 digits
        guard digitsWithoutPrefix.count == 10 else {
            return nil
        }
        
        // Format the number
        let formatted = "(\(digitsWithoutPrefix.prefix(3))) \(digitsWithoutPrefix.dropFirst(3).prefix(3))-\(digitsWithoutPrefix.dropFirst(6))"

        return formatted
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.textLabel?.text = model.number
        
        let iconImage = UIImage(systemName: "xmark.shield")
        cell.iconImageView.image = iconImage
        //added
        cell.showsReorderControl = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = models[indexPath.row]
            deleteItem(item: item)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        
        let sheet = UIAlertController(title: "Edit Number", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            
            let alert = UIAlertController(title: "Edit Number", message: "Enter the updated number", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { textField in
                textField.keyboardType = .numberPad
            })
            alert.textFields?.first?.text = item.number
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                }
                if let formatted = self?.formatPhoneNumber(newName) {
                    //self?.createItem(number: formatted)
                    self?.updateItem(item: item, newNum: formatted)
                } else {
                    self?.updateItem(item: item, newNum: newName)
                }
            }))
            self.present(alert, animated: true)
        }))
        present(sheet, animated: true)
    }
    
    func getAllItems() {
        do {
            models = try context.fetch(BlockNums.fetchRequest())
            models2 = try context.fetch(AllowNums.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch{
            //error
        }
    }
    
    func createItem(number: String) {
        getAllItems()
        // Check if keyword already exists in models
        if models.contains(where: { $0.number == number }) {
            // Number already exists, do nothing
            return
        }
        
        if models2.contains(where: { $0.number == number }) {
            // Keyword already exists in AllowKeywords, do nothing
            return
        }
        
        let newItem = BlockNums(context: context)
        newItem.number = number
        
        do {
            try context.save()
            getAllItems()
        } catch {
            // Handle error
        }
    }
    
    func deleteItem(item: BlockNums){
        context.delete(item)
        do{
            try context.save()
            getAllItems()
        }catch{
            //error
        }

    }
    
    func updateItem(item: BlockNums, newNum: String) {
        if models2.contains(where: { $0.number == newNum }) {
            // Keyword already exists in AllowKeywords, do nothing
            return
        }
        
        if !models.contains(where: { $0 != item && $0.number == newNum }) {
            item.number = newNum
            do {
                try context.save()
                getAllItems()
            } catch {
                // error
            }
        }
    }


}

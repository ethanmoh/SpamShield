//
//  SecondViewController.swift
//  SpamShield
//
//  Created by Ethan Mohammed on 4/16/23.
//

import UIKit


class CustomTableViewCell: UITableViewCell {
    let iconImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the icon image view
        iconImageView.contentMode = .scaleAspectFit
        contentView.addSubview(iconImageView)

    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Position the icon image view
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        let iconSize: CGFloat = 24
        iconImageView.frame = CGRect(x: contentView.bounds.width - iconSize - 16,
                                     y: (contentView.bounds.height - iconSize) / 2,
                                     width: iconSize,
                                     height: iconSize)
    }
    
}

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models = [BlockKeywords]()
    private var models2 = [AllowKeywords]()
    
    private let keywordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter new keyword"
        return textField
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Blocked Keywords"
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
        createItem(keyword: keyword)
        keywordTextField.text = ""
        keywordTextField.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.textLabel?.text = model.keyword
        let iconImage = UIImage(systemName: "xmark.shield")
        //cell.backgroundColor = .systemGray6
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
        
        let sheet = UIAlertController(title: "Edit Keyword", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            
            let alert = UIAlertController(title: "Edit Keyword", message: "Enter the updated keyword", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.keyword
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                }
                self?.updateItem(item: item, newName: newName)
            }))
            self.present(alert, animated: true)
        }))
        present(sheet, animated: true)
    }
    
    //Core Data
    
    func getAllItems() {
        do {
            models = try context.fetch(BlockKeywords.fetchRequest())
            models2 = try context.fetch(AllowKeywords.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch{
            //error
        }
    }
    
    func createItem(keyword: String) {
        // Check if keyword already exists in models
        getAllItems()
        if models.contains(where: { $0.keyword == keyword }) {
            // Keyword already exists, do nothing
            return
        }
        
        if models2.contains(where: { $0.keyword == keyword }) {
            // Keyword already exists in AllowKeywords, do nothing
            return
        }
        
        let newItem = BlockKeywords(context: context)
        newItem.keyword = keyword
        
        do {
            try context.save()
            getAllItems()
        } catch {
            // Handle error
        }
    }

    
    func deleteItem(item: BlockKeywords){
        context.delete(item)
        do{
            try context.save()
            getAllItems()
        }catch{
            //error
        }

    }
    
    func updateItem(item: BlockKeywords, newName: String) {
        // Check if the new name already exists in the models2
        if models2.contains(where: { $0.keyword == newName }) {
            // New name already exists in AllowKeywords, do nothing
            return
        }

        if !models.contains(where: { $0 != item && $0.keyword == newName }) {
            item.keyword = newName
            do {
                try context.save()
                getAllItems()
            } catch {
                // error
            }
        }
    }

}

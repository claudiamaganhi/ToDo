//
//  CategoryViewController.swift
//  ToDo
//
//  Created by Claudia Cavalini Maganhi on 25/05/20.
//  Copyright © 2020 Claudia Cavalini Maganhi. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var categories = [ListCategory]()
     let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAddListButton()
        loadCategories()
        title = Constants.navigationTitle
    }
    
    private func setAddListButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewCategory))
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    @objc func addNewCategory() {
        presentAddCategoryAlert()
    }
    
    private func presentAddCategoryAlert() {
        var textField = UITextField()
        
        let alert = UIAlertController(title: Constants.Alert.addCategory, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: Constants.Alert.add, style: .default) { _ in
            if textField.text != "" {
                self.addToCategories(name: textField.text)
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = Constants.Alert.newCategoryPlaceholder
            textField = alertTextField
        }
        
        alert.addAction(UIAlertAction(title: Constants.Alert.cancel, style: .cancel))
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func addToCategories(name: String?) {
        let newCategory = ListCategory(context: context)
        guard let categoryName = name else { return }
        newCategory.name = categoryName.capitalized
        categories.append(newCategory)
        saveCategories()
    }
    
    private func saveCategories() {
        do {
            try context.save()
        } catch let error {
            print("Couldn't save the list - Error: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    private func loadCategories(request: NSFetchRequest<ListCategory> = ListCategory.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch let error {
            print("Couldn't fetch the lists - Error: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }

}

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.categoryCell, for: indexPath)
        let category = categories[indexPath.row]
        cell.selectionStyle = .none
        cell.textLabel?.text = category.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toDoViewController = storyboard?.instantiateViewController(withIdentifier: Constants.toDoStoryboardID) as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            toDoViewController.selectedCategory = categories[indexPath.row]
            navigationController?.pushViewController(toDoViewController, animated: true)
        }
    }
    
}



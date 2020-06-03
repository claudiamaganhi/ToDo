//
//  ViewController.swift
//  ToDo
//
//  Created by Claudia Cavalini Maganhi on 25/05/20.
//  Copyright © 2020 Claudia Cavalini Maganhi. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

class ToDoListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var lists = [List]()
    var selectedCategory: ListCategory?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAddListButton()
        loadList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = selectedCategory?.name
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func setAddListButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addList))
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    @objc private func addList() {
        presentAddListAlert()
    }
    
    private func presentAddListAlert() {
        var textField = UITextField()
        
        let alert = UIAlertController(title: Constants.Alert.addItem, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: Constants.Alert.add, style: .default) { (action) in
            if textField.text != "" {
                self.addToLists(title: textField.text)
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = Constants.Alert.newItemPlaceholder
            textField = alertTextField
        }
        
        alert.addAction(UIAlertAction(title: Constants.Alert.cancel, style: .cancel))
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func addToLists(title: String?) {
        let newList = List(context: self.context)
        guard let listTitle = title else { return }
        newList.title = listTitle.capitalized
        newList.done = false
        newList.parentList = selectedCategory
        lists.append(newList)
        saveList()
    }
    
    private func saveList() {
        do {
            try context.save()
        } catch let error {
            print("Couldn't save the list - Error: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    private func loadList(request: NSFetchRequest<List> = List.fetchRequest(), predicate: NSPredicate? = nil) {
        guard let categoryName = selectedCategory?.name else { return }
        
        let categoryPredicate = NSPredicate(format: "parentList.name MATCHES %@", categoryName)
        
        if let aditionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, aditionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            lists = try context.fetch(request)
        } catch let error {
            print("Couldn't fetch the lists - Error: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
}

extension ToDoListViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.toDoCellId, for: indexPath) as! SwipeTableViewCell
        let list = lists[indexPath.row]
        cell.textLabel?.text = list.title
        cell.accessoryType =  list.done ? .checkmark : .none
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        lists[indexPath.row].done = !lists[indexPath.row].done
        saveList()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "delete") { action, indexPath in
            self.context.delete(self.lists[indexPath.row])
            self.lists.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.saveList()
        }
        
        deleteAction.image = UIImage(named: "delete")
        deleteAction.title = "Delete"
        deleteAction.textColor = .black
        
        return [deleteAction]
    }
    
}

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<List> = List.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text ?? "")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadList(request: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadList()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

//
//  ViewController.swift
//  Todoey
//
//  Created by Matej Korman on 04/05/2018.
//  Copyright © 2018 Matej Korman. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {

    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib

        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
        
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name

        guard let colourHex = selectedCategory?.colour else{ fatalError() }
        
        updateNavBar(withHexCode: colourHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "9B79E7")
       }

    //MARK: - Nav Bar setup methods
    func updateNavBar(withHexCode colourHexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exsist.")}
        
        guard let navBarColour = UIColor(hexString: colourHexCode) else { fatalError() }
        
        navBar.barTintColor = navBarColour
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColour, returnFlat: true)]
        
        searchBar.barTintColor = navBarColour
    }
    
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)/1.5) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
        }
        else {
            cell.textLabel?.text = "No Items Added."
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do{
                try realm.write {
                    item.done = !item.done
                }
            }
            catch{
                print("Error saving done status, \(error)")
            }
            
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
   
    //Mark: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in

            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }
                catch {
                    print("Error saving New Item, \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Mothods
    
    func loadItems() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemForDeletion)
                }
            }
            catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    
}

//MARK: - Search bat methods
extension ToDoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}


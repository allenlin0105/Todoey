
import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    let localRealm = try! Realm()
    var items: Results<Item>?
    var category: Category? {
        didSet {  // make sure that category have been set
            loadItems()
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("NavigationController does not exist")
        }
        
        navigationItem.title = category?.name
        if let BGColor = UIColor(hexString: category!.BGColor == "" ? "65BCF8" : category!.BGColor) {
            navBar.backgroundColor = BGColor.lighten(byPercentage: 0.2)
            navBar.tintColor = ContrastColorOf(navBar.barTintColor!, returnFlat: true)
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: navBar.tintColor!]
            searchBar.barTintColor = BGColor.lighten(byPercentage: 0.1)
        }
    }
    
    //MARK: - Add New Item
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { alertTextfield in
            alertTextfield.placeholder = "Create new item..."
            textField = alertTextfield
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add Item", style: .default) { action in
            if !(textField.text ?? "").isEmpty {
                let newItemtitle = textField.text!
                for item in self.items! {
                    if newItemtitle == item.title {
                        return
                    }
                }
                
                if let safeCategory = self.category {
                    do {
                        try self.localRealm.write({
                            let newItem = Item(title: newItemtitle)
                            safeCategory.items.append(newItem)
                        })
                    } catch {
                        print("Saving context with error: \(error)")
                    }
                }
                
                self.tableView.reloadData()
            }
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        items = category?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        self.tableView.reloadData()
    }
    
    //MARK: - Delete item by SwipeTableViewController
    override func updateModel(at indexPath: IndexPath) {
        if let deleteItem = self.items?[indexPath.row] {
            do {
                try self.localRealm.write({
                    self.localRealm.delete(deleteItem)
                })
            } catch {
                print("Deleting item with error: \(error)")
            }
        }
    }
    
    //MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let item = items?[indexPath.row] ?? nil
        
        cell.textLabel!.text = item?.title ?? "No item added yet"
        cell.accessoryType = (item?.done ?? false) ? .checkmark : .none
        
        if let categoryBGColor = category?.BGColor {
            cell.backgroundColor = UIColor(hexString: categoryBGColor == "" ? "65BCF8" : categoryBGColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(items!.count))
        }
        
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let clickedItem = self.items?[indexPath.row] {
            do {
                try self.localRealm.write {
                    clickedItem.done.toggle()
                }
            } catch {
                print("Update isDone with error: \(error)")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tableView.deselectRow(at: indexPath, animated: true)  // Click animation
            tableView.reloadData()
        }
    }
}

//MARK: - UISearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {  // Search is clicked
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!)
                      .sorted(byKeyPath: "dateCreated", ascending: true)
        searchBar.text = ""
        self.tableView.endEditing(true)
        self.tableView.reloadData()
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

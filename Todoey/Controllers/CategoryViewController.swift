
import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    lazy var localRealm = try! Realm()
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("NavigationController does not exist")
        }
        
        navBar.backgroundColor = .white
    }
    
    //MARK: - Add New Category
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            if !(textField.text ?? "").isEmpty {
                let newCategoryName = textField.text!
                for category in self.categories! {  // Check if there is duplicated category
                    if category.name == newCategoryName {
                        return
                    }
                }
                
                let newCategory = Category(name: newCategoryName, BGColor: UIColor.randomFlat().hexValue())
                self.add(newCategory)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "New Category..."
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }

    func add(_ newCategory: Category) {
        do {
            try localRealm.write({
                localRealm.add(newCategory)
            })
        } catch {
            print("Save categories with error: \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategory() {
        categories = localRealm.objects(Category.self)
        self.tableView.reloadData()
    }
    
    //MARK: - Delete data from swipe
    override func updateModel(at indexPath: IndexPath) {
        if let deleteCategory = self.categories?[indexPath.row] {
            do {
                try self.localRealm.write({
                    self.localRealm.delete(deleteCategory)
                })
            } catch {
                print("Deleting category with error: \(error)")
            }
        }
    }
    
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            cell.backgroundColor = UIColor(hexString: (category.BGColor == "" ? "65BCF8" : category.BGColor))
        }
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = self.tableView.indexPathForSelectedRow {
            destinationVC.category = categories?[indexPath.row]
        }
    }
}

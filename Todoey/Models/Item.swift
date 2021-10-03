import Foundation
import RealmSwift

class Item: Object {
    @Persisted var title: String
    @Persisted var done: Bool = false
    @Persisted var dateCreated: Date = Date()
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
}

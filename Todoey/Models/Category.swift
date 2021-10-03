import Foundation
import RealmSwift

class Category: Object {
    @Persisted var name: String = ""
    @Persisted var BGColor: String = ""
    @Persisted var items = List<Item>()
    
    convenience init(name: String, BGColor: String) {
        self.init()
        self.name = name
        self.BGColor = BGColor
    }
}

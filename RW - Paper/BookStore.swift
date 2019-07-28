import UIKit

class BookStore {
    public static var sharedInstance : BookStore = BookStore()
    
    func loadBooks(with plist: String) -> [Book] {
        var books: [Book] = []
        
        if let path = Bundle.main.path(forResource: plist, ofType: "plist") {
            if let array = NSArray(contentsOfFile: path) {
                for dict in array as! [NSDictionary] {
                    let book = Book(dict: dict)
                    books += [book]
                }
            }
        }
        
        return books
    }
}

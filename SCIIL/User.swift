import Foundation
import SQLite

struct User_DB {
    static let UserID = Expression<String>("UserID")
    static let IDLge = Expression<Int>("IDLge")
    static let FirstName = Expression<String>("FirstName")
    static let LastName = Expression<String>("LastName")
    static let IDUser = Expression<String>("IDUser")
}

class User {
    var UserID:String!
    var IDLge:Int!
    var FirstName:String!
    var LastName:String!
    var IDUser:String!
    
    init(UserID: String, IDLge: Int, FirstName :String, LastName :String, IDUser :String) {
        self.UserID = UserID
        self.IDLge = IDLge
        self.FirstName = FirstName
        self.LastName = LastName
        self.IDUser = IDUser
    }
}

import Foundation
import SQLite

struct Login_DB {
    static let IDLge = Expression<Int>("IDLge")
    static let IDUser = Expression<String>("IDUser")
    static let UserID = Expression<String>("UserID")
    static let IDModule = Expression<String>("IDModule")
    static let ModuleID = Expression<String>("ModuleID")
    static let IDSession = Expression<String>("IDSession")
    static let DashboardLink = Expression<String>("DashboardLink")
    static let DocumentationLink = Expression<String>("DocumentationLink")
    static let TABLE = Table("login")
}

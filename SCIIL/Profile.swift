import Foundation
import SQLite

struct PROFILE_DB {
    static let IDLge = Expression<Int>("IDLge")
    static let IDModule = Expression<String>("IDModule")
    static let ModuleID = Expression<String>("ModuleID")
    static let DashboardLink = Expression<String>("DashboardLink")
    static let DocumentationLink = Expression<String>("DocumentationLink")
    static let ModuleDesc = Expression<String>("ModuleDesc")
    static let WebServiceLink = Expression<String>("WebServiceLink")
    static let TABLE = Table("profile")
}

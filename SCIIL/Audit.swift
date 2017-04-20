import Foundation
import SQLite

struct Audit_DB {
    static let UserID = Expression<String>("UserID")
    static let MachineID = Expression<String>("MachineID")
    static let Planned = Expression<String>("Planned")
    static let Started = Expression<String>("Started")
    static let IDLPAAudit = Expression<String>("IDLPAAudit")
    static let IDUser = Expression<String>("IDUser")
    static let IDDoc = Expression<String>("IDDoc")
    static let IDMachine = Expression<String>("IDMachine")
    static let IDLge = Expression<Int>("IDLge")
    static let Syncing = Expression<Bool>("Syncing")
    static let Started_IDUser = Expression<String>("Started_IDUser")
    static let Started_UserID = Expression<String>("Started_UserID")
    static let TABLE = Table("audit")
}

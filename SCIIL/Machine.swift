import Foundation
import SQLite

struct Machine_DB {
    static let IDDoc = Expression<String>("IDDoc")
    static let IDMachine = Expression<String>("IDMachine")
    static let MachineDesc = Expression<String>("MachineDesc")
    static let MachineID = Expression<String>("MachineID")
    static let TABLE = Table("machine")
}

class Machine {
    var IDDoc:String!
    var IDMachine:String!
    var MachineDesc:String!
    var MachineID:String!
    
    init(IDDoc:String, IDMachine:String, MachineDesc:String, MachineID:String) {
        self.IDDoc = IDDoc
        self.IDMachine = IDMachine
        self.MachineDesc = MachineDesc
        self.MachineID = MachineID
    }
}

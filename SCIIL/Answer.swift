import Foundation
import SQLite

struct Answer_DB {
    static let Closed = Expression<Int>("Closed")
    static let IDAnsweredBy = Expression<String>("IDAnsweredBy")
    static let Ok = Expression<Int>("Ok")
    static let IDDoc = Expression<String>("IDDoc")
    static let Answered = Expression<String>("Answered")
    static let Info1 = Expression<String>("Info1")
    static let IDLPAAudit = Expression<String>("IDLPAAudit")
    static let ImmediatelyCorrected = Expression<Int>("ImmediatelyCorrected")
    static let NotOk = Expression<Int>("NotOk")
    static let QuestionID = Expression<String>("QuestionID")
    static let TABLE = Table("answer")
}

class Answer {
    var Closed:Int!
    var IDAnsweredBy:String!
    var Ok:Int!
    var IDDoc:String!
    var Answered:String!
    var Info1:String!
    var IDLPAAudit:String!
    var ImmediatelyCorrected:Int!
    var NotOk:Int!
    var QuestionID:String!
    
    init(Closed :Int, IDAnsweredBy :String, Ok :Int, IDDoc :String, Answered :String, Info1 :String, IDLPAAudit: String, ImmediatelyCorrected :Int, NotOk :Int, QuestionID:String) {
        self.Closed = Closed
        self.IDAnsweredBy = IDAnsweredBy
        self.Ok = Ok
        self.IDDoc = IDDoc
        self.Answered = Answered
        self.Info1 = Info1
        self.IDLPAAudit = IDLPAAudit
        self.ImmediatelyCorrected = ImmediatelyCorrected
        self.NotOk = NotOk
        self.QuestionID = QuestionID
    }
    
    func equals (compareTo:Answer) -> Bool {
        return
            self.Closed == compareTo.Closed &&
            self.IDAnsweredBy == compareTo.IDAnsweredBy &&
            self.Ok == compareTo.Ok &&
            self.IDDoc == compareTo.IDDoc &&
            self.Answered == compareTo.Answered &&
            self.Info1 == compareTo.Info1 &&
            self.IDLPAAudit == compareTo.IDLPAAudit &&
            self.ImmediatelyCorrected == compareTo.ImmediatelyCorrected &&
            self.NotOk == compareTo.NotOk &&
            self.QuestionID == compareTo.QuestionID
    }
}

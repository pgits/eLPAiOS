import Foundation
import SQLite

struct NotSavedAnswers_DB {
    static let IDChapter = Expression<String>("IDChapter")
    static let Answered = Expression<String>("Answered")
    static let IDAnsweredBy = Expression<String>("IDAnsweredBy")
    static let IDDoc = Expression<String>("IDDoc")
    static let IDLPAAudit = Expression<String>("IDLPAAudit")
    static let ImmediatelyCorrected = Expression<Int>("ImmediatelyCorrected")
    static let NotOk = Expression<Int>("NotOk")
    static let Ok = Expression<Int>("Ok")
    static let IDQuestion = Expression<String>("IDQuestion")
    static let Info1 = Expression<String>("Info1")
    static let TABLE = Table("notsavedanswers")
}

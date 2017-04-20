import Foundation
import SQLite

struct Question_DB {
    static let IDQuestion = Expression<String>("IDQuestion")
    static let Chapter = Expression<String>("Chapter")
    static let QuestionDesc = Expression<String>("IDDQuestionDescoc")
    static let IDDoc = Expression<String>("IDDoc")
    static let Info1 = Expression<String>("Info1")
    static let QuestionID = Expression<String>("QuestionID")
    static let IDParentQuestion = Expression<String>("IDParentQuestion")
    static let IDChapter = Expression<String>("IDChapter")
    static let TABLE = Table("question")
}

class Question {
    var IDQuestion:String!
    var Chapter:String!
    var QuestionDesc:String!
    var IDDoc:String!
    var Info1:String!
    var QuestionID:String!
    var IDParentQuestion:String!
    var IDChapter:String!
    
    init(IDQuestion:String, Chapter:String, QuestionDesc:String, IDDoc:String, Info1:String, QuestionID:String, IDParentQuestion:String, IDChapter:String) {
        self.IDQuestion = IDQuestion
        self.Chapter = Chapter
        self.QuestionDesc = QuestionDesc
        self.IDDoc = IDDoc
        self.Info1 = Info1
        self.QuestionID = QuestionID
        self.IDParentQuestion = IDParentQuestion
        self.IDChapter = IDChapter
    }
}

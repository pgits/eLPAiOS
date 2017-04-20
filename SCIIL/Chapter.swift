import Foundation
import SQLite

struct Chapter_DB {
    static let ChapterDesc = Expression<String>("ChapterDesc")
    static let IDChapter = Expression<String>("IDChapter")
    static let ChapterID = Expression<String>("ChapterID")
    static let Info1 = Expression<String>("Info1")
    static let TABLE = Table("chapter")
}

class Chapter {
    var ChapterDesc:String!
    var IDChapter:String!
    var ChapterID:String!
    var Info1:String!
    
    init(ChapterDesc :String, IDChapter :String, ChapterID :String, Info1 :String) {
        self.ChapterDesc = ChapterDesc
        self.IDChapter = IDChapter
        self.ChapterID = ChapterID
        self.Info1 = Info1
    }
}

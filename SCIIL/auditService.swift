import UIKit
import Foundation
import SQLite
import Alamofire
import SwiftyJSON

extension String {
    func chopPrefix(_ count: Int = 1) -> String {
        return substring(from: characters.index(startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return substring(to: characters.index(endIndex, offsetBy: -count))
    }
}

class auditService {
    
    func resetAuditStatus(AuditID: String, Module: String, IDLge:Int, User: String) {
        let parameters :Parameters = ["Parameter1":AuditID, "Module":["IDModule":Module], "User":["IDLge":IDLge, "IDUser":User]]
        
        Alamofire.request("\(Config.DEFAULTS.string(forKey: "WS_URL")!)/LPAWebService/Web/ResetLPAAuditStatus", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            guard let json = response.result.value as? [String: Any] else {
                print("didn't get object as JSON from API")
                print("Error: \(response.result.error)")
                return
            }
            
            let jsonObj = JSON(json)
            print(jsonObj)
        }
    }
    
    func getAuditsList(Session :String, Module :String, Lge :Int, User :String, UserAuditor: String, Machine :String, DateFrom :String, DateTo :String){
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        let db = try! Connection("\(path)/\(Config.DB_FILE)")
        
        try! db.run(Audit_DB.TABLE.create(ifNotExists: true) { t in
            t.column(Audit_DB.IDLPAAudit)
            t.column(Audit_DB.IDDoc)
            t.column(Audit_DB.IDMachine)
            t.column(Audit_DB.MachineID)
            t.column(Audit_DB.Planned)
            t.column(Audit_DB.Started)
            t.column(Audit_DB.IDLge)
            t.column(Audit_DB.IDUser)
            t.column(Audit_DB.UserID)
            t.column(Audit_DB.Syncing)
            t.column(Audit_DB.Started_IDUser)
            t.column(Audit_DB.Started_UserID)
        })
        
        let fromDate :String = "/Date(\(DateFrom))/"
        let toDate :String = "/Date(\(DateTo))/"
        
        let parameters :Parameters = ["IDSession":Session, "Module":["IDModule":Module], "Parameter1":["IDMachine":Machine, "IDUser":UserAuditor, "Planned":["DateFrom":fromDate, "DateTo":toDate]], "User":["IDLge":Lge, "IDUser":User]]

        Alamofire.request("\(Config.DEFAULTS.string(forKey: "WS_URL")!)/LPAWebService/Web/LoadAuditsList", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            guard let json = response.result.value as? [String: Any] else {
                print("didn't get object as JSON from API")
                print("Error: \(response.result.error)")
                return
            }
            
            var jsonObj = JSON(json)
            print(jsonObj)
            if let resultArray = jsonObj["Result1"].array {
                for resultDict in resultArray {
                    let IDLPAAudit_JSON: String! = resultDict["IDLPAAudit"].string
                    let IDDoc_JSON: String! = resultDict["Machine"]["IDDoc"].string
                    let IDMachine_JSON: String! = resultDict["Machine"]["IDDoc"].string
                    let MachineID_JSON: String! = resultDict["Machine"]["MachineID"].string
                    let Planned_JSON: String! = resultDict["Planned"].string
                    let Started_JSON: String! = resultDict["Started"].string
                    let IDLge_JSON: Int! = resultDict["User"]["IDLge"].int
                    let IDUser_JSON: String! = resultDict["User"]["IDUser"].string
                    let UserID_JSON: String! = resultDict["User"]["UserID"].string
                    let Started_IDUser_JSON: String! = resultDict["StartedBy"]["IDUser"].string
                    let Started_UserID_JSON: String! = resultDict["StartedBy"]["UserID"].string
                    
                    var Started_String: String!
                    if(Started_JSON == nil){
                        Started_String = "null"
                    }else{
                        Started_String = Started_JSON.chopPrefix(6).chopSuffix(2)
                    }

                    let insert = Audit_DB.TABLE.insert(or: .replace, Audit_DB.IDLPAAudit <- IDLPAAudit_JSON, Audit_DB.IDDoc <- IDDoc_JSON, Audit_DB.IDMachine <- IDMachine_JSON, Audit_DB.MachineID <- MachineID_JSON, Audit_DB.Planned <- Planned_JSON.chopPrefix(6).chopSuffix(2), Audit_DB.Started <- Started_String, Audit_DB.IDLge <- IDLge_JSON, Audit_DB.IDUser <- IDUser_JSON, Audit_DB.UserID <- UserID_JSON, Audit_DB.Syncing <- false, Audit_DB.Started_IDUser <- Started_IDUser_JSON, Audit_DB.Started_UserID <- Started_UserID_JSON)
                    _ = try! db.run(insert)
                }
            }
        }
    }
    
    func getQuestions(AuditID :String, callback: @escaping (_ isOK: Bool, _ jsonDATA: JSON) -> ()) -> (){
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        let db = try! Connection("\(path)/\(Config.DB_FILE)")
        let login = Table("login")
        
        let IDSession = Expression<String>("IDSession")
        let IDModule = Expression<String>("IDModule")
        let IDLge = Expression<Int>("IDLge")
        let IDUser = Expression<String>("IDUser")
        
        var IDSession_DB:String!
        var IDModule_DB:String!
        var IDLge_DB:Int!
        var IDUser_DB:String!
        
        if let logins = try! db.pluck(login) {
            IDSession_DB = logins[IDSession]
            IDModule_DB = logins[IDModule]
            IDLge_DB = logins[IDLge]
            IDUser_DB = logins[IDUser]
        }
        
        let parameters :Parameters = ["IDSession": IDSession_DB, "Module":["IDModule":IDModule_DB!], "Parameter1":AuditID, "User":["IDLge": IDLge_DB, "IDUser":IDUser_DB]]
        
        Alamofire.request("\(Config.DEFAULTS.string(forKey: "WS_URL")!)/LPAWebService/Web/LoadLPAAudit", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            guard let json = response.result.value as? [String: Any] else {
                print("didn't get object as JSON from API")
                print("Error: \(response.result.error)")
                let jsonError:JSON = ["error": true]
                callback(false, JSON(jsonError))
                return
            }
            callback(true, JSON(json))
        }
    }
    
    func getImageBase64(imageID :String, callback: @escaping (_ imageValue:JSON) -> () ) -> (){
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        
        let IDSession = Expression<String>("IDSession")
        let IDModule = Expression<String>("IDModule")
        let IDLge = Expression<Int>("IDLge")
        let IDUser = Expression<String>("IDUser")
        
        var IDSession_DB:String!
        var IDModule_DB:String!
        var IDLge_DB:Int!
        var IDUser_DB:String!
        
        if let logins = try! db.pluck(Login_DB.TABLE) {
            IDSession_DB = logins[IDSession]
            IDModule_DB = logins[IDModule]
            IDLge_DB = logins[IDLge]
            IDUser_DB = logins[IDUser]
        }
        
        let parameters :Parameters = ["IDSession": IDSession_DB, "Module":["IDModule":IDModule_DB!], "Parameter1":imageID, "User":["IDLge": IDLge_DB, "IDUser":IDUser_DB]]

        Alamofire.request("\(Config.DEFAULTS.string(forKey: "WS_URL")!)/CommWebService/Web/GetImageBase64", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            guard let json = response.result.value as? [String: Any] else {
                print("didn't get object as JSON from API")
                print("Error: \(response.result.error)")
                return
            }
            
            var jsonObj = JSON(json)
            callback(jsonObj["Result1"])
        }
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func saveImageBase64(imageCache: UIImage, auditID: String, questID: String, callback: @escaping (_ newIDDoc:JSON) -> () ) -> (){
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        let db = try! Connection("\(path)/\(Config.DB_FILE)")
        
        var IDSession_DB:String!
        var IDModule_DB:String!
        var IDLge_DB:Int!
        var IDUser_DB:String!
        
        if let logins = try! db.pluck(Login_DB.TABLE) {
            IDSession_DB = logins[Login_DB.IDSession]
            IDModule_DB = logins[Login_DB.IDModule]
            IDLge_DB = logins[Login_DB.IDLge]
            IDUser_DB = logins[Login_DB.IDUser]
        }
        let IDRef = auditID+questID
        let imageFilename = randomString(length: 6)+".jpg"
        
        var convertedImage :String!
        
        if let userPhoto:UIImage = imageCache as UIImage!{
            let imageData:NSData = UIImagePNGRepresentation(userPhoto)! as NSData
            convertedImage = imageData.base64EncodedString()
        }
        
        let parameters :Parameters = ["IDSession": IDSession_DB, "Module":["IDModule":IDModule_DB!], "Parameter1":IDRef, "Parameter2": imageFilename, "Parameter3": convertedImage, "User":["IDLge": IDLge_DB, "IDUser":IDUser_DB]]
        
        Alamofire.request("\(Config.DEFAULTS.string(forKey: "WS_URL")!)/CommWebService/Web/SaveImageBase64", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            guard let json = response.result.value as? [String: Any] else {
                print("didn't get object as JSON from API")
                print("Error: \(response.result.error)")
                return
            }
            
            var jsonObj = JSON(json)

            if(jsonObj["Message"] == "Success"){
                jsonObj["Result1"]["error"] = JSON(false)
                callback(jsonObj["Result1"])
            }else{
                jsonObj["error"] = JSON(true)
                print(jsonObj)
                callback(jsonObj)
            }
        }
    }
    
    func saveAnswersOffline(callback: @escaping (_ save:Bool, _ IDAudit:String) -> ()) -> () {
        var IDSession:String!
        var IDModule:String!
        var IDLge:Int!
        var IDUser:String!
        
        let DB_CONNECTION = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        if let logins = try! DB_CONNECTION.pluck(Login_DB.TABLE) {
            IDSession = logins[Login_DB.IDSession]
            IDModule = logins[Login_DB.IDModule]
            IDLge = logins[Login_DB.IDLge]
            IDUser = logins[Login_DB.IDUser]
        }
        var generetedJSON:Parameters!
        
        let str2 = "{\"IDSession\":\"\(IDSession!)\", \"Module\":{\"IDModule\":\"\(IDModule!)\"},\"Parameter1\":{\"AuditQuestions\": ["
        
        var IDLPAAudit:String!
        var arrayString = [String]()
        var startedDate:String!
        
        NotificationHelper.uploadAuditPhoto()
        for answer in try! DB_CONNECTION.prepare(NotSavedAnswers_DB.TABLE) {
            let fileName = answer[NotSavedAnswers_DB.IDDoc]
            if(fileName.contains(find: "userphoto") == true) {
                let photoToSave = ImageHelper.getImage(fileName: fileName)
                
                self.saveImageBase64(imageCache: photoToSave, auditID: answer[NotSavedAnswers_DB.IDLPAAudit], questID: answer[NotSavedAnswers_DB.IDQuestion]) { (jsonDATA) in
                    
                    if(jsonDATA["error"].bool! == false){
                        let saveToDB = NotSavedAnswers_DB.TABLE.filter(NotSavedAnswers_DB.IDDoc == answer[NotSavedAnswers_DB.IDDoc])
                        
                        _ = try! DB_CONNECTION.run(saveToDB.update(NotSavedAnswers_DB.IDDoc <- jsonDATA["IDDoc"].string!))
                        ImageHelper.renameImage(oldFile: fileName, newFile: jsonDATA["IDDoc"].string!)
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            for answer in try! DB_CONNECTION.prepare(NotSavedAnswers_DB.TABLE) {
                if(answer[NotSavedAnswers_DB.Answered] != "") {
                    var info1_string = answer[NotSavedAnswers_DB.Info1].replacingOccurrences(of:"\n", with: "\\n")
                    let str4 = "{\"Chapter\": {\"IDChapter\": \"\(answer[NotSavedAnswers_DB.IDChapter])\"}, \"Questions\" : [{\"Answer\": {\"Answered\": \"\(answer[NotSavedAnswers_DB.Answered])\", \"IDAnsweredBy\": \"\(answer[NotSavedAnswers_DB.IDAnsweredBy])\", \"IDDoc\": \"\(answer[NotSavedAnswers_DB.IDDoc])\", \"IDLPAAudit\": \"\(answer[NotSavedAnswers_DB.IDLPAAudit])\", \"ImmediatelyCorrected\": \(answer[NotSavedAnswers_DB.ImmediatelyCorrected]), \"Info1\": \"\(info1_string)\", \"NotOk\": \(answer[NotSavedAnswers_DB.NotOk]), \"Ok\": \(answer[NotSavedAnswers_DB.Ok])}, \"Question\": {\"IDQuestion\": \"\(answer[NotSavedAnswers_DB.IDQuestion])\"}}]}"
                    arrayString.append(str4)
                }
                IDLPAAudit = answer[NotSavedAnswers_DB.IDLPAAudit]
                startedDate = answer[NotSavedAnswers_DB.Answered]
            }
            let last_str = "], \"IDLPAAudit\": \"\(IDLPAAudit!)\"}, \"User\": {\"IDLge\": \(IDLge!), \"IDUser\": \"\(IDUser!)\"}}"
            let seperator = ","
            let mergedArray = arrayString.joined(separator: seperator)
            let str3 = str2+mergedArray+last_str
            
            let saveToDB = Audit_DB.TABLE.filter(Audit_DB.IDLPAAudit == IDLPAAudit)
            _ = try! DB_CONNECTION.run(saveToDB.update(Audit_DB.Started <- startedDate))
            
            generetedJSON = self.convertToDictionary(text: str3)
            
            Alamofire.request("\(Config.DEFAULTS.string(forKey: "WS_URL")!)/LPAWebService/Web/SaveLPAAudit", method: .post, parameters: generetedJSON, encoding: JSONEncoding.default).responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    print("didn't get object as JSON from API")
                    print("Error: \(response.result.error)")
                    return
                }
                
                var jsonObj = JSON(json)

                if(jsonObj["Message"].string! == "Successful"){
                    callback(true, IDLPAAudit)
                }else{
                    callback(false, IDLPAAudit)
                }
            }
        }
    }
    
    func saveAnswers(answersArray: [String: Answer], savePhoto: NSCache<NSString, UIImage>, callback: @escaping (_ saved:Bool) -> ()) -> () {
        var IDSession:String!
        var IDModule:String!
        var IDLge:Int!
        var IDUser:String!
    
        let DB_CONNECTION = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        if let logins = try! DB_CONNECTION.pluck(Login_DB.TABLE) {
            IDSession = logins[Login_DB.IDSession]
            IDModule = logins[Login_DB.IDModule]
            IDLge = logins[Login_DB.IDLge]
            IDUser = logins[Login_DB.IDUser]
        }
        var generetedJSON:Parameters!
        
        let str2 = "{\"IDSession\":\"\(IDSession!)\", \"Module\":{\"IDModule\":\"\(IDModule!)\"},\"Parameter1\":{\"AuditQuestions\": ["
        
        var IDLPAAudit:String!
        var startedDate:String!
        var arrayString = [String]()

        var showNotification:Bool = false
        for (questID, answer) in answersArray {
            if savePhoto.object(forKey: questID as NSString) != nil{
                if(answer.IDDoc! == ""){
                    showNotification = true
                }
            }
        }
        if(showNotification) {
            NotificationHelper.uploadAuditPhoto()
        }
        var endUploading:Bool = true
        var saveAudit:Bool = true
        for (questID, answer)  in answersArray {
            if let savePhoto = savePhoto.object(forKey: questID as NSString){
                if(answer.IDDoc! == ""){
                    self.saveImageBase64(imageCache: savePhoto, auditID: answer.IDLPAAudit, questID: questID) { (jsonDATA) in
                        if(jsonDATA["error"].bool! == false){
                            ImageHelper.saveImage(image: savePhoto, fileName: jsonDATA["IDDoc"].string!)
                            answer.IDDoc = jsonDATA["IDDoc"].string!
                            if(endUploading){
                                NotificationHelper.finishedPhotoUploading()
                            }
                            endUploading = false
                            saveAudit = true
                        }else{
                            NotificationHelper.cantSavePhoto()
                            saveAudit = false
                        }
                    }
                }
            }
        }

            DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
                if(saveAudit){
                    for (questID, answer) in answersArray {
                        if let question = try! DB_CONNECTION.pluck(Question_DB.TABLE.filter(Question_DB.IDQuestion == questID)){
                            if(answer.Answered! != "") {
                                let info1_string = answer.Info1!.replacingOccurrences(of:"\n", with: "\\n")
                                let str4 = "{\"Chapter\": {\"IDChapter\": \"\(question[Question_DB.IDChapter])\"}, \"Questions\" : [{\"Answer\": {\"Answered\": \"\(answer.Answered!)\", \"IDAnsweredBy\": \"\(answer.IDAnsweredBy!)\", \"IDDoc\": \"\(answer.IDDoc!)\", \"IDLPAAudit\": \"\(answer.IDLPAAudit!)\", \"ImmediatelyCorrected\": \(answer.ImmediatelyCorrected!), \"Info1\": \"\(info1_string)\", \"NotOk\": \(answer.NotOk!), \"Ok\": \(answer.Ok!)}, \"Question\": {\"IDQuestion\": \"\(questID)\"}}]}"
                                arrayString.append(str4)
                            }
                            IDLPAAudit = answer.IDLPAAudit!
                            startedDate = answer.Answered!
                        }
                    }
                    let last_str = "], \"IDLPAAudit\": \"\(IDLPAAudit!)\"}, \"User\": {\"IDLge\": \(IDLge!), \"IDUser\": \"\(IDUser!)\"}}"
                    let seperator = ","
                    let mergedArray = arrayString.joined(separator: seperator)
                    let str3 = str2+mergedArray+last_str
                    
                    let saveToDB = Audit_DB.TABLE.filter(Audit_DB.IDLPAAudit == IDLPAAudit)
                    _ = try! DB_CONNECTION.run(saveToDB.update(Audit_DB.Started <- startedDate))
                    
                    generetedJSON = self.convertToDictionary(text: str3)
                    print(generetedJSON)
                    Alamofire.request("\(Config.DEFAULTS.string(forKey: "WS_URL")!)/LPAWebService/Web/SaveLPAAudit", method: .post, parameters: generetedJSON, encoding: JSONEncoding.default).responseJSON { response in
                        
                        guard let json = response.result.value as? [String: Any] else {
                            print("didn't get object as JSON from API")
                            print("Error: \(response.result.error)")
                            return
                        }
                        
                        var jsonObj = JSON(json)
                        if(jsonObj["Message"].string! == "Successful"){
                            callback(true)
                        }else{
                            callback(false)
                        }
                    }
                }else{
                    callback(false)
                }
            }

    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func unwrapString(wrappedString :String) -> String{
        var unwrappedString = ""
        
        if let temp = String?(wrappedString) {
            unwrappedString = temp
        }
        
        return unwrappedString
    }
    
    func unwrapInt(wrappedInt :Int) -> Int{
        var unwrappedInt = 0
        
        if let temp = Int?(wrappedInt) {
            unwrappedInt = temp
        }
        
        return unwrappedInt
    }
    
    func insertChapter(chapterArray :[Chapter], db:Connection){
        let arrayCount = chapterArray.count
        let chapter = Table("chapter")
        
        try! db.run(chapter.create(ifNotExists: true) { t in
            t.column(Chapter_DB.ChapterDesc)
            t.column(Chapter_DB.IDChapter)
            t.column(Chapter_DB.ChapterID)
            t.column(Chapter_DB.Info1)
        })
        
        for i in 0...arrayCount-1 {
            let insert = chapter.insert(or: .replace,
                                        Chapter_DB.ChapterDesc <- chapterArray[i].ChapterDesc, Chapter_DB.IDChapter <- chapterArray[i].IDChapter, Chapter_DB.ChapterID <- chapterArray[i].ChapterID, Chapter_DB.Info1 <- chapterArray[i].Info1
                                        )
            _ = try! db.run(insert)
        }
    }
    
    func insertAnswer(answerArray :[Answer], db:Connection){
        let arrayCount = answerArray.count
        let answer = Table("answer")
        
        try! db.run(answer.create(ifNotExists: true) { t in
            t.column(Answer_DB.Closed)
            t.column(Answer_DB.IDAnsweredBy)
            t.column(Answer_DB.Ok)
            t.column(Answer_DB.IDDoc)
            t.column(Answer_DB.Answered)
            t.column(Answer_DB.Info1)
            t.column(Answer_DB.IDLPAAudit)
            t.column(Answer_DB.ImmediatelyCorrected)
            t.column(Answer_DB.NotOk)
            t.column(Answer_DB.QuestionID)
        })
        
        for i in 0...arrayCount-1 {
            let insert = answer.insert(or: .replace,
                                       Answer_DB.Closed <- answerArray[i].Closed,
                                       Answer_DB.IDAnsweredBy <- answerArray[i].IDAnsweredBy, Answer_DB.Ok <- answerArray[i].Ok,
                                       Answer_DB.IDDoc <- answerArray[i].IDDoc,
                                       Answer_DB.Answered <- answerArray[i].Answered,
                                       Answer_DB.Info1 <- answerArray[i].Info1,
                                       Answer_DB.IDLPAAudit <- answerArray[i].IDLPAAudit, Answer_DB.ImmediatelyCorrected <- answerArray[i].ImmediatelyCorrected,
                                       Answer_DB.NotOk <- answerArray[i].NotOk,
                                       Answer_DB.QuestionID <- answerArray[i].QuestionID
                                        )
            
            _ = try! db.run(insert)
        }
    }
    
    func insertQuestion(questionArray :[Question], db:Connection){
        let arrayCount = questionArray.count
        
        let question = Table("question")
        
        try! db.run(question.create(ifNotExists: true) { t in
            t.column(Question_DB.IDQuestion)
            t.column(Question_DB.Chapter)
            t.column(Question_DB.QuestionDesc)
            t.column(Question_DB.IDDoc)
            t.column(Question_DB.Info1)
            t.column(Question_DB.QuestionID)
            t.column(Question_DB.IDParentQuestion)
            t.column(Question_DB.IDChapter)
        })
        
        for i in 0...arrayCount-1 {
            let insert = question.insert(or: .replace,
                                         Question_DB.IDQuestion <- questionArray[i].IDQuestion, Question_DB.Chapter <- questionArray[i].Chapter, Question_DB.QuestionDesc <- questionArray[i].QuestionDesc,
                                         Question_DB.IDDoc <- questionArray[i].IDDoc, Question_DB.Info1 <- questionArray[i].Info1, Question_DB.QuestionID <- questionArray[i].QuestionID,
                                         Question_DB.IDParentQuestion <- questionArray[i].IDParentQuestion,
                                         Question_DB.IDChapter <- questionArray[i].IDChapter
                                            )
            
            _ = try! db.run(insert)
        }
    }
    
    func insertMachine(machineArray :[Machine], db:Connection){
        let arrayCount = machineArray.count
        
        let machine = Table("machine")
        
        try! db.run(machine.create(ifNotExists: true) { t in
            t.column(Machine_DB.IDDoc)
            t.column(Machine_DB.IDMachine)
            t.column(Machine_DB.MachineDesc)
            t.column(Machine_DB.MachineID)
        })
        
        for i in 0...arrayCount-1 {
            let insert = machine.insert(or: .replace,
                                        Machine_DB.IDDoc <- machineArray[i].IDDoc,
                                        Machine_DB.IDMachine <- machineArray[i].IDMachine,
                                        Machine_DB.MachineDesc <- machineArray[i].MachineDesc, Machine_DB.MachineID <- machineArray[i].MachineID
                                        )
            
            _ = try! db.run(insert)
        }
    }
    
    func insertStartedBy(startedByArray :[StartedBy], db:Connection){
        let arrayCount = startedByArray.count
        
        let startedBy = Table("startedBy")
        
        try! db.run(startedBy.create(ifNotExists: true) { t in
            t.column(StartedBy_DB.UserID)
            t.column(StartedBy_DB.IDLge)
            t.column(StartedBy_DB.FirstName)
            t.column(StartedBy_DB.LastName)
            t.column(StartedBy_DB.IDUser)
        })
        
        for i in 0...arrayCount-1 {
            let insert = startedBy.insert(or: .replace,
                                          StartedBy_DB.UserID <- startedByArray[i].UserID,
                                          StartedBy_DB.IDLge <- startedByArray[i].IDLge,
                                          StartedBy_DB.FirstName <- startedByArray[i].FirstName,
                                          StartedBy_DB.LastName <- startedByArray[i].LastName,
                                          StartedBy_DB.IDUser <- startedByArray[i].IDUser
                                        )
            
            _ = try! db.run(insert)
        }
    }
    
    func insertUser(userArray :[User], db:Connection){
        let arrayCount = userArray.count
        
        let user = Table("user")
        
        try! db.run(user.create(ifNotExists: true) { t in
            t.column(User_DB.UserID)
            t.column(User_DB.IDLge)
            t.column(User_DB.FirstName)
            t.column(User_DB.LastName)
            t.column(User_DB.IDUser)
        })
        
        for i in 0...arrayCount {
            let insert = user.insert(or: .replace,
                                     User_DB.UserID <- userArray[i].UserID,
                                     User_DB.IDLge <- userArray[i].IDLge,
                                     User_DB.FirstName <- userArray[i].FirstName,
                                     User_DB.LastName <- userArray[i].LastName,
                                     User_DB.IDUser <- userArray[i].IDUser
                                    )
            
            _ = try! db.run(insert)
        }
    }
}


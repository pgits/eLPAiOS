import Foundation
import Alamofire
import SQLite

class auditorsListService {
    func getAuditors(IDSession:String, IDModule:String, LgeID:Int, UserIDS:String) {
        
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        let auditorsList = Table("auditorsList")
        
        let FirstName = Expression<String>("FirstName")
        let IDLge = Expression<Int>("IDLge")
        let IDUser = Expression<String>("IDUser")
        let LastName = Expression<String>("LastName")
        let UserID = Expression<String>("UserID")
        
        try! db.run(auditorsList.create(ifNotExists: true) { t in
            t.column(FirstName)
            t.column(IDLge)
            t.column(IDUser)
            t.column(LastName)
            t.column(UserID, unique: true)
        })
        
        let parameters: Parameters = ["IDSession":IDSession, "Module":["IDModule":IDModule], "User":["IDLge":LgeID, "IDUser":UserIDS]]
        
        Alamofire.request("\(Config.DEFAULTS.string(forKey: "WS_URL")!)/LPAWebService/Web/LoadAuditors", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            guard let json = response.result.value as? [String: Any] else {
                print("didn't get object as JSON from API")
                print("Error: \(response.result.error)")
                return
            }
            
            if let datas = json["Result1"] as? [[String:Any]] {
                for aList in datas {
                    let insert = auditorsList.insert(or: .replace, FirstName <- aList["FirstName"] as! String, IDLge <- aList["IDLge"] as! Int, IDUser <- aList["IDUser"] as! String, LastName <- aList["LastName"] as! String, UserID <- aList["UserID"] as! String)
                
                    _ = try! db.run(insert)
                }
            }
            
        }
    }
}

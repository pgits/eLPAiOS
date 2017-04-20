import Foundation
import Alamofire
import SQLite
import SwiftyJSON

class loginService {
    var ResultCode: Int = 2
    var errorMessage: String = ""
    
    func doLogin(username:String, password:String, module:String, dashboardLink:String, documentationLink:String, callback: @escaping (_ codeResult:Int, _ messageError:String) ->() ) -> (){
        
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        
        do {
            if try db.run(Login_DB.TABLE.delete()) > 0 {
                print("deleted User")
            } else {
                print("User not found")
            }
            
        } catch {
            print("delete failed: \(error)")
        }
        
        try! db.run(Login_DB.TABLE.create(ifNotExists: true) { t in
            t.column(Login_DB.IDLge)
            t.column(Login_DB.IDUser)
            t.column(Login_DB.UserID, unique: true)
            t.column(Login_DB.IDModule)
            t.column(Login_DB.ModuleID)
            t.column(Login_DB.IDSession)
            t.column(Login_DB.DashboardLink)
            t.column(Login_DB.DocumentationLink)
        })
        
        let parameters: Parameters = ["Parameter1":username, "Parameter2":password, "Parameter3":module]
        Alamofire.request("\(Config.DEFAULTS.string(forKey: "WS_URL")!)/CommWebService/Web/UserValidate", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            guard let json = response.result.value as? [String: Any] else {
                print("didn't get object as JSON from API")
                print("Error: \(response.result.error)")
                callback(15, "error")
                return
            }
            if (json["ResultCode"] as! Int == 0){
                guard let Result1 = json["Result1"] as? [String: Any] else {
                    print("didn't get object as JSON from API")
                    print("Error: \(response.result.error)")
                    return
                }
                
                guard let Result2 = json["Result2"] as? [String: Any] else {
                    print("didn't get object as JSON from API")
                    print("Error: \(response.result.error)")
                    return
                }
                
                self.ResultCode =  0
                callback(self.ResultCode, json["Message"] as! String)
                
                let insert = Login_DB.TABLE.insert(or: .replace, Login_DB.IDLge <- Result1["IDLge"] as! Int, Login_DB.IDUser <- Result1["IDUser"] as! String, Login_DB.UserID <- Result1["UserID"] as! String, Login_DB.IDModule <- Result2["IDModule"] as! String, Login_DB.ModuleID <- Result2["ModuleID"] as! String, Login_DB.IDSession <- json["Result3"] as! String, Login_DB.DashboardLink <- dashboardLink, Login_DB.DocumentationLink <- documentationLink)
                Config.DEFAULTS.set(String(describing: Result1["UserID"]!), forKey: "username")
                _ = try! db.run(insert)
                
            }else if(json["ResultCode"] as! Int == 1){
                self.ResultCode = 1
                callback(self.ResultCode, json["Message"] as! String)
            }else{
                self.ResultCode = 2
                callback(self.ResultCode, json["Message"] as! String)
            }
        }
    }
    
    func getProfiles(callback: @escaping (_ results :JSON, _ succeed: Bool) -> ()) -> (){
        let parameters: Parameters = [:]
        
        Alamofire.request("\(Config.DEFAULTS.string(forKey: "profileWSURL")!)/CommWebService/Web/GetModuleList", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            guard let json = response.result.value as? [String: Any] else {
                print("didn't get object as JSON from API")
                print("Error: \(response.result.error)")
                callback(JSON.null, false)
                return
            }
            let jsonOBJ = JSON(json)
            
            if(jsonOBJ["ResultCode"].int == 0){
                callback(jsonOBJ["Result1"], true)
            }
        }
    }
    
    func getImageSize(callback: @escaping (_ value: String) -> ()) -> (){
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        var parameters:Parameters!
        
        if let login = try! db.pluck(Login_DB.TABLE) {
            parameters = ["IDSession":"\(login[Login_DB.IDSession])", "Module":["IDModule":"\(login[Login_DB.IDModule])"], "Parameter1":"admin", "Parameter2":"tabletimagesize", "Parameter3":"Big", "User":["IDLge":login[Login_DB.IDLge], "IDUser":"\(login[Login_DB.IDUser])"]]
        }
        
        Alamofire.request("\(Config.DEFAULTS.string(forKey: "WS_URL")!)/CommWebService/Web/GetSystemSwitch", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            guard let json = response.result.value as? [String: Any] else {
                print("didn't get object as JSON from API")
                print("Error: \(response.result.error)")
                return
            }
            let jsonOBJ = JSON(json)
            
            if(jsonOBJ["ResultCode"].int == 0){
                callback(jsonOBJ["Result1"]["Value"].string!)
            }
        }
    }
}

import Foundation
import SwiftyJSON
import Alamofire

class langService {
    
    func getLangList(callback: @escaping (_ results :JSON) -> ()) -> (){
        let parameters: Parameters = [:]
        
        Alamofire.request("\(Config.DEFAULTS.string(forKey: "WS_URL")!)/CommWebService/Web/LoadLge", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            guard let json = response.result.value as? [String: Any] else {
                print("didn't get object as JSON from API")
                print("Error: \(response.result.error)")
                callback(JSON.null)
                return
            }
            var jsonOBJ = JSON(json)
            
            if(jsonOBJ["ResultCode"].int == 0){
                callback(jsonOBJ["Result1"])
            }
        }
    }
    
    func getTranslations(langID: Int, callback: @escaping (_ results :JSON) -> ()) -> (){
        
        var arrayString = [String]()
        for (key, value) in DefaultLang.LangValues {
            let variable = "{\"Entry\": \"\(key)\", \"Module\": \"lpa\", \"Section\": \"mobile\", \"Text\": \"\(value)\"}"
            arrayString.append(variable)
        }
        let seperator = ","
        let mergedArray = arrayString.joined(separator: seperator)
        let startString = "{\"Parameter1\": \"\(langID)\", \"Parameter2\":[\(mergedArray)]}"

        let generetedJSON:Parameters = WS.AUDIT_SERVICE.convertToDictionary(text: startString)!
        
        Alamofire.request("\(Config.DEFAULTS.string(forKey: "WS_URL")!)/CommWebService/Web/TranslateTexts", method: .post, parameters: generetedJSON, encoding: JSONEncoding.default).responseJSON { response in
            
            guard let json = response.result.value as? [String: Any] else {
                print("didn't get object as JSON from API")
                print("Error: \(response.result.error)")
                return
            }
            let jsonOBJ = JSON(json)
            
            if(jsonOBJ["ResultCode"].int == 0){
                callback(jsonOBJ["Result1"])
            }
        }
    }
    
}

import Foundation
import Alamofire
import SQLite

class workstationService {
    func getWorkstations(IDSession:String, IDModule:String, LgeID:Int, UserIDS:String){
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/\(Config.DB_FILE)")
        let machinesList = Table("machinesList")
        
        let IDMachine = Expression<String>("IDMachine")
        let MachineDesc = Expression<String>("MachineDesc")
        let MachineID = Expression<String>("MachineID")
        
        try! db.run(machinesList.create(ifNotExists: true) { t in
            t.column(MachineID)
            t.column(MachineDesc)
            t.column(IDMachine, unique: true)
        })
        
        let parameters: Parameters = ["IDSession":IDSession, "Module":["IDModule":IDModule], "User":["IDLge":LgeID, "IDUser":UserIDS]]
        
        Alamofire.request("\(Config.DEFAULTS.string(forKey: "WS_URL")!)/LPAWebService/Web/LoadMachines", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            guard let json = response.result.value as? [String: Any] else {
                print("didn't get object as JSON from API")
                print("Error: \(response.result.error)")
                return
            }
            
            if let datas = json["Result1"] as? [[String:Any]] {
                for aList in datas {
                    let insert = machinesList.insert(or: .replace, IDMachine <- aList["IDMachine"] as! String, MachineDesc <- aList["MachineDesc"] as! String, MachineID <- aList["MachineID"] as! String)
                    
                    _ = try! db.run(insert)
                }
            }
            
        }
        
    }
}

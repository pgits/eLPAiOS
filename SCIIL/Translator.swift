import Foundation

public class Translator {
    // MARK: - Set language values to defaults settings
    class func setLangValues() {
        for (langKey, value) in DefaultLang.LangValues {
            if(Translator.checkIfKeyExist(key: langKey) == false) {
                Config.DEFAULTS.set(value, forKey: langKey)
            }
        }
    }
    
    // MARK: - Get language value by key
    class func getLangValue(key: String) -> String {
        return Config.DEFAULTS.string(forKey: key)!
    }
    
    // MARK: - Set language value by key
    class func setLangValue(key: String, value:String) {
        Config.DEFAULTS.set(value, forKey: key)
    }
    
    class func checkIfKeyExist(key: String) -> Bool{
        return Config.DEFAULTS.object(forKey: key) != nil
    }
    
    // MARK: - Status texts
    class func notSynced() -> String {
        return Translator.getLangValue(key: "status_not_synced")
    }
    
    class func started() -> String {
        return Translator.getLangValue(key: "status_started")
    }
    
    class func overdue() -> String {
        return Translator.getLangValue(key: "status_overdue")
    }
    
    class func planned() -> String {
        return Translator.getLangValue(key: "status_planned")
    }
    
    class func notFinished() -> String {
        return Translator.getLangValue(key: "status_not_finished")
    }
}

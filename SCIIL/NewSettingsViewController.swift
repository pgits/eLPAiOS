import UIKit
import SwiftyJSON
import SQLite
import UserNotifications

protocol SearchViewDelegate {
    func updateModule(data: String)
    func updateLanguage(data: String)
}

class NewSettingsViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate{
    // outlets
    @IBOutlet var serverURLfield: UITextField!
    @IBOutlet var serverURLtitle: UILabel!
    
    //module
    @IBOutlet var moduleArrow: UIImageView!
    @IBOutlet var moduleView: UIView!
    @IBOutlet var moduleTitle: UILabel!
    @IBOutlet var moduleName: UILabel!
    var profileSelect = [String]()
    var profileLang = [Int]()
    
    // language
    
    @IBOutlet var languageArrow: UIImageView!
    @IBOutlet var languageTitle: UILabel!
    @IBOutlet var languageName: UILabel!
    @IBOutlet var languageView: UIView!
    var languageSelect = [String]()
    var languageID = [Int]()
    var modalValue:String!
    
    var noModules:Bool!
    
    // loading
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    
    // save button
    var newSaveButton:UIButton = UIButton(type: UIButtonType.custom) as UIButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moduleName.text = ""
        languageName.text = ""
        
        // save button
        self.addSaveButton()
        
        // Translated values of objects
        self.translations()
        
        // Add tap gesture for views
        self.addTapGesture()
        
        // TexField delegate
        serverURLfield.delegate = self
        
        // only for ADIENT APP
        if(APP_FLAVOR.APP == "adient"){
            self.serverURLfield.textColor = UIColor(red:0.77, green:0.77, blue:0.77, alpha:1.0)
            Config.DEFAULTS.set(Adient.URL, forKey: "profileWSURL")
            self.serverURLfield.isUserInteractionEnabled = false
        }
        
        if (Translator.checkIfKeyExist(key: "profileWSURL") == true) {
            serverURLfield.text = Config.DEFAULTS.string(forKey: "profileWSURL")!
        }
        
        if(serverURLfield.text! != "") {
            self.profileSelect.removeAll()
            self.showActivityIndicatory(uiView: self.view)
            WS.LOGIN_SERVICE.getProfiles() { (result, succeed) in
                if(succeed == true){
                    for profilesArray in result.array! {
                        self.insertProfile(IDLge: profilesArray["IDLge"].int!, IDModule: profilesArray["IDModule"].string!, ModuleID: profilesArray["ModuleID"].string!, DashboardLink: profilesArray["DashboardLink"].string!, DocumentationLink: profilesArray["DocumentationLink"].string!, ModuleDesc: profilesArray["ModuleDesc"].string!, WebServiceLink: profilesArray["WebServiceLink"].string!)
                        self.profileSelect.append(profilesArray["ModuleID"].string!)
                        self.profileLang.append(profilesArray["IDLge"].int!)
                    }
                    
                    if(self.profileSelect.count > 0) {
                        if(Translator.checkIfKeyExist(key: "selectedModule")) {
                            self.moduleName.text = self.profileSelect[self.getSavedModuleId()]
                        }else{
                            self.moduleName.text = Translator.getLangValue(key: "select_module")
                            self.disableSaveButtonAdient()
                        }
                    }else{
                        self.moduleName.text = ""
                        self.disableSaveButton()
                    }
                    
                    let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
                    if let profile = try! db.pluck(PROFILE_DB.TABLE.filter(PROFILE_DB.ModuleID == self.moduleName.text!)) {
                        Config.DEFAULTS.set(profile[PROFILE_DB.WebServiceLink], forKey: "WS_URL")
                        self.getLanguageList(moduleChanged: false)
                    }
                }else{
                    self.view.makeToast(Translator.getLangValue(key: "could_not_download_profiles"), duration: 3.0, position: .bottom)
                    self.profileSelect.removeAll()
                    self.profileLang.removeAll()
                    self.languageSelect.removeAll()
                    self.languageID.removeAll()
                    self.moduleName.text = ""
                    self.languageName.text = ""
                    self.disableSaveButton()
                }
                self.stopActivityIndicatory()
            }
        }else{
            self.disableSaveButton()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.moduleView.backgroundColor = UIColor(red:0.00, green:0.30, blue:0.45, alpha:1.0)
        self.languageView.backgroundColor = UIColor(red:0.00, green:0.30, blue:0.45, alpha:1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTapGesture() {
        // Tap gesture for module view
        let tapGestureModule = UITapGestureRecognizer(target: self, action: #selector(moduleTap(sender:)))
        moduleView.addGestureRecognizer(tapGestureModule)
        
        // Tap gesture for language view
        let tapGestureLanguage = UITapGestureRecognizer(target: self, action: #selector(languageTap(sender:)))
        languageView.addGestureRecognizer(tapGestureLanguage)
    }
    
    func moduleTap(sender: UITapGestureRecognizer) {
        if(self.profileSelect.count > 0) {
            self.moduleView.backgroundColor = UIColor(red:0.00, green:0.25, blue:0.37, alpha:1.0)
            self.modalValue = "module"
            performSegue(withIdentifier:"searchModal", sender: self)
        }
    }
    
    func languageTap(sender: UITapGestureRecognizer) {
        if(self.languageSelect.count > 0) {
            self.languageView.backgroundColor = UIColor(red:0.00, green:0.25, blue:0.37, alpha:1.0)
            self.modalValue = "language"
            performSegue(withIdentifier:"searchModal", sender: self)
        }
    }
    
    // MARK: - textField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(serverURLfield.text!)
        if(textField == serverURLfield){
            if(textField.text?.hasHTTPS())! {
                self.profileSelect.removeAll()
                self.profileLang.removeAll()
                Config.DEFAULTS.set(textField.text!, forKey: "profileWSURL")
                self.showActivityIndicatory(uiView: self.view)
                WS.LOGIN_SERVICE.getProfiles() { (result, succeed) in
                    if(succeed == true){
                        for profilesArray in result.array! {
                            self.insertProfile(IDLge: profilesArray["IDLge"].int!, IDModule: profilesArray["IDModule"].string!, ModuleID: profilesArray["ModuleID"].string!, DashboardLink: profilesArray["DashboardLink"].string!, DocumentationLink: profilesArray["DocumentationLink"].string!, ModuleDesc: profilesArray["ModuleDesc"].string!, WebServiceLink: profilesArray["WebServiceLink"].string!)
                            self.profileSelect.append(profilesArray["ModuleID"].string!)
                            self.profileLang.append(profilesArray["IDLge"].int!)
                        }

                        if(self.profileSelect.count > 0){
                            self.moduleName.text = Translator.getLangValue(key: "select_module")
                            self.enableSaveButton()
                            self.disableSaveButtonAdient()
                        }else{
                            self.moduleName.text = ""
                            self.languageName.text = ""
                            self.languageSelect.removeAll()
                            self.languageID.removeAll()
                            self.disableSaveButton()
                        }
                        
                        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
                        if let profile = try! db.pluck(PROFILE_DB.TABLE.filter(PROFILE_DB.ModuleID == self.moduleName.text!)) {
                            Config.DEFAULTS.set(profile[PROFILE_DB.WebServiceLink], forKey: "WS_URL")
                            self.getLanguageList(moduleChanged: false)
                        }
                    }else{
                        self.view.makeToast(Translator.getLangValue(key: "could_not_download_profiles"), duration: 3.0, position: .bottom)
                        self.profileSelect.removeAll()
                        self.profileLang.removeAll()
                        self.languageSelect.removeAll()
                        self.languageID.removeAll()
                        self.moduleName.text = ""
                        self.languageName.text = ""
                        self.disableSaveButton()
                    }
                    self.stopActivityIndicatory()
                }
            }else{
                self.view.makeToast(Translator.getLangValue(key: "invalid_server_url"), duration: 3.0, position: .bottom)
                self.profileSelect.removeAll()
                self.profileLang.removeAll()
                self.languageSelect.removeAll()
                self.languageID.removeAll()
                self.moduleName.text = ""
                self.languageName.text = ""
                self.disableSaveButton()
            }
        }
    }
    
    func disableSaveButton() {
        self.newSaveButton.isEnabled = false
        self.newSaveButton.isUserInteractionEnabled = false
        self.newSaveButton.alpha = 0.5
        self.moduleTitle.alpha = 0.5
        self.languageTitle.alpha = 0.5
        self.moduleArrow.alpha = 0.5
        self.languageArrow.alpha = 0.5
        self.noModules = true
    }
    
    func disableSaveButtonAdient() {
        self.newSaveButton.isEnabled = false
        self.newSaveButton.isUserInteractionEnabled = false
        self.newSaveButton.alpha = 0.5
        self.noModules = true
        self.languageTitle.alpha = 0.5
        self.languageArrow.alpha = 0.5
    }
    
    func enableSaveButton() {
        self.newSaveButton.isEnabled = true
        self.newSaveButton.isUserInteractionEnabled = true
        self.newSaveButton.alpha = 1.0
        self.moduleTitle.alpha = 1.0
        self.languageTitle.alpha = 1.0
        self.moduleArrow.alpha = 1.0
        self.languageArrow.alpha = 1.0
        self.noModules = false
    }
    
    func disableLanguageView() {
        self.newSaveButton.isEnabled = false
        self.newSaveButton.isUserInteractionEnabled = false
        self.newSaveButton.alpha = 0.5
        self.languageTitle.alpha = 0.5
        self.languageArrow.alpha = 0.5
    }
    
    // MARK: - Get Language list
    func getLanguageList (moduleChanged: Bool) {
        self.showActivityIndicatory(uiView: self.view)
        WS.LANGUAGE_SERVICE.getLangList() { (results) in
            self.languageSelect.removeAll()
            self.languageID.removeAll()
            if(results == JSON.null) {
                self.stopActivityIndicatory()
                self.languageName.text = ""
                self.disableLanguageView()
            }else{
                for object in results.array! {
                    self.languageSelect.append(object["LgeDesc"].string!)
                    self.languageID.append(object["IDLge"].int!)
                }
                
                if(self.languageSelect.count > 0){
                    self.languageName.text = self.languageSelect[self.getLanguageId()]
                    if(!moduleChanged) {
                        if(Translator.checkIfKeyExist(key: "selectedLanguage")) {
                            self.languageName.text = self.languageSelect[self.getSavedLanguageId()]
                        }
                    }
                }else{
                    self.languageName.text = ""
                    self.disableLanguageView()
                }
                self.stopActivityIndicatory()
            }

        }
    }
    
    // MARK: - Prepare seque for open Audit
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "searchModal") {
            let viewController = segue.destination as! SearchTableViewController
            if(modalValue == "module") {
                viewController.tableData = profileSelect
                viewController.modalValue = modalValue
                viewController.selectedValue = moduleName.text!
                viewController.searchDelegate = self
            }
            
            if(modalValue == "language") {
                viewController.tableData = languageSelect
                viewController.modalValue = modalValue
                viewController.selectedValue = languageName.text!
                viewController.searchDelegate = self
            }
            
        }
    }

    func translations() {
        // View Title
        self.title = Translator.getLangValue(key: "settings")
        
        // Server URL title
        self.serverURLtitle.text = Translator.getLangValue(key: "server_url")
        
        // Module title
        self.moduleTitle.text = Translator.getLangValue(key: "profile")
        
        self.languageTitle.text = Translator.getLangValue(key: "language")
    }
    
    func insertProfile(IDLge: Int, IDModule: String, ModuleID: String, DashboardLink: String, DocumentationLink: String, ModuleDesc: String, WebServiceLink: String) {
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        
        try! db.run(PROFILE_DB.TABLE.create(ifNotExists: true) { t in
            t.column(PROFILE_DB.IDLge)
            t.column(PROFILE_DB.IDModule)
            t.column(PROFILE_DB.ModuleID, unique: true)
            t.column(PROFILE_DB.DashboardLink)
            t.column(PROFILE_DB.DocumentationLink)
            t.column(PROFILE_DB.ModuleDesc)
            t.column(PROFILE_DB.WebServiceLink)
        })
        
        let insert = PROFILE_DB.TABLE.insert(or: .replace, PROFILE_DB.IDLge <- IDLge, PROFILE_DB.IDModule <- IDModule, PROFILE_DB.ModuleID <- ModuleID, PROFILE_DB.DashboardLink <- DashboardLink, PROFILE_DB.DocumentationLink <- DocumentationLink, PROFILE_DB.ModuleDesc <- ModuleDesc, PROFILE_DB.WebServiceLink <- WebServiceLink)
        
        _ = try! db.run(insert)
        
    }
    
    func getModuleId() -> Int{
        let moduleId = self.profileSelect.index(of: self.moduleName.text!)
        return moduleId!
    }
    
    func getProfileLanguageId() -> Int {
        let langId = self.profileLang[getModuleId()]

        return langId
    }
    
    func getSavedLanguageId() -> Int {
        let languageId = self.languageSelect.index(of: Config.DEFAULTS.string(forKey: "selectedLanguage")!)
        
        return languageId!
    }
    
    func getSavedModuleId() -> Int {
        let moduleId = self.profileSelect.index(of: Config.DEFAULTS.string(forKey: "selectedModule")!)
        
        return moduleId!
    }
    
    func getSelectedLanguageId() -> Int {
        let languageId = self.languageSelect.index(of: self.languageName.text!)
        
        return languageID[languageId!]
    }
    
    func getLanguageId() -> Int {
        if(self.getProfileLanguageId() == 0) {
            return 0
        }
        
        let langId = self.languageID.index(of: self.getProfileLanguageId())
        return langId!
    }
    
    func saveButtonPressed() {
        view.endEditing(true)
        
        WS.LOGIN_SERVICE.getProfiles() { (result, succeed) in
            if(succeed){
                let profileCount = result.array?.count
                if(profileCount == 0) {
                    self.disableSaveButton()
                }else{
                    Config.DEFAULTS.set(self.moduleName.text!, forKey: "profileID")
                    WS.LANGUAGE_SERVICE.getTranslations(langID: self.getSelectedLanguageId()) { (results) in
                        for object in results.array! {
                            Translator.setLangValue(key: object["Entry"].string!, value: object["Text"].string!)
                        }
                    }
                    Config.DEFAULTS.set(self.languageName.text!, forKey: "selectedLanguage")
                    
                    if(self.moduleName.text! != "") {
                        Config.DEFAULTS.set(self.moduleName.text!, forKey: "selectedModule")
                    }
                    
                    self.view.makeToast("Settings saved!", duration: 3.0, position: .bottom)
                    _ = self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    func addSaveButton() {
        newSaveButton.addTarget(self, action: #selector(self.saveButtonPressed), for: UIControlEvents.touchUpInside)
        newSaveButton.setTitle(Translator.getLangValue(key: "save"), for: UIControlState.normal)
        newSaveButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        newSaveButton.sizeToFit()
        
        let saveButton = UIBarButtonItem(customView: newSaveButton)
        navigationItem.rightBarButtonItems = [saveButton]
    }
    
    func removeAuditorsAndMachines() {
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        let auditorsList = Table("auditorsList")
        let machinesList = Table("machinesList")
        
        do {
            if try db.run(auditorsList.delete()) > 0 {
                print("deleted Auditors list")
            } else {
                print("Auditors list not found")
            }
            
            if try db.run(machinesList.delete()) > 0 {
                print("deleted Machine List")
            } else {
                print("Machine List not found")
            }
            
            if try db.run(Login_DB.TABLE.delete()) > 0 {
                print("deleted Logins")
            } else {
                print("Logins not found")
            }
            
            if try db.run(Audit_DB.TABLE.delete()) > 0 {
                print("deleted Audits")
            } else {
                print("Audits not found")
            }
            
            Config.DEFAULTS.removeObject(forKey: "dateFromTimeStamp")
            Config.DEFAULTS.removeObject(forKey: "dateToTimeStamp")
            Config.DEFAULTS.removeObject(forKey: "user_filter")
            Config.DEFAULTS.removeObject(forKey: "machine_filter")
            
        } catch {
            print("delete failed: \(error)")
        }
    }
    
    func showActivityIndicatory(uiView: UIView) {
        
        container.frame = uiView.frame
        container.center = uiView.center
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor(red:0.27, green:0.27, blue:0.27, alpha:0.0)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2,
                                y: loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.startAnimating()
    }
    
    func stopActivityIndicatory() {
        actInd.stopAnimating()
        container.removeFromSuperview()
    }
}

extension NewSettingsViewController: SearchViewDelegate {
    func updateModule(data: String) {
        self.moduleName.text = data
        
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        if let profile = try! db.pluck(PROFILE_DB.TABLE.filter(PROFILE_DB.ModuleID == self.moduleName.text!)) {
            print(profile[PROFILE_DB.WebServiceLink])
            if(profile[PROFILE_DB.WebServiceLink] != "") {
                Config.DEFAULTS.set(profile[PROFILE_DB.WebServiceLink], forKey: "WS_URL")
                self.enableSaveButton()
                self.getLanguageList(moduleChanged: true)
                self.removeAuditorsAndMachines()
            }else{
                // create the alert
                let alert = UIAlertController(title: Translator.getLangValue(key: "invalid_web_service_url"), message: "", preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "ok"), style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
                self.disableSaveButton()
            }

        }
    }
    
    func updateLanguage(data: String) {
        self.languageName.text = data
    }
}

import UIKit
import SwiftyJSON
import SQLite
import UserNotifications

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet var profileField: UITextField!
    @IBOutlet var serverURLField: UITextField!
    @IBOutlet var profileLabel: UILabel!
    @IBOutlet var serverURLLabel: UILabel!
    @IBOutlet var languageTextField: UITextField!
    @IBOutlet var languageLabel: UILabel!
    
    let profilePicker = UIPickerView()
    var profileSelect = [String]()
    var profileLang = [Int]()
    var profileLangID:Int!
    
    let languagePicker = UIPickerView()
    var languageSelect = [String]()
    var languageID = [Int]()
    var selectedLangID:Int!
    
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var newSaveButton:UIButton = UIButton(type: UIButtonType.custom) as UIButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        profileLabel.text = Translator.getLangValue(key: "profile")
        serverURLLabel.text = Translator.getLangValue(key: "server_url")
        
        let toolBarLang = UIToolbar().ToolbarPiker(mySelect: #selector(toolBarLangDiss))
        languagePicker.delegate = self
        languagePicker.dataSource = self
        languageTextField.delegate = self
        languageTextField.inputView = languagePicker
        languageTextField.inputAccessoryView = toolBarLang
        
        let toolBarProfile = UIToolbar().ToolbarPiker(mySelect: #selector(toolBarProfileDiss))
        profilePicker.delegate = self
        profilePicker.dataSource = self
        profileField.delegate = self
        profileField.inputView = profilePicker
        profileField.inputAccessoryView = toolBarProfile
        
        languageLabel.text = Translator.getLangValue(key: "language")
        self.title = Translator.getLangValue(key: "settings")
        // Do any additional setup after loading the view.

        newSaveButton.addTarget(self, action: #selector(self.saveButtonPressed), for: UIControlEvents.touchUpInside)
        newSaveButton.setTitle(Translator.getLangValue(key: "save"), for: UIControlState.normal)
        newSaveButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        newSaveButton.sizeToFit()
        newSaveButton.isEnabled = false
        newSaveButton.isUserInteractionEnabled = false
        
        let saveButton = UIBarButtonItem(customView: newSaveButton)
        navigationItem.rightBarButtonItems = [saveButton]
        
        serverURLField.delegate = self
        
        // only for ADIENT APP
        if(APP_FLAVOR.APP == "adient"){
            self.serverURLField.textColor = UIColor(red:0.77, green:0.77, blue:0.77, alpha:1.0)
            Config.DEFAULTS.set(Adient.URL, forKey: "profileWSURL")
            self.serverURLField.isUserInteractionEnabled = false
        }
        
        if (Translator.checkIfKeyExist(key: "profileWSURL") == true) {
            serverURLField.text = Config.DEFAULTS.string(forKey: "profileWSURL")!
        }
        self.profileField.isUserInteractionEnabled = false
        self.languageTextField.isUserInteractionEnabled = false
        self.newSaveButton.isEnabled = false
        self.newSaveButton.isUserInteractionEnabled = false
        self.newSaveButton.alpha = 0.5
        
        if(serverURLField.text != "") {
            self.profileSelect.removeAll()
            self.showActivityIndicatory(uiView: self.view)
            WS.LOGIN_SERVICE.getProfiles() { (result, succeed) in
                if(succeed == true) {
                    for profilesArray in result.array! {
                        self.insertProfile(IDLge: profilesArray["IDLge"].int!, IDModule: profilesArray["IDModule"].string!, ModuleID: profilesArray["ModuleID"].string!, DashboardLink: profilesArray["DashboardLink"].string!, DocumentationLink: profilesArray["DocumentationLink"].string!, ModuleDesc: profilesArray["ModuleDesc"].string!, WebServiceLink: profilesArray["WebServiceLink"].string!)
                        self.profileSelect.append(profilesArray["ModuleID"].string!)
                        self.profileLang.append(profilesArray["IDLge"].int!)
                    }
                    self.profilePicker.reloadAllComponents()
                    self.profileField.isUserInteractionEnabled = true
                    
                    // ADIENT APP
                    if(APP_FLAVOR.APP != "adient") {
                        if(self.profileSelect.count > 0){
                            self.profileField.text = self.profileSelect[0]
                        }
                    }
                    if(self.profileLang.count > 0){
                        self.profileLangID = self.profileLang[0]
                    }
                    
                    if (Translator.checkIfKeyExist(key: "profileSelected") == true){
                        print(Config.DEFAULTS.string(forKey: "profileSelected"))
                        let defaultProfileIndex = self.profileSelect.index(of: Config.DEFAULTS.string(forKey: "profileSelected")!)
                        self.profilePicker.selectRow(defaultProfileIndex!, inComponent: 0, animated: true)
                        self.profileField.text = self.profileSelect[defaultProfileIndex!]
                        
                    }
                    
                    if(APP_FLAVOR.APP != "adient" || Translator.checkIfKeyExist(key: "adientLangChange")){
                        self.getLanguageList()
                    }
                    
                    if(APP_FLAVOR.APP == "adient") {
                       Config.DEFAULTS.set(Adient.URL, forKey: "adientLangChange")
                    }
                    
                }else{
                    self.view.makeToast(Translator.getLangValue(key: "could_not_download_profiles"), duration: 3.0, position: .bottom)
                    self.profileSelect.removeAll()
                    self.profileLang.removeAll()
                    self.languageSelect.removeAll()
                    self.profilePicker.reloadAllComponents()
                    self.languagePicker.reloadAllComponents()
                    self.profileField.text = ""
                    self.languageTextField.text = ""
                    self.profileField.isUserInteractionEnabled = false
                    self.languageTextField.isUserInteractionEnabled = false
                    self.newSaveButton.isEnabled = false
                    self.newSaveButton.isUserInteractionEnabled = false
                    Config.DEFAULTS.removeObject(forKey: "languageID")
                }
                self.stopActivityIndicatory()
            }
        }else{

        }
//        self.getLanguageList()
    }
    
    func getLanguageList () {
        WS.LANGUAGE_SERVICE.getLangList() { (results) in
            self.languageSelect.removeAll()
            self.languageID.removeAll()
            for object in results.array! {
                self.languageSelect.append(object["LgeDesc"].string!)
                self.languageID.append(object["IDLge"].int!)
            }
            self.newSaveButton.isEnabled = true
            self.newSaveButton.isUserInteractionEnabled = true
            self.newSaveButton.alpha = 1.0
            self.languagePicker.reloadAllComponents()
            self.languageTextField.isUserInteractionEnabled = true
            if let profileLangIDS = self.profileLangID {
                if(profileLangIDS != 0) {
                    let selectedLangIndex = self.languageID.index(of: self.profileLangID!)
                    self.languageTextField.text = self.languageSelect[selectedLangIndex!]
                    self.selectedLangID = self.languageID[selectedLangIndex!]
                    self.languagePicker.selectRow(selectedLangIndex!, inComponent: 0, animated: true)
                }else{
                    let selectedLangIndex = 0
                    self.languageTextField.text = self.languageSelect[selectedLangIndex]
                    self.selectedLangID = self.languageID[selectedLangIndex]
                    self.languagePicker.selectRow(selectedLangIndex, inComponent: 0, animated: true)
                }
            }


            if (Translator.checkIfKeyExist(key: "languageID") == true){
                let defaultLangIndex = self.languageSelect.index(of: Config.DEFAULTS.string(forKey: "languageID")!)
                if(defaultLangIndex != nil) {
                    self.languagePicker.selectRow(defaultLangIndex!, inComponent: 0, animated: true)
                    self.languageTextField.text = self.languageSelect[defaultLangIndex!]
                    self.selectedLangID = self.languageID[defaultLangIndex!]
                }
            }
         self.stopActivityIndicatory()   
        }
    }
    
    func toolBarLangDiss() {
        let row = languagePicker.selectedRow(inComponent: 0)
        languageTextField.text = languageSelect[row]
        view.endEditing(true)
        newSaveButton.isEnabled = true
        newSaveButton.isUserInteractionEnabled = true
        self.newSaveButton.alpha = 1.0
    }
    
    func toolBarProfileDiss() {
        let row = profilePicker.selectedRow(inComponent: 0)
            if(profileSelect.count > 0) {
                profileField.text = profileSelect[row]
            }
        view.endEditing(true)
        Config.DEFAULTS.removeObject(forKey: "languageID")
        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
        if let profile = try! db.pluck(PROFILE_DB.TABLE.filter(PROFILE_DB.ModuleID == profileField.text!)) {
            Config.DEFAULTS.set(profile[PROFILE_DB.WebServiceLink], forKey: "WS_URL")
            self.getLanguageList()
        }
    }
    
    func saveButtonPressed() {
        if(serverURLField.text! != ""){
            Config.DEFAULTS.set(serverURLField.text!, forKey: "profileWSURL")
            WS.LOGIN_SERVICE.getProfiles() { (result, succeed) in
                if(succeed){
                    Config.DEFAULTS.set(self.profileField.text!, forKey: "profileID")
                    self.view.endEditing(true)
                    if(self.selectedLangID != nil){
                        WS.LANGUAGE_SERVICE.getTranslations(langID: self.selectedLangID) { (results) in
                            for object in results.array! {
                                Translator.setLangValue(key: object["Entry"].string!, value: object["Text"].string!)
                            }
                        }
                        Config.DEFAULTS.set(self.languageTextField.text!, forKey: "languageID")
                        print(self.languageTextField.text!)
                        if(self.profileField.text! != "") {
                            Config.DEFAULTS.set(self.profileField.text!, forKey: "profileSelected")
                        }
                        
                        self.view.makeToast("Settings saved!", duration: 3.0, position: .bottom)
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    }else{
                        self.view.makeToast(Translator.getLangValue(key: "select_language"), duration: 3.0, position: .bottom)
                    }
                }else{
                    self.view.makeToast(Translator.getLangValue(key: "server_error"), duration: 3.0, position: .bottom)
                    self.profileSelect.removeAll()
                    self.languageSelect.removeAll()
                    self.profileLang.removeAll()
                    self.profilePicker.reloadAllComponents()
                    self.languagePicker.reloadAllComponents()
                    self.profileField.text = ""
                    self.languageTextField.text = ""
                    self.profileField.isUserInteractionEnabled = false
                    self.languageTextField.isUserInteractionEnabled = false
                    self.newSaveButton.isEnabled = false
                    self.newSaveButton.isUserInteractionEnabled = false
                    self.newSaveButton.alpha = 0.5
                    Config.DEFAULTS.removeObject(forKey: "languageID")
                    Config.DEFAULTS.removeObject(forKey: "profileWSURL")
                    self.view.endEditing(true)
                }
            }

        }else{
            view.endEditing(true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField == serverURLField){
            
            if(textField.text?.hasHTTPS())! {
                Config.DEFAULTS.removeObject(forKey: "profileSelected")
                self.profileSelect.removeAll()
                self.showActivityIndicatory(uiView: self.view)
                Config.DEFAULTS.set(textField.text!, forKey: "profileWSURL")
                WS.LOGIN_SERVICE.getProfiles() { (result, succeed) in
                    if(succeed == true){
                        for profilesArray in result.array! {
                            self.insertProfile(IDLge: profilesArray["IDLge"].int!, IDModule: profilesArray["IDModule"].string!, ModuleID: profilesArray["ModuleID"].string!, DashboardLink: profilesArray["DashboardLink"].string!, DocumentationLink: profilesArray["DocumentationLink"].string!, ModuleDesc: profilesArray["ModuleDesc"].string!, WebServiceLink: profilesArray["WebServiceLink"].string!)
                            self.profileSelect.append(profilesArray["ModuleID"].string!)
                            self.profileLang.append(profilesArray["IDLge"].int!)
                        }
                        self.profilePicker.reloadAllComponents()
                        self.profileField.isUserInteractionEnabled = true
                        self.profileField.text = self.profileSelect[0]
                        self.profileLangID = self.profileLang[0]
                        
                        let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
                        if let profile = try! db.pluck(PROFILE_DB.TABLE.filter(PROFILE_DB.ModuleID == self.profileField.text!)) {
                            Config.DEFAULTS.set(profile[PROFILE_DB.WebServiceLink], forKey: "WS_URL")
                            self.getLanguageList()
                        }
                        
                        if (Translator.checkIfKeyExist(key: "profileSelected") == true){
                            let defaultProfileIndex = self.profileSelect.index(of: Config.DEFAULTS.string(forKey: "profileSelected")!)
                            self.profilePicker.selectRow(defaultProfileIndex!, inComponent: 0, animated: true)
                            self.profileField.text = self.profileSelect[defaultProfileIndex!]
                            self.getLanguageList()
                        }
                        
                    }else{
                        self.view.makeToast(Translator.getLangValue(key: "server_error"), duration: 3.0, position: .bottom)
                        self.profileSelect.removeAll()
                        self.languageSelect.removeAll()
                        self.profileLang.removeAll()
                        self.profilePicker.reloadAllComponents()
                        self.languagePicker.reloadAllComponents()
                        self.profileField.text = ""
                        self.languageTextField.text = ""
                        self.profileField.isUserInteractionEnabled = false
                        self.languageTextField.isUserInteractionEnabled = false
                        self.newSaveButton.isEnabled = false
                        self.newSaveButton.isUserInteractionEnabled = false
                        self.newSaveButton.alpha = 0.5
                        Config.DEFAULTS.removeObject(forKey: "languageID")
                    }
                }
                self.stopActivityIndicatory()
            }else{
                self.view.makeToast(Translator.getLangValue(key: "invalid_server_url"), duration: 3.0, position: .bottom)
                self.profileSelect.removeAll()
                self.languageSelect.removeAll()
                self.profileLang.removeAll()
                self.profilePicker.reloadAllComponents()
                self.languagePicker.reloadAllComponents()
                self.profileField.text = ""
                self.languageTextField.text = ""
                self.profileField.isUserInteractionEnabled = false
                self.languageTextField.isUserInteractionEnabled = false
                self.newSaveButton.isEnabled = false
                self.newSaveButton.isUserInteractionEnabled = false
                self.newSaveButton.alpha = 0.5
                Config.DEFAULTS.removeObject(forKey: "languageID")
            }
        }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == languagePicker){
            return languageSelect.count
        }
        if (pickerView == profilePicker){
            return profileSelect.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == languagePicker){
            return languageSelect[row]
        }
        if (pickerView == profilePicker){
            return profileSelect[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (pickerView == languagePicker){
            languageTextField.text = languageSelect[row]
            selectedLangID = languageID[row]
        }
        if (pickerView == profilePicker) {
            profileField.text = profileSelect[row]
//            if (languageID.count > 0) {
//                print(languageID)
//                selectedLangID = languageID[row]
//            }
            let db = try! Connection("\(Config.PATH)/\(Config.DB_FILE)")
            if let profile = try! db.pluck(PROFILE_DB.TABLE.filter(PROFILE_DB.ModuleID == profileField.text!)) {
                if(profile[PROFILE_DB.WebServiceLink] == "") {
                    // create the alert
                    let alert = UIAlertController(title: Translator.getLangValue(key: "invalid_web_service_url"), message: "", preferredStyle: UIAlertControllerStyle.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: Translator.getLangValue(key: "ok"), style: UIAlertActionStyle.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }else{
                    Config.DEFAULTS.set(profile[PROFILE_DB.WebServiceLink], forKey: "WS_URL")
                    self.profileLangID = profile[PROFILE_DB.IDLge]
                    self.getLanguageList()
                }
            }
            self.removeAuditorsAndMachines()
        }
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
